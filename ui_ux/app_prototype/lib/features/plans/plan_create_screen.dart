import 'dart:math';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/provider/exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/enum/body_part.dart';
import '../../data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart' as api;

/// PERSON 2 — „Eigenen Plan erstellen" als 3-Schritt-Wizard.
///
/// Umsetzung von Sophias Redesign (03.07.26). Reihenfolge NEU:
///  1. „Wähle deine Übungen" — Filter (Körperteil + Trainingseffekt) + Suche +
///     Übungsliste mit „+".
///  2. „Name & Farbe für deinen Plan" — Planname, Planfarbe, Wochenziel (1–7).
///  3. „Alles bereit?" — Zusammenfassung + „Plan hinzufügen".
///
/// **Single-region:** Ein Plan hat genau EIN Körperteil ([BodyPart]) und EIN
/// Ziel ([Goal]) — passend zum Datenmodell der API-Gruppe (`Plan.region`/
/// `Plan.goal`). Der Körperteil-/Trainingseffekt-Filter ist daher
/// **Einfachauswahl** und legt zugleich region/goal des Plans fest.
///
/// Die Daten-Anbindung ist UNVERÄNDERT die der API-Gruppe:
/// `ExerciseProvider.loadAll(bodyPart, goal)` → `.exercises` und
/// `PlanProvider.savePlan(Plan(...))`.
class PlanCreateScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSaved;

  /// Optional vorausgewähltes Körperteil (z.B. aus einer Empfehlung).
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

/// Sophias Körperregion-Gruppierung über das bestehende [BodyPart]-Enum
/// (rein fürs UI — ändert nichts am Datenmodell).
const Map<String, List<BodyPart>> _kRegionGroups = {
  'Oberkörper': [
    BodyPart.shoulders,
    BodyPart.arms,
    BodyPart.elbows,
    BodyPart.wrists,
    BodyPart.chest,
    BodyPart.back,
    BodyPart.upperBack,
    BodyPart.lowerBack,
    BodyPart.neck,
    BodyPart.spine,
  ],
  'Rumpf': [
    BodyPart.core,
    BodyPart.obliques,
    BodyPart.pelvic,
    BodyPart.glutes,
  ],
  'Beine': [
    BodyPart.hip,
    BodyPart.psoas,
    BodyPart.thighs,
    BodyPart.quadriceps,
    BodyPart.hamstrings,
    BodyPart.knees,
    BodyPart.calves,
    BodyPart.ankles,
  ],
};
const List<String> _kRegionOrder = ['Oberkörper', 'Rumpf', 'Beine'];

class _PlanCreateScreenState extends State<PlanCreateScreen> {
  int _step = 1;

  // Schritt 1 — Übungswahl (Einfachauswahl → single-region)
  BodyPart? _region;
  Goal? _goal;
  final List<api.Exercise> _selected = [];
  String _search = '';
  bool _filterOpen = true;
  String? _openFilterCategory; // 'Körperteil' | 'Trainingseffekt'
  String? _openFilterRegion;

  // Schritt 2 — Name, Farbe, Wochenziel
  final TextEditingController _nameCtrl = TextEditingController();
  Color _color = PlanColors.all.first;
  int _sessionsPerWeek = 3;

  @override
  void initState() {
    super.initState();
    final pre = widget.prefilledRegion;
    if (pre != null) {
      _region = BodyPart.values.firstWhere(
        (e) => e.name == pre || e.label == pre,
        orElse: () => BodyPart.none,
      );
      if (_region == BodyPart.none) _region = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _isSelected(api.Exercise ex) => _selected.any((e) => e.id == ex.id);

  void _toggleExercise(api.Exercise ex) {
    setState(() {
      if (_isSelected(ex)) {
        _selected.removeWhere((e) => e.id == ex.id);
      } else {
        _selected.add(ex);
      }
    });
  }

  bool get _hasFilter => _region != null || _goal != null;
  bool get _canStep1 => _selected.isNotEmpty;
  bool get _canStep2 => _nameCtrl.text.trim().isNotEmpty;

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  /// Lädt Übungen über die API-Gruppen-Anbindung (nur wenn ein Körperteil
  /// gewählt ist — sonst gibt es keinen Bezug).
  Future<void> _reload() async {
    if (_region == null) return;
    await context
        .read<ExerciseProvider>()
        .loadAll(bodyPart: _region!, goal: _goal ?? Goal.none);
  }

  Future<void> _save() async {
    final planProvider = context.read<PlanProvider>();
    final planLogExerciseProvider = context.read<PlanLogExerciseProvider>();
    final plan = Plan(
      id: 'plan_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}',
      name: _nameCtrl.text.trim(),
      region: _region ?? BodyPart.none,
      goal: _goal ?? Goal.none,
      exercises: _selected,
      sessionsPerWeek: _sessionsPerWeek,
      source: 'eigen',
      colorValue: _color.toARGB32(),
    );
    await planProvider.savePlan(plan);
    await planLogExerciseProvider.loadTodayLogs(
        activePlans: planProvider.activePlans);
    if (mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 24),
            children: [
              AppBackButton(
                onTap:
                    _step == 1 ? widget.onBack : () => setState(() => _step--),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ProgressBar(step: _step),
              const SizedBox(height: AppSpacing.base),
              Text('SCHRITT $_step VON 3', style: AppText.micro),
              const SizedBox(height: AppSpacing.md),
              if (_step == 1) _buildStep1(context),
              if (_step == 2) _buildStep2(),
              if (_step == 3) _buildStep3(),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, 24),
          color: AppColors.cream,
          child: _buildFooter(),
        ),
      ],
    );
  }

  // ── Schritt 1: Übungen wählen ──────────────────────────────────
  Widget _buildStep1(BuildContext context) {
    final all = context.watch<ExerciseProvider>().exercises;
    final q = _search.trim().toLowerCase();
    final list = q.isEmpty
        ? all
        : all.where((e) => e.label.toLowerCase().contains(q)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wähle deine Übungen', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_selected.length} ${_selected.length == 1 ? 'Übung' : 'Übungen'} ausgewählt',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.base),
        _searchField(),
        const SizedBox(height: AppSpacing.sm),
        if (_hasFilter) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (_region != null)
                _activeFilterChip(_region!.label, () async {
                  setState(() => _region = null);
                  await _reload();
                }),
              if (_goal != null)
                _activeFilterChip(_goal!.label, () async {
                  setState(() => _goal = null);
                  await _reload();
                }),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _filterHeaderRow(),
        if (_filterOpen) ...[
          const SizedBox(height: AppSpacing.sm),
          _filterPanel(),
        ],
        const SizedBox(height: AppSpacing.base),
        if (_region == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              'Wähle oben einen Körperbereich, um passende Übungen zu sehen.',
              style: AppText.caption,
            ),
          )
        else
          for (final ex in list) _exerciseRow(ex),
        if (_region != null && list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text('Keine Übung gefunden. Passe Suche oder Filter an.',
                style: AppText.caption),
          ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Übung suchen',
                hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterHeaderRow() {
    return AppCard(
      onTap: () => setState(() => _filterOpen = !_filterOpen),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _hasFilter
                  ? 'Filter aktiv'
                  : 'Nach Körperteil oder Trainingseffekt filtern',
              style: AppText.cardTitle.copyWith(
                color: _hasFilter ? AppColors.sageDeep : AppColors.text,
              ),
            ),
          ),
          Icon(_filterOpen ? Icons.expand_less : Icons.chevron_right,
              size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _filterPanel() {
    return AppCard(
      child: Column(
        children: [
          _filterCategory(
            'Körperteil',
            child: Column(
              children: [
                for (final region in _kRegionOrder) _filterRegion(region),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.beige),
          _filterCategory(
            'Trainingseffekt',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final g in Goal.values.where((e) => e != Goal.none))
                  AppChip(
                    label: g.label,
                    active: _goal == g,
                    onTap: () async {
                      setState(() => _goal = (_goal == g) ? null : g);
                      await _reload();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterCategory(String title, {required Widget child}) {
    final open = _openFilterCategory == title;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _openFilterCategory = open ? null : title),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppText.cardTitle)),
                Icon(open ? Icons.expand_less : Icons.chevron_right,
                    size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (open)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: child,
            ),
          ),
      ],
    );
  }

  Widget _filterRegion(String region) {
    final parts = _kRegionGroups[region] ?? const <BodyPart>[];
    final open = _openFilterRegion == region;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _openFilterRegion = open ? null : region),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text(region, style: AppText.body)),
                Icon(open ? Icons.expand_less : Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final p in parts)
                  AppChip(
                    label: p.label,
                    active: _region == p,
                    onTap: () async {
                      // Einfachauswahl: neues Körperteil ersetzt das alte,
                      // Auswahl wird zurückgesetzt (anderer Bezug).
                      setState(() {
                        _region = (_region == p) ? null : p;
                        _selected.clear();
                      });
                      await _reload();
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _exerciseRow(api.Exercise ex) {
    final selected = _isSelected(ex);
    final tags = <String>[
      if (ex.bodyParts.isNotEmpty) ex.bodyParts.first,
      if (ex.trainingsEffects.isNotEmpty) ex.trainingsEffects.first,
      if (ex.difficulty.isNotEmpty) ex.difficulty,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => _toggleExercise(ex),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.label,
                      style: AppText.cardTitle,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${ex.duration} Min', style: AppText.micro),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final t in tags) _miniTag(t)],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.sageDeep : AppColors.white,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: AppColors.beige, width: 1.5),
              ),
              child: Icon(selected ? Icons.check : Icons.add,
                  size: 16,
                  color: selected ? AppColors.white : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.beige),
      ),
      child: Text(text,
          style: AppText.label
              .copyWith(fontSize: 11, color: AppColors.textSecondary)),
    );
  }

  Widget _activeFilterChip(String label, VoidCallback onRemove) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 7, bottom: 7),
        decoration: BoxDecoration(
          color: AppColors.sage,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppText.label.copyWith(color: AppColors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 13, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  // ── Schritt 2: Name, Farbe, Wochenziel ─────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name & Farbe für deinen Plan', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),
        Text('Planname', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        _TextField(
          controller: _nameCtrl,
          hint: 'z. B. Meine Knie-Routine',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Planfarbe', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final c in PlanColors.all)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _color == c ? AppColors.text : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: _color == c
                        ? const Icon(Icons.check,
                            size: 20, color: AppColors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Wochenziel', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wie oft pro Woche möchtest du diesen Plan absolvieren?',
                  style: AppText.body),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int n = 1; n <= 7; n++)
                    GestureDetector(
                      onTap: () => setState(() => _sessionsPerWeek = n),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _sessionsPerWeek == n
                              ? AppColors.sage
                              : AppColors.offwhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _sessionsPerWeek == n
                                ? AppColors.sage
                                : AppColors.beige,
                          ),
                        ),
                        child: Text('$n',
                            style: AppText.label.copyWith(
                              color: _sessionsPerWeek == n
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('${_sessionsPerWeek}x pro Woche', style: AppText.caption),
            ],
          ),
        ),
      ],
    );
  }

  // ── Schritt 3: Alles bereit? ───────────────────────────────────
  Widget _buildStep3() {
    final total = _selected.fold<int>(0, (sum, e) => sum + e.duration);
    final name = _nameCtrl.text.trim();
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
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: _color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(name.isEmpty ? 'Mein Plan' : name,
                        style: AppText.cardTitle.copyWith(fontSize: 16)),
                  ),
                  if (_region != null)
                    AppTag(_region!.label, variant: TagVariant.region),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.beige),
                    bottom: BorderSide(color: AppColors.beige),
                  ),
                ),
                child: Row(
                  children: [
                    _summaryStat('ÜBUNGEN', '${_selected.length}'),
                    _summaryStat('DAUER', '$total Min'),
                    _summaryStat('WOCHENZIEL', '${_sessionsPerWeek}x'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final ex in _selected)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: _color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(ex.label, style: AppText.body)),
                      Text('${ex.duration} Min', style: AppText.caption),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.micro),
          const SizedBox(height: 2),
          Text(value,
              style: AppText.cardTitle
                  .copyWith(fontSize: 16, color: AppColors.sageDeep)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
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
      label: 'Plan hinzufügen',
      icon: Icons.check,
      onPressed: _save,
    );
  }
}

/// Fortschrittsbalken mit 3 Segmenten.
class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int s = 1; s <= 3; s++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: s <= step ? AppColors.sage : AppColors.beige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (s < 3) const SizedBox(width: 6),
        ],
      ],
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
