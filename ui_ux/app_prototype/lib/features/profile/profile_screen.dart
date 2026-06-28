import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/enum/gender.dart';

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

    final name = userProvider.userExists ? userProvider.fullName : profile.name;
    final initials = userProvider.userExists ? userProvider.initials : profile.initials;
    final email = userProvider.userExists && userProvider.email.isNotEmpty
        ? userProvider.email
        : profile.email;
    final gender = userProvider.userExists ? userProvider.genderText : profile.gender.label;
    final age = userProvider.userExists ? userProvider.ageText : '—';
    final height = userProvider.userExists ? userProvider.heightText : '—';
    final weight = userProvider.userExists ? userProvider.weightText : '—';
    final skillLevel = userProvider.userExists ? userProvider.skillLevelText : profile.mobility;
    final injuryLabels = userProvider.userExists ? userProvider.injuryLabels : <String>[];

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
              HeaderAvatar(initials: initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.cardTitle),
                    Text(email, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        const SectionTitle('Deine Angaben'),
        _InfoRow(label: 'Geschlecht', value: gender),
        _InfoRow(label: 'Alter', value: age),
        _InfoRow(label: 'Größe', value: height),
        _InfoRow(label: 'Gewicht', value: weight),

        if (injuryLabels.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              background: AppColors.offwhite,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Verletzungen / Beschwerden', style: AppText.caption),
                      Text('${injuryLabels.length} ausgewählt',
                        style: AppText.micro.copyWith(color: AppColors.sageDeep),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: injuryLabels.map((injuryLabel) {
                      return AppTag(injuryLabel, variant: TagVariant.region);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],

        _InfoRow(label: 'Ziel', value: profile.goal),
        _InfoRow(label: 'Hauptregion', value: profile.region),
        _InfoRow(label: 'Fitnesslevel', value: skillLevel),
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
