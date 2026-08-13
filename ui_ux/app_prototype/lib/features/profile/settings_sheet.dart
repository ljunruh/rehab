import 'package:app_prototype/data/provider/pain_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
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
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.sageDeep,
              onPrimary: Colors.white,
              surface: AppColors.cream,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        title: Text('Trainingsdaten löschen?',
            style: AppText.screenTitle.copyWith(fontSize: 18)),
        content: Text(
          'Möchtest du wirklich alle Trainingsdaten vom ${_formatDate(_fromDate)} bis ${_formatDate(_toDate)} unwiderruflich löschen?',
          style: AppText.cardTitle.copyWith(fontWeight: FontWeight.normal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            //TODO[API]:
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // Löschung im Provider ausführen
              await context.read<PainLogProvider>().deleteLogsBetween(_fromDate!, _toDate!);
              await context.read<PainLogExerciseProvider>().deleteLogsBetween(_fromDate!, _toDate!);
              await context.read<PlanLogExerciseProvider>().deleteLogsBetween(_fromDate!, _toDate!);


              setState(() {
                _fromDate = null;
                _toDate = null;
                _isExpanded = false;
              });
            },
            child: const Text('Löschen',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFormValid ? _showConfirmationDialog : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        disabledBackgroundColor: AppColors.beige,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Bestätigen',
                        style: TextStyle(
                          color: isFormValid ? Colors.white : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.beige),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.micro),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.text : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today,
                    size: 13, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}