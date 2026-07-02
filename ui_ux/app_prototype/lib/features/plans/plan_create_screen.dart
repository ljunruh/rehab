import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/provider/exercise_provider.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:app_prototype/data/service/exercise_service.dart';
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
/// Schritt 2: Übungen aus der Bibliothek auswählen (mit Region-Filter).
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
  String _filterRegion = 'Alle';
  Color _color = PlanColors.tuerkis;
  int _sessionsPerWeek = 3;

  @override
  void initState() {
    super.initState();
    _region = widget.prefilledRegion ?? 'Knie';
    _filterRegion = widget.prefilledRegion ?? 'Alle';
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
      _filterRegion = r;
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
      sessionsPerWeek: _sessionsPerWeek,
      source: 'eigen',
      color: _color,
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
              if (_step == 3) _buildStep3(),
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
  Widget _buildStep2(BuildContext context) {
    final app = context.watch<UiState>();
    final library = _filterRegion == 'Alle'
        ? app.library
        : app.library.where((e) => e.region == _filterRegion).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wähle deine Übungen', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_selectedIds.length} ${_selectedIds.length == 1 ? 'Übung' : 'Übungen'} ausgewählt',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.base),

        // Region-Filter
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final r in PlanOptions.regionFilter)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AppChip(
                    label: r,
                    active: _filterRegion == r,
                    onTap: () => setState(() => _filterRegion = r),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Übungsliste
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.sage : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: selected ? AppColors.sage : AppColors.beige,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.white)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name, style: AppText.cardTitle),
                        Text('${ex.region} · ${ex.duration} · ${ex.difficulty}',
                            style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (library.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text('Keine Übungen in dieser Region.',
                style: AppText.caption),
          ),
      ],
    );
  }

  // ── Schritt 3: Farbe + Zusammenfassung ──
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fast geschafft', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text('Wähle eine Farbe und prüfe deinen Plan.',
            style: AppText.caption),
        const SizedBox(height: AppSpacing.lg),

        Text('Kalenderfarbe', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in PlanColors.all)
              GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color == c ? AppColors.text : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: _color == c
                      ? const Icon(Icons.check, size: 18, color: AppColors.white)
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Einheiten pro Woche', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (int n = 1; n <= 5; n++)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppChip(
                  label: '$n',
                  active: _sessionsPerWeek == n,
                  onTap: () => setState(() => _sessionsPerWeek = n),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Zusammenfassung
        AppCard(
          background: AppColors.offwhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_nameCtrl.text.trim(),
                        style: AppText.cardTitle),
                  ),
                  AppTag(_region, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Ziel: $_goal', style: AppText.caption),
              Text(
                  '${_selectedIds.length} Übungen · $_sessionsPerWeek×/Woche',
                  style: AppText.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    if (_step == 1) {
      //TODO: Test
      return PrimaryButton(
        label: 'Weiter',
        icon: Icons.arrow_forward,
        disabled: !_canStep1,
        onPressed: () {
        context.read<ExerciseProvider>().loadAll();
      },//_canStep1 ? _next : null,
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
