import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../navigation/screen_header.dart';

/// ┌──────────────────────────────────────────────────────────┐
/// │  PERSON 3 — FORTSCHRITT & KALENDER                        │
/// │  Verantwortlich für: ProgressScreen, Kalender-Widget,    │
/// │  Vollbild-Kalender, Schmerz-Charts, Tagesdetail.         │
/// │  Daten: app.painLogs, app.painHistory, app.calendarEvents│
/// └──────────────────────────────────────────────────────────┘
class ProgressScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  const ProgressScreen({super.key, required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.scrollBottom),
      children: [
        ScreenHeader(
          greeting: 'Fortschritt',
          subtitle: 'Dein Verlauf der letzten Wochen',
          initials: profile.initials,
          onAvatarTap: onOpenProfile,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(value: '${app.streak}', label: 'Tage am Stück'),
                    _Divider(),
                    _Metric(
                      value: '${app.completedSessionsThisWeek}',
                      label: 'diese Woche',
                    ),
                    _Divider(),
                    _Metric(value: '${app.painLogs.length}', label: 'Einträge'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionTitle('Schmerzverlauf'),
              ...app.painHistory.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                  child: _PainSummaryCard(region: entry.key, logs: entry.value),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const SectionTitle('Letzte Einträge'),
              ...app.painLogs.take(4).map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PainLogRow(log: l),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppText.screenTitle.copyWith(color: AppColors.sage)),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.beige);
}

class _PainSummaryCard extends StatelessWidget {
  final String region;
  final List<PainLog> logs;
  const _PainSummaryCard({required this.region, required this.logs});

  @override
  Widget build(BuildContext context) {
    final first = logs.isNotEmpty ? logs.first.level : 0;
    final last = logs.isNotEmpty ? logs.last.level : 0;
    final improved = last < first;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTag(region, variant: TagVariant.region),
                const SizedBox(height: AppSpacing.sm),
                Text('Von $first → $last (Schmerzlevel)',
                    style: AppText.caption),
              ],
            ),
          ),
          Icon(
            improved ? Icons.trending_down : Icons.trending_flat,
            color: improved ? AppColors.sage : AppColors.textMuted,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _PainLogRow extends StatelessWidget {
  final PainLog log;
  const _PainLogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: AppColors.offwhite,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(AppRadius.iconSmall),
            ),
            child: Text('${log.level}',
                style: AppText.cardTitle.copyWith(color: AppColors.sageDeep)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.region, style: AppText.cardTitle),
                if (log.note.isNotEmpty)
                  Text(log.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption),
              ],
            ),
          ),
          Text(log.dateKey, style: AppText.micro),
        ],
      ),
    );
  }
}
