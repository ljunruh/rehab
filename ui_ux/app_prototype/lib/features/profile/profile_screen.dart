import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/model/condition.dart';
import '../../data/model/enum/gender.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 4 — PROFIL, PRAXIS & NAVIGATION                   │
/// │  Verantwortlich für: ProfileScreen, ProfileDrawer,       │
/// │  PracticeScreen (Termine), BottomNav-Verdrahtung,        │
/// │  App-weites Routing (navigation/app_shell.dart).         │
/// └──────────────────────────────────────────────────────────┘
class ProfileScreen extends StatelessWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

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
              HeaderAvatar(initials: userProvider.initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userProvider.fullName, style: AppText.cardTitle),
                    Text(userProvider.email, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        const SectionTitle('Deine Angaben'),
        _InfoRow(label: 'Geschlecht', value: userProvider.genderText),
        _InfoRow(label: 'Alter', value: userProvider.ageText),
        _InfoRow(label: 'Größe', value: userProvider.heightText),
        _InfoRow(label: 'Gewicht', value: userProvider.weightText),

        if (userProvider.conditionLabels.isNotEmpty) ...[
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
                      Text('Einschränkungen', style: AppText.caption),
                      Text('${userProvider.conditionLabels.length} ausgewählt',
                        style: AppText.micro.copyWith(color: AppColors.sageDeep),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: userProvider.conditionLabels.map((cond) {
                      return AppTag(cond, variant: TagVariant.region);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],

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
