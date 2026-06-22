import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

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
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppText.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        widget.summary,
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: AppIconSize.defaultSize,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding, 0, AppSpacing.cardPadding, AppSpacing.cardPadding),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: AppText.body,
                    decoration: InputDecoration(
                      labelText: "Suchen...",
                      labelStyle: AppText.body.copyWith(color: AppColors.textSecondary),
                      floatingLabelStyle: AppText.body.copyWith(color: AppColors.sage, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: AppIconSize.defaultSize),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: AppIconSize.defaultSize),
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearch('');
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.offwhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: const BorderSide(color: AppColors.beige),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: const BorderSide(color: AppColors.beige),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        borderSide: const BorderSide(color: AppColors.sage),
                      ),
                    ),
                    onChanged: (value) {
                      widget.onSearch(value);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    height: 180,
                    child: widget.filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              "Keine Einträge gefunden",
                              style: AppText.caption.copyWith(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = widget.filteredItems[index];
                              final id = widget.getId(item);
                              final selected = widget.selectedIds.contains(id);

                              return CheckboxListTile(
                                value: selected,
                                activeColor: AppColors.sage,
                                checkColor: AppColors.white,
                                title: Text(
                                  widget.getTitle(item),
                                  style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                                ),
                                subtitle: widget.getSubtitle != null
                                    ? Text(
                                        widget.getSubtitle!(item),
                                        style: AppText.caption,
                                      )
                                    : null,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  widget.onSelectionChanged(
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