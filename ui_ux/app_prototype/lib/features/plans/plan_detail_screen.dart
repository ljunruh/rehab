import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/models/api/api_models.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 2 — Detailansicht eines Trainingsplans.
///
/// Zeigt Plan-Cover, Name, Region-/Rubrik-/Kalenderfarbe-Tags, Kennzahlen,
/// im Bearbeiten-Modus die Farbauswahl + umsortierbare/löschbare
/// Übungsliste + Archivieren/Löschen, sonst "Training starten".
/// Entspricht PlanDetail im JSX-Prototyp (V12).
class PlanDetailScreen extends StatefulWidget {
  final String planId;
  final VoidCallback onBack;
  final ValueChanged<String> onStartTraining;
  final ValueChanged<String> onAddExercise;

  const PlanDetailScreen({
    super.key,
    required this.planId,
    required this.onBack,
    required this.onStartTraining,
    required this.onAddExercise,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _editing = false;
  bool _colorInfoOpen = false;

  static const _rubrikMap = [
    ['Kraft', 'Kräftigung', 'Kraft'],
    ['Mobil', 'Beweglich', 'Entlastung', 'Dehnung', 'Mobilisation'],
    ['Koordination', 'Stabilität', 'Gleichgewicht', 'Haltung', 'Koordination'],
    ['Entspannung', 'Ruhe', 'Entspannung'],
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().getPlan(widget.planId);
    });
  }

  String _rubrikLabel(String goal) {
    for (final entry in _rubrikMap) {
      final keys = entry.sublist(0, entry.length - 1);
      if (keys.any((k) => goal.contains(k))) return entry.last;
    }
    return 'Mobilisation';
  }

  Future<void> _confirmDelete(UiState app, api.Plan plan) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.cream,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFAE6DC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  size: 22, color: Color(0xFFC46A52)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Plan löschen?',
                style: AppText.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Möchtest du "${plan.name}" wirklich löschen? Diese Aktion '
              'kann nicht rückgängig gemacht werden.',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Abbrechen',
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB85C5C),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text('Löschen',
                          style:
                              AppText.button.copyWith(color: AppColors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      app.deletePlan(plan.id);
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final planProvider = context.watch<PlanProvider>();
    final plan = planProvider.plan;
    final exercises = plan?.exercises ?? [];
    final planDuration = plan?.duration;
    //final plan = app.planById(widget.planId);

    if (plan == null) {
      return Center(child: Text('Plan nicht gefunden.', style: AppText.body));
    }

    // UI DemoData auskommentieren
    // Übungen des Plans aus der Bibliothek auflösen (in exerciseIds-Reihenfolge).
    /*
    final exercises = <Exercise>[];
    for (final id in plan.exerciseIds) {
      for (final e in app.library) {
        if (e.id == id) {
          exercises.add(e);
          break;
        }
      }
    }

    final totalMinutes = exercises.fold<int>(0, (sum, e) {
      final m = int.tryParse(e.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + m;
    });
    */

    final accent = plan.color ?? AppColors.sage;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        AppBackButton(onTap: widget.onBack),
        const SizedBox(height: AppSpacing.base),

        // Cover (zentriert)
        Center(child: _PlanCover(region: plan.region)),
        const SizedBox(height: AppSpacing.lg),

        // Titel + Bearbeiten-Toggle
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: AppText.screenTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppTag(plan.region, variant: TagVariant.region),
                      AppTag(_rubrikLabel(plan.goal), variant: TagVariant.goal),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text('Kalenderfarbe',
                            style:
                                AppText.label.copyWith(color: AppColors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() => _editing = !_editing),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _editing ? AppColors.sageLight : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(_editing ? Icons.check : Icons.edit_outlined,
                    size: 16, color: AppColors.sageDeep),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Kennzahlen (linksbündig, letzte rechtsbündig)
        AppCard(
          background: AppColors.offwhite,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _StatBlock(label: 'ÜBUNGEN', value: '${exercises.length}'),
              const SizedBox(width: 28),
              _StatBlock(label: 'GESAMTDAUER', value: '$planDuration Min'),
              const Spacer(),
              _StatBlock(
                label: 'ABGESCHLOSSEN',
                value: '${plan.completedSessions}×',
                valueColor: AppColors.sageDeep,
                alignRight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Farbauswahl (nur im Bearbeiten-Modus)
        if (_editing) ...[
          Stack(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KALENDERFARBE', style: AppText.micro),
                    const SizedBox(height: AppSpacing.base),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        for (final c in PlanColors.all)
                          GestureDetector(
                            onTap: () => app.updatePlanColor(plan.id, c),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: accent.value == c.value
                                    ? Border.all(
                                        color: AppColors.text, width: 2)
                                    : null,
                              ),
                              child: accent.value == c.value
                                  ? const Icon(Icons.check,
                                      size: 16, color: AppColors.white)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _colorInfoOpen = !_colorInfoOpen),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _colorInfoOpen
                          ? AppColors.sageLight
                          : AppColors.offwhite,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                        _colorInfoOpen
                            ? 'assets/icons/other/info-green.svg'
                            : 'assets/icons/other/info-gray.svg',
                        width: 13, height: 13),
                  ),
                ),
              ),
              if (_colorInfoOpen)
                Positioned(
                  top: 42,
                  right: 12,
                  child: Container(
                    width: 196,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.beige),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Mit dieser Farbe erscheint der Plan in deinem Kalender.',
                      style: AppText.micro.copyWith(height: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],

        const SectionTitle('Übungen im Plan'),
        const SizedBox(height: AppSpacing.sm),

        if (exercises.isEmpty)
          AppCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text('Noch keine Übungen. Füge welche hinzu.',
                    style: AppText.caption),
              ),
            ),
          )
        else if (_editing)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                final exercises = List<api.Exercise>.from(plan.exercises);
                if (newIndex > oldIndex) newIndex -= 1;
                final movedExercise = exercises.removeAt(oldIndex);
                exercises.insert(newIndex, movedExercise);
                planProvider.updatePlanExercises(exercises);
              },
            children: [
              for (int i = 0; i < exercises.length; i++)
                Padding(
                  key: ValueKey(exercises[i].id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PlanExerciseRow(
                    index: i + 1,
                    exercise: exercises[i],
                    editing: true,
                    dragHandle: ReorderableDragStartListener(
                      index: i,
                      child: const _DragDots(),
                    ),
                    onRemove: () {
                      final exercises = List<api.Exercise>.from(plan.exercises);
                      exercises.remove(exercises[i]);
                      planProvider.updatePlanExercises(exercises);
                    },
                  ),
                ),
            ],
          )
        else
          for (int i = 0; i < exercises.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PlanExerciseRow(
                index: i + 1,
                exercise: exercises[i],
                editing: false,
              ),
            ),

        if (_editing) ...[
          const SizedBox(height: AppSpacing.sm),
          // "Übung aus Bibliothek hinzufügen" – im Prototyp optisch als
          // gestrichelte Karte, dort aber ohne Funktion (kein onClick,
          // toter Code). Damit das Team weiterhin Übungen ergänzen kann,
          // habe ich das hier bewusst funktionsfähig gelassen (führt zum
          // bestehenden Bibliotheks-Flow) statt es rein dekorativ zu
          // lassen — sonst gäbe es in der App gar keinen Weg mehr, einem
          // Plan nachträglich Übungen hinzuzufügen.
          GestureDetector(
            onTap: () => widget.onAddExercise(plan.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.mint, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 14, color: AppColors.sageDeep),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Übung aus Bibliothek hinzufügen',
                      style: AppText.caption.copyWith(
                          color: AppColors.sageDeep,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: () {
              app.archivePlan(plan.id);
              widget.onBack();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.archive_outlined,
                      size: 14, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Plan archivieren',
                      style:
                          AppText.button.copyWith(color: AppColors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _confirmDelete(app, plan),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFB85C5C),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline,
                      size: 14, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Plan löschen',
                      style:
                          AppText.button.copyWith(color: AppColors.white)),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 26),
          PrimaryButton(
            label: 'Training starten',
            icon: Icons.play_arrow,
            onPressed:
                exercises.isEmpty ? null : () => widget.onStartTraining(plan.id),
          ),
        ],
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignRight;

  const _StatBlock({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppText.micro),
        const SizedBox(height: 2),
        Text(value,
            style: AppText.cardTitle
                .copyWith(fontSize: 18, color: valueColor ?? AppColors.text)),
      ],
    );
  }
}

class _DragDots extends StatelessWidget {
  const _DragDots();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < 3; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3,
                    height: 3,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
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

class _PlanExerciseRow extends StatelessWidget {
  final int index;
  final api.Exercise exercise;
  final bool editing;
  final Widget? dragHandle;
  final VoidCallback? onRemove;

  const _PlanExerciseRow({
    required this.index,
    required this.exercise,
    required this.editing,
    this.dragHandle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (editing && dragHandle != null) ...[
            dragHandle!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.offwhite,
              shape: BoxShape.circle,
            ),
            child: Text('$index',
                style: AppText.micro.copyWith(
                    color: AppColors.sageDeep, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.label,
                    style: AppText.caption.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text('${exercise.duration} Min · ${exercise.difficulty}',
                    style: AppText.micro),
              ],
            ),
          ),
          if (editing && onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.offwhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset('assets/icons/other/trash.svg',
                    width: 14, height: 14,
                    colorFilter: const ColorFilter.mode(
                        AppColors.sageDeep, BlendMode.srcIn)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plan-Cover (großes, farbiges Badge), entspricht PlanCover im Prototyp.
class _PlanCover extends StatelessWidget {
  final String region;
  const _PlanCover({required this.region});

  static const _palettes = <String, ({Color bg, Color a, Color b})>{
    'Knie': (bg: Color(0xFFC8DDD2), a: Color(0xFF7A9B7E), b: Color(0xFF3F5E48)),
    'Schulter': (bg: Color(0xFFD7E4D3), a: Color(0xFF7FBFA8), b: Color(0xFF3F5E48)),
    'Rücken': (bg: Color(0xFFE8DFCF), a: Color(0xFFC9B79C), b: Color(0xFF7A9B7E)),
    'Nacken': (bg: Color(0xFFD9E3DC), a: Color(0xFFA6BFD1), b: Color(0xFF3F5E48)),
    'Hüfte': (bg: Color(0xFFE5DCC7), a: Color(0xFFD6B582), b: Color(0xFF3F5E48)),
    'Büro': (bg: Color(0xFFE8DFCF), a: Color(0xFFC9B79C), b: Color(0xFF7A9B7E)),
    'Morgen': (bg: Color(0xFFF3E0C6), a: Color(0xFFE0B575), b: Color(0xFFC46A52)),
    'Abend': (bg: Color(0xFFD7D4DE), a: Color(0xFFA6A0BF), b: Color(0xFF5B5273)),
    'Unterwegs': (bg: Color(0xFFD7E4D3), a: Color(0xFF7FBFA8), b: Color(0xFF3F5E48)),
  };

  @override
  Widget build(BuildContext context) {
    final p = _palettes[region] ?? _palettes['Knie']!;
    const dim = 140.0;
    IconData? icon;
    switch (region) {
      case 'Büro':
        icon = Icons.work_outline;
        break;
      case 'Morgen':
        icon = Icons.wb_sunny_outlined;
        break;
      case 'Abend':
        icon = Icons.dark_mode_outlined;
        break;
      case 'Unterwegs':
        icon = Icons.map_outlined;
        break;
    }

    return Container(
      width: dim,
      height: dim,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: icon == null
          ? null
          : Stack(
              children: [
                Positioned(
                  top: -dim * 0.12,
                  right: -dim * 0.12,
                  child: Container(
                    width: dim * 0.44,
                    height: dim * 0.44,
                    decoration: BoxDecoration(
                      color: p.a.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -dim * 0.18,
                  left: -dim * 0.12,
                  child: Container(
                    width: dim * 0.56,
                    height: dim * 0.56,
                    decoration: BoxDecoration(
                      color: p.b.withOpacity(0.32),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(child: Icon(icon, size: 52, color: p.b)),
              ],
            ),
    );
  }
}
