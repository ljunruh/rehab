import 'package:app_prototype/data/provider/pain_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';

/// "Einstellungen"-Sheet im Profil-Drawer (Person 4).
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

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
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Einstellungen',
                    style: AppText.screenTitle.copyWith(fontSize: 18)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.offwhite,
                      borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                    ),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Text('RECHTLICHES & DATEN', style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),
            _SettingsRow(
              icon: 'assets/icons/profile/shield.svg',
              label: 'Datenschutz',
              isFirst: true,
              onTap: () => context
                  .read<UiState>()
                  .showToast('Datenschutzerklärung (Demo).'),
            ),
            const SizedBox(height: 2),
            _SettingsRow(
              icon: 'assets/icons/other/info-green.svg',
              label: 'Lizenzen',
              onTap: () =>
                  context.read<UiState>().showToast('Lizenzen (Demo).'),
            ),
            const SizedBox(height: 2),
            const _DeleteTrainingDataAccordion(isLast: true),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String icon; // SVG-Asset-Pfad
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.offwhite,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(14) : const Radius.circular(4),
            bottom: isLast ? const Radius.circular(14) : const Radius.circular(4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(9),
              ),
              child: SvgPicture.asset(icon,
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                      AppColors.sageDeep, BlendMode.srcIn)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppText.cardTitle
                      .copyWith(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right,
                size: 15, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Ausklappbares Accordion für das Löschen von Trainingsaufzeichnungen
class _DeleteTrainingDataAccordion extends StatefulWidget {
  final bool isLast;

  const _DeleteTrainingDataAccordion({this.isLast = false});

  @override
  State<_DeleteTrainingDataAccordion> createState() =>
      _DeleteTrainingDataAccordionState();
}

class _DeleteTrainingDataAccordionState extends State<_DeleteTrainingDataAccordion> {
  bool _isExpanded = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Datum wählen';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _fromDate : _toDate) ?? now;

    final picked = await _AppDatePickerDialog.show(
      context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      title: isFrom ? 'Startdatum wählen' : 'Enddatum wählen',
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
            _toDate = picked;
          }
        } else {
          _toDate = picked;
          if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
            _fromDate = picked;
          }
        }
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.cream,
        elevation: 8,
        shadowColor: AppColors.toastShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                      ),
                      child: const Icon(Icons.delete_forever_rounded,
                          size: 20, color: Colors.redAccent),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.offwhite,
                          borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                        ),
                        child: const Icon(Icons.close, size: 14, color: AppColors.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Trainingsdaten löschen?',
                  style: AppText.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Möchtest du wirklich alle Trainingsdaten vom ${_formatDate(_fromDate)} bis ${_formatDate(_toDate)} unwiderruflich löschen?',
                  style: AppText.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Abbrechen',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(dialogContext).pop();

                          if (!mounted) return;

                          final painLogProv = context.read<PainLogProvider>();
                          final painLogExProv = context.read<PainLogExerciseProvider>();
                          final planLogExProv = context.read<PlanLogExerciseProvider>();

                          await painLogProv.deleteLogsBetween(_fromDate!, _toDate!);
                          await painLogExProv.deleteLogsBetween(_fromDate!, _toDate!);
                          await planLogExProv.deleteLogsBetween(_fromDate!, _toDate!);

                          if (!mounted) return;

                          setState(() {
                            _fromDate = null;
                            _toDate = null;
                            _isExpanded = false;
                          });
                        },
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                          ),
                          child: Text(
                            'Löschen',
                            style: AppText.button.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormValid = _fromDate != null && _toDate != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(4),
          bottom: widget.isLast && !_isExpanded
              ? const Radius.circular(14)
              : const Radius.circular(4),
        ),
      ),
      child: Column(
        children: [
          // Accordion Header
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: AppColors.sageDeep),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Trainingsaufzeichnung löschen',
                      style: AppText.cardTitle
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Accordion Body (Eingabefelder & Button)
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.beige),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Von',
                          valueText: _formatDate(_fromDate),
                          isSelected: _fromDate != null,
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _DateField(
                          label: 'Bis',
                          valueText: _formatDate(_toDate),
                          isSelected: _toDate != null,
                          onTap: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Bestätigen',
                    disabled: !isFormValid,
                    onPressed: isFormValid ? _showConfirmationDialog : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Datums-Auswahl-Feld Hilfswidget
class _DateField extends StatelessWidget {
  final String label;
  final String valueText;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.valueText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: isSelected ? AppColors.sageDeep : AppColors.beige,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.micro.copyWith(
                color: isSelected ? AppColors.sageDeep : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.text : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isSelected ? AppColors.sageDeep : AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Maße- & designgetreuer, mehrauflösungsfähiger Datums-Picker für die AppShell.
class _AppDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _AppDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required String title,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => _AppDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
      ),
    );
  }

  @override
  State<_AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<_AppDatePickerDialog> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  bool _showYearPicker = false;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  void _prevMonth() {
    setState(() {
      final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
      if (!prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, 1))) {
        _displayedMonth = prev;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
      if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1))) {
        _displayedMonth = next;
      }
    });
  }

  bool get _canGoPrev {
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    return !prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, 1));
  }

  bool get _canGoNext {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1));
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstWeekday = (DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday + 6) % 7;
    final today = DateTime.now();

    return Dialog(
      backgroundColor: AppColors.cream,
      elevation: 8,
      shadowColor: AppColors.toastShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kopfzeile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppText.cardTitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.offwhite,
                        borderRadius: BorderRadius.circular(AppRadius.iconSmall),
                      ),
                      child: const Icon(Icons.close, size: 14, color: AppColors.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Monats- und Jahres-Navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.offwhite,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _canGoPrev ? _prevMonth : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _canGoPrev ? AppColors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          size: 18,
                          color: _canGoPrev ? AppColors.sageDeep : AppColors.textMuted,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showYearPicker = !_showYearPicker),
                      child: Row(
                        children: [
                          Text(
                            '${_months[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                            style: AppText.cardTitle.copyWith(
                              fontSize: 14,
                              color: AppColors.sageDeep,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _showYearPicker ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: AppColors.sageDeep,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _canGoNext ? _nextMonth : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _canGoNext ? AppColors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: _canGoNext ? AppColors.sageDeep : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_showYearPicker) ...[
                // Schnell-Auswahl für das Jahr
                SizedBox(
                  height: 180,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.lastDate.year - widget.firstDate.year + 1,
                    itemBuilder: (context, index) {
                      final year = widget.firstDate.year + index;
                      final isSelected = _displayedMonth.year == year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _displayedMonth = DateTime(year, _displayedMonth.month, 1);
                            _showYearPicker = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.sageDeep : AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.sageDeep : AppColors.beige,
                            ),
                          ),
                          child: Text(
                            '$year',
                            style: AppText.caption.copyWith(
                              color: isSelected ? Colors.white : AppColors.text,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Wochentage-Header
                Row(
                  children: [
                    for (final w in _weekdays)
                      Expanded(
                        child: Center(
                          child: Text(
                            w,
                            style: AppText.micro.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Tage-Raster
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: firstWeekday + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) return const SizedBox.shrink();
                    final day = index - firstWeekday + 1;
                    final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);

                    final isSelected = _selectedDate.year == date.year &&
                        _selectedDate.month == date.month &&
                        _selectedDate.day == date.day;
                    final isToday = today.year == date.year &&
                        today.month == date.month &&
                        today.day == date.day;
                    final isDisabled = date.isBefore(widget.firstDate) ||
                        date.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day, 23, 59, 59));

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                      child: Center(
                        child: AnimatedContainer(
                          duration: AppMotion.standard,
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sageDeep
                                : (isToday ? AppColors.sageLight : Colors.transparent),
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: AppColors.sageDeep, width: 1.5)
                                : null,
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w400,
                              color: isDisabled
                                  ? AppColors.textMuted.withValues(alpha: 0.4)
                                  : (isSelected
                                      ? Colors.white
                                      : AppColors.text),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.base),

              // Aktions-Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Abbrechen',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(_selectedDate),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.sageDeep,
                          borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                        ),
                        child: Text(
                          'Auswählen',
                          style: AppText.button.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}