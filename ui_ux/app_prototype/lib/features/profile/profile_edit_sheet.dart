import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/demo/plan_options.dart';
import '../../data/enum/gender.dart';
import '../../state/ui_state.dart';
import 'mobility_level_sheet.dart';

/// PERSON 4 — Profil bearbeiten (Bottom-Sheet), wie im Prototyp.
///
/// Datenschutz-Hinweis, Avatar, Name (änderbar), Stammdaten (Alter,
/// Größe, Geschlecht, Gewicht), Verletzung(en) (Körperregionen,
/// Mehrfachauswahl) und Mobilitätslevel mit "Level wählen/ändern"
/// (öffnet die Selbsteinschätzung). Entspricht dem
/// Profil-bearbeiten-Sheet im JSX-Prototyp (verschachtelt im
/// Profil-Drawer, kein 4-Fragen-Test).
class ProfileEditSheet extends StatefulWidget {
  const ProfileEditSheet({super.key});

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
      builder: (_) => const ProfileEditSheet(),
    );
  }

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UiState>().profile;
    _nameCtrl = TextEditingController(text: profile.name);
    _ageCtrl = TextEditingController(text: profile.age?.toString() ?? '');
    _heightCtrl =
        TextEditingController(text: profile.height?.toString() ?? '');
    _weightCtrl =
        TextEditingController(text: profile.weight?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();
    final profile = app.profile;
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
                  Text('Profil bearbeiten',
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
              const SizedBox(height: AppSpacing.base),

              // Datenschutz-Hinweis
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 18, color: AppColors.sageDeep),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Deine Daten verlassen nie dein Gerät. Alles wird '
                        'lokal gespeichert – sicher und privat.',
                        style: AppText.caption
                            .copyWith(color: AppColors.sageDeep, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Avatar mit Stift
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.sageLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(profile.initials,
                          style: AppText.screenTitle.copyWith(
                              color: AppColors.sageDeep, fontSize: 26)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 13, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // NAME
              Text('NAME', style: AppText.micro),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.beige),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _editingName
                          ? TextField(
                              controller: _nameCtrl,
                              autofocus: true,
                              style: AppText.body,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Text(_nameCtrl.text, style: AppText.body),
                            ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_editingName) {
                          app.updateProfile(
                              profile.copyWith(name: _nameCtrl.text.trim()));
                        }
                        setState(() => _editingName = !_editingName);
                      },
                      child: Text(_editingName ? 'Fertig' : 'Ändern',
                          style: AppText.body
                              .copyWith(color: AppColors.sageDeep)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // STAMMDATEN
              Text('STAMMDATEN', style: AppText.micro),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'Alter',
                      suffix: 'Jahre',
                      controller: _ageCtrl,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NumberField(
                      label: 'Größe',
                      suffix: 'cm',
                      controller: _heightCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _GenderField(
                      value: profile.gender,
                      onChanged: (g) =>
                          app.updateProfile(profile.copyWith(gender: g)),
                    ),
                    // _GenderField arbeitet jetzt direkt mit dem Gender-Enum
                    // der API (statt mit einem String).
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NumberField(
                      label: 'Gewicht',
                      suffix: 'kg',
                      controller: _weightCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // VERLETZUNG(EN)
              Text('Verletzung(en)', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final r in PlanOptions.regions)
                    AppChip(
                      label: r,
                      active: profile.regions.contains(r),
                      activeBorder: true,
                      onTap: () {
                        final next = List<String>.from(profile.regions);
                        if (next.contains(r)) {
                          next.remove(r);
                        } else {
                          next.add(r);
                        }
                        app.updateProfile(profile.copyWith(regions: next));
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // MOBILITÄTSLEVEL
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sage, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MOBILITÄTSLEVEL',
                        style: AppText.micro
                            .copyWith(color: AppColors.sageDeep)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Schätz dich selbst ein – wähle die Stufe, die am '
                      'besten zu dir passt.',
                      style: AppText.caption.copyWith(
                          height: 1.55, color: AppColors.text),
                    ),
                    if (MobilityLevelMeta.forKey(profile.mobility) !=
                        null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.input),
                        ),
                        child: Row(
                          children: [
                            Text('Aktuelles Level',
                                style: AppText.caption
                                    .copyWith(color: AppColors.text)),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              MobilityLevelMeta.labelFor(profile.mobility),
                              style: AppText.cardTitle.copyWith(
                                  color: AppColors.sageDeep,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _DarkButton(
                      label: MobilityLevelMeta.forKey(profile.mobility) !=
                              null
                          ? 'Level ändern'
                          : 'Level wählen',
                      icon: Icons.bolt,
                      onPressed: () => MobilityLevelSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Änderungen speichern',
                icon: Icons.check,
                onPressed: () {
                  app.updateProfile(profile.copyWith(
                    name: _nameCtrl.text.trim(),
                    age: int.tryParse(_ageCtrl.text),
                    height: int.tryParse(_heightCtrl.text),
                    weight: int.tryParse(_weightCtrl.text),
                  ));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dunkelgrüner (sageDeep) Voll-Button — für das Mobilitätslevel-Widget,
/// wo der normale Primär-Button laut Design-Feedback zu blass war.
class _DarkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DarkButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.sageDeep,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: AppText.button.copyWith(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;

  const _NumberField({
    required this.label,
    required this.suffix,
    required this.controller,
  });

  void _step(int delta) {
    final v = int.tryParse(controller.text) ?? 0;
    final next = (v + delta).clamp(0, 999);
    controller.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.only(left: 14, right: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.beige),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Text(suffix, style: AppText.micro),
              const SizedBox(width: 6),
              // Stepper-Pfeile (hoch/runter), wie im Prototyp
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _step(1),
                    child: const Icon(Icons.keyboard_arrow_up,
                        size: 15, color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => _step(-1),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 15, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderField extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;

  const _GenderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geschlecht', style: AppText.caption),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.beige),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Gender>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more,
                  size: 16, color: AppColors.textMuted),
              style: AppText.body,
              items: Gender.values
                  .map((g) =>
                      DropdownMenuItem(value: g, child: Text(g.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
