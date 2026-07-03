import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 4 — Praxis & Termine.
///
/// Zwei Tabs: "Termine" (nächster Termin hervorgehoben + Liste) und
/// "Kontakt" (Praxis-Infos + Nachricht-Formular mit Betreff/Dringlichkeit).
/// Entspricht PracticeScreen im JSX-Prototyp.
class PracticeScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PracticeScreen({super.key, required this.onBack});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _contactTab = false;

  static const _subjectOptions = [
    'Frage zur Übung',
    'Termin verschieben',
    'Beschwerden',
    'Sonstiges',
  ];
  static const _urgencyOptions = ['Niedrig', 'Mittel', 'Hoch'];

  String _subject = _subjectOptions.first;
  String _urgency = 'Mittel';
  final _messageCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send(UiState app) {
    if (_messageCtrl.text.trim().isEmpty) return;
    app.showToast('Nachricht an die Praxis gesendet.');
    setState(() {
      _sent = true;
      _subject = _subjectOptions.first;
      _urgency = 'Mittel';
      _messageCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _sent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final appointments = app.appointments;
    final next = appointments.isNotEmpty ? appointments.first : null;
    final rest = appointments.length > 1 ? appointments.sublist(1) : [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.base, AppSpacing.screenH, 110),
      children: [
        AppBackButton(onTap: widget.onBack),
        const SizedBox(height: AppSpacing.base),
        Text('Meine Praxis', style: AppText.screenTitle),
        const SizedBox(height: AppSpacing.lg),

        // Tab-Umschalter: Termine / Kontakt
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.offwhite,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabBtn(
                  label: 'Termine',
                  active: !_contactTab,
                  onTap: () => setState(() => _contactTab = false),
                ),
              ),
              Expanded(
                child: _TabBtn(
                  label: 'Kontakt',
                  active: _contactTab,
                  onTap: () => setState(() => _contactTab = true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        if (!_contactTab) ...[
          if (next == null)
            AppCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text('Keine Termine vorhanden.',
                      style: AppText.caption),
                ),
              ),
            )
          else ...[
            // Nächster Termin (hervorgehoben, dunkle Fläche)
            Text('NÄCHSTER TERMIN', style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.sageDeep,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.onDarkIconBg,
                          borderRadius:
                              BorderRadius.circular(AppRadius.iconLarge),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(next.day,
                                style: AppText.cardTitle.copyWith(
                                    color: AppColors.white, fontSize: 18)),
                            Text(next.month,
                                style: AppText.micro.copyWith(
                                    color: AppColors.onDarkSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(next.type,
                                style: AppText.cardTitle
                                    .copyWith(color: AppColors.white)),
                            const SizedBox(height: 2),
                            Text('${next.weekday}, ${next.time} Uhr',
                                style: AppText.caption.copyWith(
                                    color: AppColors.onDarkSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Divider(color: AppColors.onDarkDivider, height: 1),
                  const SizedBox(height: AppSpacing.base),
                  _DarkInfoRow(
                      icon: Icons.person_outline, text: next.therapist),
                  const SizedBox(height: AppSpacing.sm),
                  _DarkInfoRow(
                      icon: Icons.meeting_room_outlined, text: next.room),
                  const SizedBox(height: AppSpacing.sm),
                  _DarkInfoRow(
                      icon: Icons.location_on_outlined, text: next.address),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Zum Kalender',
                    icon: Icons.event,
                    onPressed: () {
                      app.showToast('Zum Kalender hinzugefügt.');
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Nachricht',
                    icon: Icons.mail_outline,
                    onPressed: () => setState(() => _contactTab = true),
                  ),
                ),
              ],
            ),
          ],
          if (rest.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionTitle('Weitere Termine'),
            ...rest.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AppointmentRow(appointment: a as Appointment),
                )),
          ],
        ] else ...[
          // ── Kontakt-Tab ──
          AppCard(
            background: AppColors.offwhite,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Physio Praxis Müller', style: AppText.cardTitle),
                const SizedBox(height: 4),
                Text(
                  'Hauptstraße 14, 21255 Tostedt\nMo–Fr 8:00–18:00 Uhr',
                  style: AppText.caption.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle('Nachricht senden'),
          const SizedBox(height: AppSpacing.sm),
          Text('Betreff', style: AppText.caption),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final s in _subjectOptions)
                AppChip(
                  label: s,
                  active: _subject == s,
                  onTap: () => setState(() => _subject = s),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text('Dringlichkeit', style: AppText.caption),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final u in _urgencyOptions)
                AppChip(
                  label: u,
                  active: _urgency == u,
                  onTap: () => setState(() => _urgency = u),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text('Nachricht', style: AppText.caption),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.offwhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.beige),
            ),
            child: TextField(
              controller: _messageCtrl,
              minLines: 4,
              maxLines: 6,
              style: AppText.body,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                hintText: "Worum geht's? Schreib uns kurz, was los ist — "
                    'wir melden uns.',
                hintStyle:
                    AppText.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          PrimaryButton(
            label: _sent ? 'Gesendet ✓' : 'Nachricht senden',
            icon: Icons.send,
            onPressed: () => _send(app),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text('Antwort in der Regel innerhalb von 24 Std.',
                style: AppText.micro),
          ),
        ],
      ],
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppText.caption.copyWith(
            color: active ? AppColors.text : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DarkInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DarkInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onDarkSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: AppText.caption.copyWith(color: AppColors.white)),
        ),
      ],
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentRow({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(AppRadius.iconLarge),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(appointment.day,
                    style: AppText.cardTitle.copyWith(
                        color: AppColors.sageDeep, fontSize: 16)),
                Text(appointment.month,
                    style: AppText.micro.copyWith(color: AppColors.sageDeep)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.type, style: AppText.cardTitle),
                Text('${appointment.weekday}, ${appointment.time} Uhr',
                    style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
