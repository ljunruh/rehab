import 'package:app_prototype/data/api/user_api.dart';
import 'package:app_prototype/data/model/condition.dart';
import 'package:app_prototype/data/model/enum/gender.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'selectable_accordion.dart';
import '../../../data/model/user.dart';
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
  final _email = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  Gender gender = Gender.male;

  final ConditionApi _conditionApi = ConditionApi();
  List<Condition> _allConditions = [];
  List<Condition> _filteredConditions = [];
  final Set<String> _selectedConditionIds = {};
  bool _isLoadingConditions = true;
  String _conditionsError = '';

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    try {
      final conditions = await _conditionApi.fetchConditions();
      setState(() {
        _allConditions = conditions;
        _filteredConditions = conditions;
        _isLoadingConditions = false;
      });
    } catch (e) {
      setState(() {
        _conditionsError = e.toString();
        _isLoadingConditions = false;
      });
    }
  }

  void _filterConditions(String query) {
    setState(() {
      _filteredConditions = _allConditions
          .where((c) =>
              c.label.toLowerCase().contains(query.toLowerCase()) ||
              c.comment.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _create() async {
    //TODO[API]: Allgemein Validator prüfen
    final uiState = context.read<UiState>();
    final nameVal = _name.text.trim();
    final emailVal = _email.text.trim();
    if (nameVal.isEmpty) {
      uiState.showToast("Bitte gib deinen Namen ein.");
      return;
    }

    //TODO[API]: Brauch einen Email Validator
    if (emailVal.isEmpty) {
      uiState.showToast("Bitte gib deine Email ein.");
      return;
    }

    final ageVal = int.tryParse(_age.text);
    if (ageVal == null || ageVal <= 0) {
      uiState.showToast("Bitte gib ein gültiges Alter ein.");
      return;
    }

    final heightVal = double.tryParse(_height.text);
    if (heightVal == null || heightVal <= 0) {
      uiState.showToast("Bitte gib eine gültige Größe ein.");
      return;
    }

    final weightVal = double.tryParse(_weight.text);
    if (weightVal == null || weightVal <= 0) {
      uiState.showToast("Bitte gib ein gültiges Gewicht ein.");
      return;
    }

    final isar = Isar.getInstance()!;

    final user = User()
      ..name = nameVal
      ..email = emailVal
      ..age = ageVal
      ..gender = gender
      ..height = heightVal
      ..weight = weightVal
      ..conditions = _selectedConditionIds.toList();

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

  Widget _buildConditionSummary() {
    if (_selectedConditionIds.isEmpty) {
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
      children: _allConditions
          .where((c) => _selectedConditionIds.contains(c.id))
          .map(
            (c) => Chip(
              label: Text(
                c.label,
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
                  _selectedConditionIds.remove(c.id);
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildConditionsSection() {
    if (_isLoadingConditions) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Einschränkungen / Bedingungen",
              style: AppText.sectionHeader,
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
              ),
            ),
          ],
        ),
      );
    }

    if (_conditionsError.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Einschränkungen / Bedingungen",
              style: AppText.sectionHeader,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Fehler beim Laden: $_conditionsError",
              style: AppText.body.copyWith(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return SelectableAccordion<Condition>(
      title: "Einschränkungen / Bedingungen",
      summary: _buildConditionSummary(),
      items: _allConditions,
      filteredItems: _filteredConditions,
      onSearch: _filterConditions,
      getId: (condition) => condition.id,
      getTitle: (condition) => condition.label,
      getSubtitle: (condition) => condition.comment,
      selectedIds: _selectedConditionIds,
      onSelectionChanged: (id, selected) {
        setState(() {
          if (selected) {
            _selectedConditionIds.add(id);
          } else {
            _selectedConditionIds.remove(id);
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
                  "Profil erstellen",
                  style: AppText.screenTitle,
                ),
              ),
              _buildTextField(
                controller: _name,
                label: "Name",
              ),
              _buildTextField(
                controller: _email,
                label: "E-Mail",
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
              const SizedBox(height: AppSpacing.sm),
              _buildConditionsSection(),
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