import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';

/// PERSON 3 — Termin/Ereignis anlegen (Bottom-Sheet).
///
/// Erfasst Titel, Datum, Uhrzeit und Notiz und speichert das Ereignis über
/// UiState.addCalendarEvent. Entspricht EventCreateSheet im JSX-Prototyp.
class EventCreateSheet extends StatefulWidget {
  final DateTime? prefilledDate;
  const EventCreateSheet({super.key, this.prefilledDate});

  static Future<void> show(BuildContext context, {DateTime? prefilledDate}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => EventCreateSheet(prefilledDate: prefilledDate),
    );
  }

  @override
  State<EventCreateSheet> createState() => _EventCreateSheetState();
}

class _EventCreateSheetState extends State<EventCreateSheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late DateTime _date;
  TimeOfDay? _time;
  String _type = 'appointment';

  @override
  void initState() {
    super.initState();
    _date = widget.prefilledDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  String get _dateKey =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _dateLabel =>
      '${_date.day}.${_date.month}.${_date.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final app = context.read<UiState>();
    final timeStr = _time != null
        ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
        : '08:00';
    app.addCalendarEvent(CalendarEvent(
      id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      region: '',
      dateKey: _dateKey,
      time: timeStr,
      type: _type,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Neuer Termin',
                      style: AppText.screenTitle.copyWith(fontSize: 20)),
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

              Text('Titel', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _titleCtrl,
                hint: 'z. B. Physiotherapie',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Art', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  AppChip(
                    label: 'Termin',
                    active: _type == 'appointment',
                    onTap: () => setState(() => _type = 'appointment'),
                  ),
                  AppChip(
                    label: 'Übung',
                    active: _type == 'exercise',
                    onTap: () => setState(() => _type = 'exercise'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Datum',
                      value: _dateLabel,
                      icon: Icons.event,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _PickerField(
                      label: 'Uhrzeit',
                      value: _time != null ? _time!.format(context) : 'wählen',
                      icon: Icons.schedule,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Notiz (optional)', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              _Field(controller: _noteCtrl, hint: 'z. B. Praxis Dr. Wagner'),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Termin speichern',
                icon: Icons.check,
                disabled: !_canSave,
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.offwhite,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.beige),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.sageDeep),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.offwhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
    );
  }
}
