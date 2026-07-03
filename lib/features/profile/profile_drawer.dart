import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import 'mobility_level_sheet.dart';
import 'notifications_sheet.dart';
import 'past_tips_sheet.dart';
import 'settings_sheet.dart';

/// PERSON 4 — Profil-Drawer (fährt von rechts ein).
///
/// Zeigt Profil-Kopf, schnelle Aktionen (Profil bearbeiten, Praxis,
/// Einstellungen), das Archiv (archivierte Pläne mit Wiederherstellen/
/// Löschen) und Abmelden. Entspricht ProfileDrawer im JSX-Prototyp.
///
/// Wird als Overlay über die App gelegt (siehe app_shell). Die Animation
/// (Slide-in + Overlay-Fade) übernimmt ein AnimationController.
class ProfileDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onEditProfile;
  final VoidCallback? onOpenPractice;

  const ProfileDrawer({
    super.key,
    required this.onClose,
    required this.onEditProfile,
    this.onOpenPractice,
  });

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _fade;
  bool _archiveOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.screenEntry,
    );
    _slide = CurvedAnimation(parent: _controller, curve: AppMotion.expoOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;
    final archived = app.plans.where((p) => p.archived).toList();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  color: Color.fromRGBO(31, 36, 33, 0.32 * _fade.value),
                ),
              ),
            ),
            // Drawer
            Positioned(
              top: 0,
              bottom: 0,
              right: -340 * (1 - _slide.value),
              width: 320,
              child: Material(
                color: AppColors.cream,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Schließen-Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _close,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.input),
                              ),
                              child: const Icon(Icons.close,
                                  size: 18, color: AppColors.text),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            // ── Profil-Kopf: großer Avatar zentriert ──
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.sageLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(profile.initials,
                                        style: AppText.screenTitle.copyWith(
                                            color: AppColors.sageDeep,
                                            fontSize: 30)),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(profile.name,
                                      style: AppText.screenTitle
                                          .copyWith(fontSize: 20)),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // ── Info-Karte: Trainingsbereiche + Mobilität ──
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Aktive Trainingsbereiche',
                                      style: AppText.caption),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: [
                                      for (final r in (profile.regions.isNotEmpty
                                          ? profile.regions
                                          : [profile.region]))
                                        AppTag(r, variant: TagVariant.region),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.base),
                                  const Divider(
                                      color: AppColors.beige, height: 1),
                                  const SizedBox(height: AppSpacing.base),
                                  Text('Mobilitätslevel',
                                      style: AppText.caption),
                                  const SizedBox(height: AppSpacing.sm),
                                  AppTag(
                                      MobilityLevelMeta.labelFor(
                                          profile.mobility),
                                      variant: TagVariant.region),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Menü-Karte ──
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  _MenuItem(
                                    icon: Icons.person_outline,
                                    label: 'Profil bearbeiten',
                                    onTap: widget.onEditProfile,
                                  ),
                                  const _MenuDivider(),
                                  _MenuItem(
                                    icon: Icons.notifications_none,
                                    label: 'Benachrichtigungen',
                                    onTap: () => NotificationsSheet.show(context),
                                  ),
                                  const _MenuDivider(),
                                  _MenuItem(
                                    icon: Icons.inventory_2_outlined,
                                    label: 'Archivierte Pläne (${archived.length})',
                                    onTap: () => setState(
                                        () => _archiveOpen = !_archiveOpen),
                                    trailing: Icon(
                                      _archiveOpen
                                          ? Icons.expand_less
                                          : Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const _MenuDivider(),
                                  _MenuItem(
                                    icon: Icons.lock_open_outlined,
                                    label: 'Vergangene Tages-Tipps',
                                    onTap: () =>
                                        PastTipsSheet.show(context),
                                  ),
                                  const _MenuDivider(),
                                  _MenuItem(
                                    icon: Icons.settings_outlined,
                                    label: 'Einstellungen',
                                    onTap: () => SettingsSheet.show(context),
                                  ),
                                ],
                              ),
                            ),

                            // Archiv-Liste (aufklappbar)
                            if (_archiveOpen) ...[
                              const SizedBox(height: AppSpacing.sm),
                              if (archived.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm,
                                      horizontal: AppSpacing.base),
                                  child: Text('Keine archivierten Pläne.',
                                      style: AppText.caption),
                                )
                              else
                                ...archived.map((p) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm),
                                      child: AppCard(
                                        background: AppColors.offwhite,
                                        padding: const EdgeInsets.all(
                                            AppSpacing.md),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color:
                                                    p.color ?? AppColors.sage,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            Expanded(
                                              child: Text(p.name,
                                                  style: AppText.body),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  app.restorePlan(p.id),
                                              child: const Icon(
                                                  Icons.restore,
                                                  size: 18,
                                                  color: AppColors.sage),
                                            ),
                                            const SizedBox(width: 14),
                                            GestureDetector(
                                              onTap: () =>
                                                  app.deletePlan(p.id),
                                              child: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                            ],

                            const SizedBox(height: AppSpacing.base),

                            // ── Ausloggen ──
                            GestureDetector(
                              onTap: () => app.showToast('Abgemeldet (Demo).'),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.card),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.logout,
                                        size: 18, color: PlanColors.koralle),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text('Ausloggen',
                                        style: AppText.cardTitle.copyWith(
                                            color: PlanColors.koralle)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: AppSpacing.base),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.sageDeep),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppText.cardTitle.copyWith(
                      fontWeight: FontWeight.w500)),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Divider(color: AppColors.beige, height: 1),
    );
  }
}
