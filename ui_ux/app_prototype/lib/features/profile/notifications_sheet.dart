import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// Benachrichtigungen-Sheet.
///
/// Schalter für die tägliche Trainings-Erinnerung und ein Zeit-Raster zur
/// Auswahl der Erinnerungszeit. Entspricht dem Benachrichtigungen-Sheet im
/// JSX-Prototyp.
class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

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
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  bool _enabled = true;
  late String _time;

  static const _times = [
    '06:00', '07:00', '08:00', '09:00',
    '10:00', '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00',
  ];

  @override
  void initState() {
    super.initState();
    _time = context.read<UiState>().profile.reminder;
    if (!_times.contains(_time)) _time = '08:00';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.base, AppSpacing.lg, AppSpacing.xl),
      child: SingleChildScrollView(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Benachrichtigungen',
                    style: AppText.screenTitle.copyWith(fontSize: 22)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                    ),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Schalter
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trainings-Erinnerung',
                            style: AppText.cardTitle),
                        const SizedBox(height: 2),
                        Text('Erinnert dich täglich an dein Training.',
                            style: AppText.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    activeColor: AppColors.white,
                    activeTrackColor: AppColors.sage,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Zeit-Raster
            if (_enabled)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Erinnern um', style: AppText.cardTitle),
                    const SizedBox(height: AppSpacing.base),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 2.1,
                      children: [
                        for (final t in _times)
                          GestureDetector(
                            onTap: () => setState(() => _time = t),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _time == t
                                    ? AppColors.sageLight
                                    : AppColors.offwhite,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.input),
                                border: Border.all(
                                  color: _time == t
                                      ? AppColors.sage
                                      : AppColors.beige,
                                ),
                              ),
                              child: Text(t,
                                  style: AppText.body.copyWith(
                                    color: _time == t
                                        ? AppColors.sageDeep
                                        : AppColors.text,
                                    fontWeight: _time == t
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  )),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            PrimaryButton(
              label: 'Speichern',
              icon: Icons.check,
              onPressed: () {
                final app = context.read<UiState>();
                app.updateProfile(app.profile.copyWith(reminder: _time));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
