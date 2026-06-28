import 'package:app_prototype/data/enum/gender.dart';
import 'package:app_prototype/data/enum/injury.dart';
import 'package:app_prototype/data/enum/skill_level.dart';
import 'package:app_prototype/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'selectable_accordion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/ui_state.dart';

class UserSetupScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const UserSetupScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  Gender gender = Gender.male;
  SkillLevel skillLevel = SkillLevel.beginner;

  List<Injury> _allInjuries = [];
  List<Injury> _filteredInjuries = [];
  final Set<String> _selectedInjuryNames = {};

  @override
  void initState() {
    super.initState();
    _allInjuries = Injury.values.where((i) => i != Injury.none).toList();
    _filteredInjuries = _allInjuries;
  }

  void _filterInjuries(String query) {
    setState(() {
      _filteredInjuries = _allInjuries
          .where((i) =>
              i.label.toLowerCase().contains(query.toLowerCase()) ||
              i.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _create() async {
    final uiState = context.read<UiState>();
    final nameVal = _name.text.trim();
    if (nameVal.isEmpty) {
      uiState.showToast("Bitte gib deinen Namen ein.");
      return;
    }

    final ageVal = int.tryParse(_age.text);
    if (ageVal == null || ageVal <= 0) {
      uiState.showToast("Bitte gib ein gültiges Alter ein.");
      return;
    }

    final heightVal = int.tryParse(_height.text);
    if (heightVal == null || heightVal <= 0) {
      uiState.showToast("Bitte gib eine gültige Größe ein.");
      return;
    }

    final weightVal = int.tryParse(_weight.text);
    if (weightVal == null || weightVal <= 0) {
      uiState.showToast("Bitte gib ein gültiges Gewicht ein.");
      return;
    }

    final isar = Isar.getInstance()!;

    final user = User(
      name: nameVal,
      gender: gender,
      age: ageVal,
      height: heightVal,
      weight: weightVal,
      injuries: _selectedInjuryNames.toList(),
      skillLevel: skillLevel,
    );

    await isar.writeTxn(() async {
      await isar.users.clear(); // sicherstellen: nur 1 user
      await isar.users.put(user);
    });

    widget.onFinished();
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Geschlecht",
            style: AppText.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: Gender.values.map((g) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppChip(
                  label: g.label,
                  active: gender == g,
                  onTap: () {
                    setState(() {
                      gender = g;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getSkillLevelDescriptions(SkillLevel level) {
    final raw = level.description;
    final parts = raw.split(RegExp(r'\n\s*\n'));
    return parts
        .map((p) => p.replaceAll(RegExp(r'^[12]\.\s*'), '').replaceAll(RegExp(r'\n\s*'), ' ').trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  Widget _buildSkillLevelSelector() {
    final descriptions = _getSkillLevelDescriptions(skillLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fitnesslevel / Aktivitätsniveau",
            style: AppText.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm * 0.5,
            runSpacing: AppSpacing.sm * 0.5,
            children: SkillLevel.values.map<Widget>((level) {
              return AppChip(
                label: level.label,
                active: skillLevel == level,
                onTap: () {
                  setState(() {
                    skillLevel = level;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            background: AppColors.offwhite,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.sage,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Kriterien für ${skillLevel.label}:",
                      style: AppText.caption.copyWith(
                        color: AppColors.sageDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...descriptions.map((desc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.sage,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            desc,
                            style: AppText.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjurySummary() {
    if (_selectedInjuryNames.isEmpty) {
      return Text(
        "Keine Einschränkungen ausgewählt.",
        style: AppText.caption.copyWith(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: _allInjuries
          .where((i) => _selectedInjuryNames.contains(i.name))
          .map(
            (i) => Chip(
              label: Text(
                i.label,
                style: AppText.caption.copyWith(color: AppColors.sageDeep),
              ),
              backgroundColor: AppColors.sageLight,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              deleteIconColor: AppColors.sageDeep,
              onDeleted: () {
                setState(() {
                  _selectedInjuryNames.remove(i.name);
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildInjuriesSection() {
    return SelectableAccordion<Injury>(
      title: "Bestehende Verletzungen / Beschwerden",
      summary: _buildInjurySummary(),
      items: _allInjuries,
      filteredItems: _filteredInjuries,
      onSearch: _filterInjuries,
      getId: (injury) => injury.name,
      getTitle: (injury) => injury.label,
      getSubtitle: (injury) => injury.description,
      selectedIds: _selectedInjuryNames,
      onSelectionChanged: (name, selected) {
        setState(() {
          if (selected) {
            _selectedInjuryNames.add(name);
          } else {
            _selectedInjuryNames.remove(name);
          }
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppText.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppText.body.copyWith(color: AppColors.textSecondary),
          floatingLabelStyle: AppText.body.copyWith(color: AppColors.sage, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.base + 8,
            AppSpacing.screenH,
            AppSpacing.scrollBottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text(
                  "Setup",
                  style: AppText.screenTitle,
                ),
              ),
              _buildTextField(
                controller: _name,
                label: "Name",
              ),
              _buildGenderSelector(),
              _buildTextField(
                controller: _age,
                label: "Alter",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _height,
                label: "Größe (cm)",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _weight,
                label: "Gewicht (kg)",
                keyboardType: TextInputType.number,
              ),
              _buildSkillLevelSelector(),
              const SizedBox(height: AppSpacing.sm),
              _buildInjuriesSection(),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: "Erstellen",
                onPressed: _create,
              ),
            ],
          ),
        ),
      ),
    );
  }
}