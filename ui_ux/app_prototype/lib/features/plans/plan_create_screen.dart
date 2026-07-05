import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../data/demo/plan_options.dart';

/// PERSON 2 — Plan-Erstellung als 3-Schritt-Wizard.
///
/// Schritt 1: Name, Region, Ziel.
/// Schritt 2: Übungen aus der Bibliothek der in Schritt 1 gewählten
///            Region auswählen (Suchfeld, sortiert nach Schwierigkeit —
///            kein Regionsfilter mehr nötig, kein "Eigene Übung
///            anlegen" mehr: laut Team-Feedback ergab beides während
///            der Plan-Erstellung keinen Sinn, da die Region schon
///            in Schritt 1 feststeht).
/// Schritt 3: Kalenderfarbe wählen + Zusammenfassung + Speichern.
/// Entspricht PlanCreate im JSX-Prototyp.
class PlanCreateScreen extends StatefulWidget {
  final VoidCallback onBack;

  /// Aufgerufen nach erfolgreichem Speichern (zurück zur Plan-Übersicht).
  final VoidCallback onSaved;

  /// Optional vorausgewählte Region (z.B. aus einer Empfehlung).
  final String? prefilledRegion;

  const PlanCreateScreen({
    super.key,
    required this.onBack,
    required this.onSaved,
    this.prefilledRegion,
  });

  @override
  State<PlanCreateScreen> createState() => _PlanCreateScreenState();
}

class _PlanCreateScreenState extends State<PlanCreateScreen> {
  int _step = 1;

  late final TextEditingController _nameCtrl;
  late String _region;
  String _goal = 'Mobilität';
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _region = widget.prefilledRegion ?? 'Knie';
    _nameCtrl = TextEditingController(text: '$_region-Plan');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onRegionChange(String r) {
    setState(() {
      _region = r;
      // Namensvorschlag aktualisieren, wenn der Nutzer ihn nicht selbst änderte.
      if (_nameCtrl.text.endsWith('-Plan')) {
        _nameCtrl.text = '$r-Plan';
      }
    });
  }

  bool get _canStep1 => _nameCtrl.text.trim().isNotEmpty;
  bool get _canStep2 => _selectedIds.isNotEmpty;

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  void _save() {
    final app = context.read<UiState>();
    final plan = TrainingPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      region: _region,
      goal: _goal,
      exerciseIds: _selectedIds.toList(),
      source: 'eigen',
    );
    app.savePlan(plan);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.base,
              AppSpacing.screenH,
              24,
            ),
            children: [
              Row(
                children: [
                  AppBackButton(
                    onTap: _step == 1
                        ? widget.onBack
                        : () => setState(() => _step--),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Fortschrittsbalken (3 Segmente)
              Row(
                children: [
                  for (int s = 1; s <= 3; s++) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: s <= _step ? AppColors.sage : AppColors.beige,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (s < 3) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text('SCHRITT $_step VON 3', style: AppText.micro),
              const SizedBox(height: AppSpacing.md),

              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(context),
              if (_step == 3) _buildStep3(context),
            ],
          ),
        ),

        // Footer-Button
        Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, 24),
          color: AppColors.cream,
          child: _buildFooterButton(),
        ),
      ],
    );
  }

  // ── Schritt 1: Name, Region, Ziel ──
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wie soll dein Plan heißen?', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),

        Text('Planname', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        _TextField(controller: _nameCtrl, hint: 'z. B. Knie Routine', onChanged: (_) => setState(() {})),
        const SizedBox(height: AppSpacing.lg),

        Text('Körperregion', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final r in PlanOptions.regions.take(5))
              AppChip(
                label: r,
                active: _region == r,
                onTap: () => _onRegionChange(r),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Ziel (optional)', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final g in PlanOptions.goals)
              AppChip(
                label: g,
                active: _goal == g,
                onTap: () => setState(() => _goal = g),
              ),
          ],
        ),
      ],
    );
  }

  // ── Schritt 2: Übungen auswählen ──
  IconData _regionIcon(String region) {
    switch (region) {
      case 'Schulter':
        return Icons.accessibility_new;
      case 'Knie':
        return Icons.accessibility;
      case 'Rücken':
        return Icons.airline_seat_recline_normal;
      case 'Nacken':
        return Icons.face_outlined;
      case 'Hüfte':
        return Icons.accessibility_new;
      case 'Morgen':
        return Icons.wb_sunny_outlined;
      case 'Abend':
        return Icons.dark_mode_outlined;
      case 'Büro':
        return Icons.work_outline;
      case 'Unterwegs':
        return Icons.map_outlined;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildStep2(BuildContext context) {
    final app = context.watch<UiState>();

    // Nur Übungen der in Schritt 1 gewählten Region (kein Regionsfilter
    // mehr nötig, da Schritt 1 die Region bereits festlegt) + Suche +
    // Sortierung nach Schwierigkeit (Leicht → Mittel → Anspruchsvoll).
    var library = app.library.where((e) => e.region == _region).toList();
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      library = library.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    library.sort((a, b) {
      final ia = PlanOptions.difficulties.indexOf(a.difficulty);
      final ib = PlanOptions.difficulties.indexOf(b.difficulty);
      return ia.compareTo(ib);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wähle deine Übungen', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_selectedIds.length} ${_selectedIds.length == 1 ? 'Übung' : 'Übungen'} ausgewählt · Region: $_region',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.base),

        // Suchfeld
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.beige),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  style: AppText.body,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    hintText: 'Übung suchen …',
                    hintStyle:
                        AppText.body.copyWith(color: AppColors.textMuted),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Übungsliste (nach Schwierigkeit sortiert)
        ...library.map((ex) {
          final selected = _selectedIds.contains(ex.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              onTap: () => setState(() {
                if (selected) {
                  _selectedIds.remove(ex.id);
                } else {
                  _selectedIds.add(ex.id);
                }
              }),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.sageLight : AppColors.mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_regionIcon(ex.region),
                        size: 20, color: AppColors.sageDeep),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name,
                            style: AppText.cardTitle,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${ex.duration} · ${ex.difficulty}',
                            style: AppText.micro),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.sage : Colors.transparent,
                      shape: BoxShape.circle,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.beige, width: 1.5),
                    ),
                    child: Icon(selected ? Icons.check : Icons.add,
                        size: 14,
                        color: selected
                            ? AppColors.white
                            : AppColors.textMuted),
                  ),
                ],
              ),
            ),
          );
        }),
        if (library.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              _searchQuery.trim().isEmpty
                  ? 'Keine Übungen für $_region verfügbar.'
                  : 'Keine Übung gefunden für "$_searchQuery".',
              style: AppText.caption,
            ),
          ),
      ],
    );
  }

  // ── Schritt 3: Zusammenfassung ──
  Widget _buildStep3(BuildContext context) {
    final app = context.watch<UiState>();
    final totalMinutes = _selectedIds.fold<int>(0, (sum, id) {
      for (final e in app.library) {
        if (e.id == id) {
          return sum + (int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
        }
      }
      return sum;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alles bereit?', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PLAN', style: AppText.micro),
              const SizedBox(height: 4),
              Text(_nameCtrl.text.trim(),
                  style: AppText.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppTag(_region, variant: TagVariant.region),
                  AppTag(_goal, variant: TagVariant.goal),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: AppColors.beige, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ÜBUNGEN', style: AppText.micro),
                          const SizedBox(height: 2),
                          Text('${_selectedIds.length}',
                              style: AppText.cardTitle.copyWith(
                                  fontSize: 16, color: AppColors.sageDeep)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAUER', style: AppText.micro),
                          const SizedBox(height: 2),
                          Text('$totalMinutes Min',
                              style: AppText.cardTitle.copyWith(
                                  fontSize: 16, color: AppColors.sageDeep)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    if (_step == 1) {
      return PrimaryButton(
        label: 'Weiter',
        icon: Icons.arrow_forward,
        disabled: !_canStep1,
        onPressed: _canStep1 ? _next : null,
      );
    }
    if (_step == 2) {
      return PrimaryButton(
        label: 'Weiter',
        icon: Icons.arrow_forward,
        disabled: !_canStep2,
        onPressed: _canStep2 ? _next : null,
      );
    }
    return PrimaryButton(
      label: 'Plan speichern',
      icon: Icons.check,
      onPressed: _save,
    );
  }
}

/// Einfaches gestyltes Textfeld (StyleGuide-konform).
class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _TextField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.offwhite,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
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
    );
  }
}
