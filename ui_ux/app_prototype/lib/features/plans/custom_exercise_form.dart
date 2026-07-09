import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../state/ui_state.dart';
import '../../data/models/models.dart';
import '../../data/demo/plan_options.dart';

/// PERSON 2 — Eigene Übung anlegen (Bottom-Sheet).
///
/// Erfasst Name, Region, Dauer, Schwierigkeit, Beschreibung und Hinweise und
/// speichert die Übung über UiState.addCustomExercise in die Bibliothek.
/// Entspricht CustomExerciseForm im JSX-Prototyp.
class CustomExerciseForm extends StatefulWidget {
  final String? planRegion;
  const CustomExerciseForm({super.key, this.planRegion});

  static Future<void> show(BuildContext context, {String? planRegion}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => CustomExerciseForm(planRegion: planRegion),
    );
  }

  @override
  State<CustomExerciseForm> createState() => _CustomExerciseFormState();
}

class _CustomExerciseFormState extends State<CustomExerciseForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hintsCtrl = TextEditingController();
  late String _region;
  int _duration = 5;
  String _difficulty = 'Leicht';

  @override
  void initState() {
    super.initState();
    _region = widget.planRegion ?? 'Knie';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _hintsCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  void _save() {
    final app = context.read<UiState>();
    final hints = _hintsCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    app.addCustomExercise(Exercise(
      id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      region: _region,
      duration: '$_duration Min',
      difficulty: _difficulty,
      description: desc.isNotEmpty
          ? desc
          : (hints.isNotEmpty ? hints : 'Eigene Übung'),
      steps: const [],
      safety: hints.isNotEmpty ? [hints] : const [],
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
                  Text('Eigene Übung',
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

              Text('Übungsname', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              _Field(controller: _nameCtrl, hint: 'z. B. Sanftes Dehnen',
                  onChanged: (_) => setState(() {})),
              const SizedBox(height: AppSpacing.base),

              Text('Körperregion', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final r in PlanOptions.regions.take(5))
                    AppChip(
                      label: r,
                      active: _region == r,
                      onTap: () => setState(() => _region = r),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Dauer: $_duration Min', style: AppText.caption),
              Slider(
                value: _duration.toDouble(),
                min: 1,
                max: 30,
                activeColor: AppColors.sage,
                onChanged: (v) => setState(() => _duration = v.round()),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text('Schwierigkeit', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final d in PlanOptions.difficulties)
                    AppChip(
                      label: d,
                      active: _difficulty == d,
                      onTap: () => setState(() => _difficulty = d),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Kurze Beschreibung', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _descCtrl,
                hint: 'Wie wird die Übung ausgeführt?',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Hinweise / Wiederholungen (optional)',
                  style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              _Field(controller: _hintsCtrl, hint: 'z. B. 3 × 10 Wiederholungen'),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Übung speichern',
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
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
