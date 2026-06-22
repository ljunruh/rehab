import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 4 — PROFIL, PRAXIS & NAVIGATION                   │
/// │  Verantwortlich für: ProfileScreen, ProfileDrawer,       │
/// │  PracticeScreen (Termine), BottomNav-Verdrahtung,        │
/// │  App-weites Routing (navigation/app_shell.dart).         │
/// └──────────────────────────────────────────────────────────┘
class ProfileScreen extends StatelessWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;
    final userProvider = context.watch<UserProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.base,
        AppSpacing.screenH,
        AppSpacing.scrollBottom,
      ),
      children: [
        Row(
          children: [
            AppBackButton(onTap: onBack),
            const SizedBox(width: AppSpacing.md),
            Text('Profil', style: AppText.screenTitle),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Avatar + Name
        AppCard(
          child: Row(
            children: [
              HeaderAvatar(initials: profile.initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: AppText.cardTitle),
                    Text(profile.email, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        const SectionTitle('Deine Angaben'),
        //TODO[Api]: Test
        _InfoRow(label: 'Alter', value: userProvider.user?.age.toString() ?? '—',),
        _InfoRow(label: 'Ziel', value: profile.goal),
        _InfoRow(label: 'Hauptregion', value: profile.region),
        _InfoRow(label: 'Beweglichkeit', value: profile.mobility),
        _InfoRow(label: 'Erinnerung', value: '${profile.reminder} Uhr'),
        const SizedBox(height: AppSpacing.sectionGap),

        PrimaryButton(
          label: 'Angaben bearbeiten',
          icon: Icons.edit_outlined,
          onPressed: () {
            // Demo: einfache Aktualisierung, später Edit-Formular.
            app.updateProfile(profile);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Löschen',
          icon: Icons.delete,
          // Nutzer wird gelöscht. Navigation zum UserSetupScreen
          onPressed: userProvider.deleteUser,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        background: AppColors.offwhite,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.caption),
            Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
