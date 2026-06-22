import 'package:flutter/material.dart';

class SelectableAccordion<T> extends StatefulWidget {
  final String title;

  /// Wird immer sichtbar angezeigt
  final Widget summary;

  /// Vollständige Liste
  final List<T> items;

  /// Gefilterte Liste
  final List<T> filteredItems;

  /// Suchfeld Callback
  final ValueChanged<String> onSearch;

  /// Liefert die ID eines Eintrags
  final String Function(T item) getId;

  /// Liefert den Titel eines Eintrags
  final String Function(T item) getTitle;

  /// Optionaler Untertitel
  final String Function(T item)? getSubtitle;

  /// Aktuell ausgewählte IDs
  final Set<String> selectedIds;

  /// Auswahl geändert
  final void Function(String id, bool selected) onSelectionChanged;

  const SelectableAccordion({
    super.key,
    required this.title,
    required this.summary,
    required this.items,
    required this.filteredItems,
    required this.onSearch,
    required this.getId,
    required this.getTitle,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.getSubtitle,
  });

  @override
  State<SelectableAccordion<T>> createState() =>
      _SelectableAccordionState<T>();
}

class _SelectableAccordionState<T>
    extends State<SelectableAccordion<T>> {
  bool _expanded = false;
  final TextEditingController _searchController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        widget.summary,
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 0, 16, 16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Suchen...",
                      prefixIcon:
                      const Icon(Icons.search),
                      suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(
                            Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                          setState(() {});
                        },
                      )
                          : null,
                      border:
                      const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.onSearch(value);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 180,
                    child: widget.filteredItems.isEmpty
                        ? const Center(
                      child: Text(
                          "Keine Einträge gefunden"),
                    )
                        : ListView.builder(
                      itemCount:
                      widget.filteredItems.length,
                      itemBuilder:
                          (context, index) {
                        final item = widget
                            .filteredItems[index];

                        final id =
                        widget.getId(item);

                        final selected = widget
                            .selectedIds
                            .contains(id);

                        return CheckboxListTile(
                          value: selected,
                          title: Text(
                            widget.getTitle(item),
                          ),
                          subtitle:
                          widget.getSubtitle !=
                              null
                              ? Text(
                            widget
                                .getSubtitle!(
                                item),
                            style:
                            const TextStyle(
                              fontSize:
                              12,
                            ),
                          )
                              : null,
                          onChanged: (value) {
                            widget
                                .onSelectionChanged(
                              id,
                              value ?? false,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}