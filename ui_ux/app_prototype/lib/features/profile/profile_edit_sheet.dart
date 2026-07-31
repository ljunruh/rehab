import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/demo/plan_options.dart';
import '../../data/enum/contraindication.dart';
import '../../data/enum/gender.dart';
import '../../data/enum/skill_level.dart';
import '../../state/ui_state.dart';
import 'mobility_level_sheet.dart';
import 'body_map_selector.dart';
import 'package:app_prototype/data/provider/user_provider.dart';

/// PERSON 4 — Profil bearbeiten (Bottom-Sheet), wie im Prototyp.
class ProfileEditSheet extends StatefulWidget {
  final VoidCallback? onClose;

  const ProfileEditSheet({super.key, this.onClose});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 380),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
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
  late Gender _selectedGender;
  late SkillLevel _selectedSkillLevel;
  late List<String> _selectedInjuries;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    _nameCtrl = TextEditingController(text: user?.name ?? 'Name eingeben');
    _ageCtrl = TextEditingController(text: user?.age.toString() ?? '');
    _heightCtrl = TextEditingController(text: user?.height.toString() ?? '');
    _weightCtrl = TextEditingController(text: user?.weight.toString() ?? '');
    _selectedGender = user?.gender ?? Gender.diverse;
    _selectedSkillLevel = user?.skillLevel ?? SkillLevel.beginner;

    _selectedInjuries = List.from(user?.contraindication ?? [])
        .map((e) => ContraindicationExt.fromString(e).label)
        .toList();
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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final userInitials = userProvider.initials;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.base,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
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
                  Text(
                    'Profil bearbeiten',
                    style: AppText.screenTitle.copyWith(fontSize: 22),
                  ),
                  GestureDetector(
                    onTap: () => widget.onClose != null
                        ? widget.onClose!()
                        : Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppRadius.iconSmall,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: AppColors.sageDeep,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Deine Daten verlassen nie dein Gerät. Alles wird lokal gespeichert – sicher und privat.',
                        style: AppText.caption.copyWith(
                          color: AppColors.sageDeep,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                      child: Text(
                        userInitials,
                        style: AppText.screenTitle.copyWith(
                          color: AppColors.sageDeep,
                          fontSize: 26,
                        ),
                      ),
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
                        child: const Icon(
                          Icons.edit,
                          size: 13,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('NAME', style: AppText.micro),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_nameCtrl.text, style: AppText.body),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _editingName = !_editingName),
                      child: Text(
                        _editingName ? 'Fertig' : 'Ändern',
                        style: AppText.body.copyWith(color: AppColors.sageDeep),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                      value: _selectedGender,
                      onChanged: (g) => setState(() => _selectedGender = g),
                    ),
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

              Text('Beschwerdebereich', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: BodyMapSelector(
                  selected: _selectedInjuries,
                  onChanged: (nextInjuries) {
                    setState(() {
                      _selectedInjuries = nextInjuries;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // MOBILITÄTSLEVEL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sage, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOBILITÄTSLEVEL',
                      style: AppText.micro.copyWith(color: AppColors.sageDeep),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Schätz dich selbst ein – wähle die Stufe, die am besten zu dir passt.',
                      style: AppText.caption.copyWith(
                        height: 1.55,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Aktuelles Level',
                            style: AppText.caption.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            // Einheitliche Anzeige direkt aus dem State-Enum (_selectedSkillLevel)
                            _selectedSkillLevel == SkillLevel.advanced
                                ? 'Fortgeschritten'
                                : _selectedSkillLevel == SkillLevel.intermediate
                                ? 'Geübt'
                                : 'Anfänger',
                            style: AppText.cardTitle.copyWith(
                              color: AppColors.sageDeep,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DarkButton(
                      label: 'Level ändern',
                      icon: Icons.bolt,
                      onPressed: () async {
                        final app = context.read<UiState>();
                        String initialKey = 'Niedrig';
                        if (_selectedSkillLevel == SkillLevel.advanced) initialKey = 'Hoch';
                        if (_selectedSkillLevel == SkillLevel.intermediate) initialKey = 'Mittel';
                        app.updateProfile(app.profile.copyWith(mobility: initialKey));

                        await MobilityLevelSheet.show(context);

                        if (context.mounted) {
                          final key = app.profile.mobility;
                          setState(() {
                            if (key == 'Hoch') {
                              _selectedSkillLevel = SkillLevel.advanced;
                            } else if (key == 'Mittel') {
                              _selectedSkillLevel = SkillLevel.intermediate;
                            } else {
                              _selectedSkillLevel = SkillLevel.beginner;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Speichern Button
              PrimaryButton(
                label: 'Änderungen speichern',
                icon: Icons.check,
                onPressed: () async {
                  final ontologyIds = _selectedInjuries.map((germanLabel) {
                    final contraindication = Contraindication.values.firstWhere(
                          (e) => e.label == germanLabel,
                      orElse: () => Contraindication.none,
                    );
                    return contraindication.labelEN;
                  }).where((id) => id != "None").toList();


                  await userProvider.saveUser(
                    name: _nameCtrl.text.trim(),
                    gender: _selectedGender,
                    age: int.tryParse(_ageCtrl.text) ?? user?.age ?? 0,
                    height: int.tryParse(_heightCtrl.text) ?? user?.height ?? 0,
                    weight: int.tryParse(_weightCtrl.text) ?? user?.weight ?? 0,
                    skillLevel: _selectedSkillLevel,
                    injuries: ontologyIds,
                  );
                  widget.onClose != null
                      ? widget.onClose!()
                      : Navigator.of(context).pop();
                },
              ),
              // „Profil löschen" entfernt: Team-Entscheidung — kein Login/Konto,
              // daher keine Profil-Löschung.
            ],
          ),
        ),
      ),
    );
  }
}

// Kleinere Hilfs-Widgets (_DarkButton, _NumberField, _GenderField) bleiben exakt wie gehabt...
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
            Text(label, style: AppText.button.copyWith(color: AppColors.white)),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _step(1),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _step(-1),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
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
              icon: const Icon(
                Icons.expand_more,
                size: 16,
                color: AppColors.textMuted,
              ),
              style: AppText.body,
              items: Gender.values
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
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