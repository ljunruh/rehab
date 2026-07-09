import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/ui_state.dart';

/// Eine Mobilitätsstufe zur Selbsteinschätzung (Person 4).
///
/// Entspricht `MOBILITY_LEVELS` im JSX-Prototyp: KEIN Fragebogen/Test,
/// sondern eine direkte Selbsteinschätzung mit drei Karten
/// (Niedrig/Mittel/Hoch), je mit Aussage-Text und Beispielen.
class MobilityLevelMeta {
  final String key;
  final String label;
  final Color color;
  final Color bg;
  final String statement;
  final List<String> examples;

  const MobilityLevelMeta({
    required this.key,
    required this.label,
    required this.color,
    required this.bg,
    required this.statement,
    required this.examples,
  });

  static const List<MobilityLevelMeta> all = [
    MobilityLevelMeta(
      key: 'Niedrig',
      label: 'Einsteiger',
      color: Color(0xFFC46A52),
      bg: Color(0xFFFAE6DC),
      statement:
          'Ich bin aktuell nur leicht belastbar und möchte langsam und '
          'sicher mit dem Training beginnen.',
      examples: ['Bürojob mit wenig Bewegung', 'leichte Hausarbeit'],
    ),
    MobilityLevelMeta(
      key: 'Mittel',
      label: 'Geübt',
      color: Color(0xFFC9A83C),
      bg: Color(0xFFFBF3DC),
      statement:
          'Ich bin regelmäßig aktiv, moderat belastbar und kann '
          'alltägliche sowie längere körperliche Aktivitäten gut bewältigen.',
      examples: ['30 Minuten Radfahren', '5–6 km Wanderung'],
    ),
    MobilityLevelMeta(
      key: 'Hoch',
      label: 'Fortgeschritten',
      color: AppColors.sageDeep,
      bg: AppColors.sageLight,
      statement:
          'Ich bin sportlich, gut belastbar und bereit für '
          'anspruchsvollere Übungen mit höherer Intensität.',
      examples: ['Joggen', 'Krafttraining'],
    ),
  ];

  static MobilityLevelMeta? forKey(String key) {
    for (final m in all) {
      if (m.key == key) return m;
    }
    return null;
  }

  /// Kurzes Label für eine Mobilitäts-Stufe (z.B. für Tags), fällt auf
  /// den rohen Schlüssel zurück falls unbekannt.
  static String labelFor(String key) => forKey(key)?.label ?? key;
}

class MobilityLevelSheet extends StatelessWidget {
  const MobilityLevelSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const MobilityLevelSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Text('Wie schätzt du dich ein?',
                style: AppText.screenTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Wähle die Stufe, die am ehesten zu deinem Alltag und '
              'deiner Aktivität passt.',
              style: AppText.caption.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final lvl in MobilityLevelMeta.all)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _LevelCard(
                  level: lvl,
                  selected: profile.mobility == lvl.key,
                  onTap: () {
                    app.updateProfile(profile.copyWith(mobility: lvl.key));
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final MobilityLevelMeta level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? level.bg : AppColors.offwhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? level.color : AppColors.beige,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level.label,
                  style: AppText.cardTitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? level.color : AppColors.text,
                  ),
                ),
                if (selected)
                  Icon(Icons.check, size: 16, color: level.color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              level.statement,
              style: AppText.caption.copyWith(height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Beispiele: ${level.examples.join(" · ")}',
              style: AppText.micro.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
