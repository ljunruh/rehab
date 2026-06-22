import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/demo/plan_options.dart';
import '../../navigation/screen_header.dart';

/// PERSON 2 — Übungs-Bibliothek.
///
/// Durchsuchbare Liste aller Übungen mit Region-Filter und Textsuche.
/// Antippen öffnet die Übungs-Detailansicht. Entspricht ExercisesScreen
/// im JSX-Prototyp.
class ExercisesScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final ValueChanged<String> onOpenExercise;

  const ExercisesScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenExercise,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _filterRegion = 'Alle';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();

    var list = app.library;
    if (_filterRegion != 'Alle') {
      list = list.where((e) => e.region == _filterRegion).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        ScreenHeader(
          greeting: 'Übungen',
          subtitle: '${app.library.length} Übungen in der Bibliothek',
          initials: app.profile.initials,
          onAvatarTap: widget.onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suchfeld
              TextField(
                onChanged: (t) => setState(() => _query = t),
                style: AppText.body,
                decoration: InputDecoration(
                  hintText: 'Übung suchen …',
                  hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.offwhite,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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

              // Liste
              ...list.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () => widget.onOpenExercise(ex.id),
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.iconLarge),
                            ),
                            child: const Icon(Icons.self_improvement,
                                color: AppColors.sageDeep, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.name, style: AppText.cardTitle),
                                const SizedBox(height: 2),
                                Text(
                                    '${ex.region} · ${ex.duration} · ${ex.difficulty}',
                                    style: AppText.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textMuted, size: 20),
                        ],
                      ),
                    ),
                  )),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text('Keine Übungen gefunden.',
                        style: AppText.caption),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
