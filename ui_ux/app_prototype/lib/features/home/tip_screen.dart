import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/demo/demo_data.dart';

/// PERSON 1 — Alltagstipp-Detailansicht.
///
/// Zeigt den zur Hauptregion des Profils passenden Tipp (Bild-Platzhalter,
/// Eyebrow, Titel, Fließtext). Entspricht TipScreen im JSX-Prototyp –
/// ohne API-Aufruf, der Text kommt aus den Demo-Daten.
class TipScreen extends StatelessWidget {
  final VoidCallback onBack;
  const TipScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final tip = DemoData.tipForRegion(app.profile.region);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        110,
      ),
      children: [
        AppBackButton(onTap: onBack),
        const SizedBox(height: AppSpacing.base),

        // Bild-Platzhalter (Verlauf mint → sageLight)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.mint, AppColors.sageLight],
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0x40FFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 24,
                  left: 24,
                  child: Icon(Icons.auto_awesome,
                      size: 42, color: AppColors.sageDeep),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(
          'ALLTAGSTIPP · ${tip.duration}'.toUpperCase(),
          style: AppText.micro,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(tip.title, style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.base),
        Text(
          tip.body,
          style: AppText.body.copyWith(height: 1.65),
        ),
      ],
    );
  }
}
