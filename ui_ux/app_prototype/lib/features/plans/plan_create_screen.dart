import 'dart:math';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/enum/body_part.dart';
import '../../data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart' as api;
import '../profile/setup/selectable_accordion.dart';

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
  late BodyPart _region;
  Goal _goal = Goal.mobility;
  final List<api.Exercise> _selectedExercises = [];
  List<api.Exercise> _filteredExercises = [];
  String _exerciseSearchQuery = "";
  late Color _color; // Dynamische Initialisierung statt starrer Vorgabe
  int _sessionsPerWeek = 3;

  @override
  void initState() {
    super.initState();
    _region = widget.prefilledRegion != null
        ? BodyPart.values.firstWhere(
            (e) =>
        e.name == widget.prefilledRegion ||
            e.label == widget.prefilledRegion,
        orElse: () => BodyPart.knees)
        : BodyPart.knees;
    _nameCtrl = TextEditingController(text: '${_region.label}-Plan');

    // Farbe dynamisch basierend auf bereits vorhandenen Plänen wählen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assignInitialColor();
    });
  }

  /// Wählt als Erstbelegung eine Farbe, die idealerweise noch nicht vergeben ist
  void _assignInitialColor() {
    final planProvider = context.read<PlanProvider>();
    final usedColors = planProvider.activePlans.map((p) => p.color).toList();

    // Suche die erste verfügbare Farbe aus PlanColors.all, die noch nicht genutzt wird
    final availableColor = PlanColors.all.firstWhere(
          (c) => !usedColors.contains(c),
      orElse: () => PlanColors.all[
      planProvider.activePlans.length % PlanColors.all.length],
    );

    setState(() {
      _color = availableColor;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onRegionChange(BodyPart r) {
    setState(() {
      _region = r;
      // Namensvorschlag aktualisieren, wenn der Nutzer ihn nicht selbst änderte.
      if (_nameCtrl.text.endsWith('-Plan')) {
        _nameCtrl.text = '${r.label}-Plan';
      }
    });
  }

  bool get _canStep1 => _nameCtrl.text.trim().isNotEmpty;
  bool get _canStep2 => _selectedExercises.isNotEmpty;

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  void _save() {
    final planProvider = context.read<PlanProvider>();
    final plan = Plan(
      id: 'plan_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}',
      name: _nameCtrl.text.trim(),
      region: _region,
      goal: _goal,
      exercises: _selectedExercises,
      sessionsPerWeek: _sessionsPerWeek,
      source: 'eigen',
      colorValue: _color.toARGB32(), // Verwendet die ausgewählte bzw. zugewiesene Farbe
    );
    planProvider.savePlan(plan);
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
        _TextField(
            controller: _nameCtrl,
            hint: 'z. B. Knie Routine',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: AppSpacing.lg),

        Text('Körperregion', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final r in BodyPart.values.where((e) => e != BodyPart.none))
              AppChip(
                label: r.label,
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
            for (final g in Goal.values.where((e) => e != Goal.none))
              AppChip(
                label: g.label,
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
    final exercises = context.watch<ExerciseProvider>().exercises;
    if (_exerciseSearchQuery.isEmpty &&
        _filteredExercises.isEmpty &&
        exercises.isNotEmpty) {
      _filteredExercises = exercises;
    }

    return SelectableAccordion<api.Exercise>(
      title: 'Wähle deine Übungen',
      summary: Text(
        '${_selectedExercises.length} ${_selectedExercises.length == 1 ? 'Übung' : 'Übungen'} ausgewählt',
        style: AppText.caption,
      ),
      items: exercises,
      filteredItems: _filteredExercises,
      onSearch: (query) {
        setState(() {
          _exerciseSearchQuery = query;
          if (query.isEmpty) {
            _filteredExercises = exercises;
          } else {
            _filteredExercises = exercises
                .where((e) =>
            e.label.toLowerCase().contains(query.toLowerCase()) ||
                e.description.toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
        });
      },
      getTitle: (ex) => ex.label,
      getSubtitle: (ex) => '${ex.difficulty} · ${ex.duration} Min',
      selectedItems: _selectedExercises,
      onSelectionChanged: (exercise, selected) {
        setState(() {
          if (selected) {
            _selectedExercises.add(exercise);
          } else {
            _selectedExercises.remove(exercise);
          }
        });
      },
    );
  }

  // ── Schritt 3: Farbe + Zusammenfassung ──
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fast geschafft', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text('Wähle eine Farbe und prüfe deinen Plan.', style: AppText.caption),
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
                      ? const Icon(Icons.check,
                      size: 18, color: AppColors.white)
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
                    child:
                    Text(_nameCtrl.text.trim(), style: AppText.cardTitle),
                  ),
                  AppTag(_region.label, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Ziel: ${_goal.label}', style: AppText.caption),
              Text(
                  '${_selectedExercises.length} Übungen · $_sessionsPerWeek×/Woche',
                  style: AppText.caption),
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
        onPressed: () async {
          final provider = context.read<ExerciseProvider>();
          await provider.loadAll(
            bodyPart: _region,
            goal: _goal,
          );
          setState(() {
            _filteredExercises = provider.exercises;
            _next();
          });
        },
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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