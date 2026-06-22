import 'package:app_prototype/data/api/user_api.dart';
import 'package:app_prototype/data/model/condition.dart';
import 'package:app_prototype/data/model/enum/gender.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'selectable_accordion.dart';
import '../../../data/model/user.dart';

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
  final _searchController = TextEditingController();

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
    final isar = Isar.getInstance()!;

    final user = User()
      ..name = _name.text
      ..age = int.parse(_age.text)
      ..gender = gender
      ..height = double.parse(_height.text)
      ..weight = double.parse(_weight.text)
      ..conditions = _selectedConditionIds.toList();

    await isar.writeTxn(() async {
      await isar.users.clear(); // sicherstellen: nur 1 user
      await isar.users.put(user);
    });

    widget.onFinished();
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _genderOption(Gender.male),
            _genderOption(Gender.female),
            _genderOption(Gender.diverse),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(Gender value) {
    return Row(
      children: [
        Radio<Gender>(
          value: value,
          groupValue: gender,
          onChanged: (newValue) {
            setState(() {
              gender = newValue!;
            });
          },
        ),
        Text(value.label),
      ],
    );
  }

  Widget _buildConditionSummary() {
    if (_selectedConditionIds.isEmpty) {
      return const Text(
        "Keine Einschränkungen ausgewählt.",
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _allConditions
          .where((c) => _selectedConditionIds.contains(c.id))
          .map(
            (c) => Chip(
          label: Text(c.label),
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
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Einschränkungen / Bedingungen",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_conditionsError.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Einschränkungen / Bedingungen",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Fehler beim Laden: $_conditionsError",
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    return SelectableAccordion<Condition>(
      title: "Bestehende Einschränkungen / Bedingungen",

      // <-- HIER die Summary-Methode verwenden
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup"),
        automaticallyImplyLeading: false, // 👈 kein Zurück möglich
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 20),
              _buildGenderSelector(),
              const SizedBox(height: 20),
              TextField(controller: _age, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
              TextField(controller: _height, decoration: const InputDecoration(labelText: "Height (cm)"), keyboardType: TextInputType.number),
              TextField(controller: _weight, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              _buildConditionsSection(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _create,
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}