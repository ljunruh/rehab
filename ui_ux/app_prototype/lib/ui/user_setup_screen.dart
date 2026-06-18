import 'package:app_prototype/api/user_api.dart';
import 'package:app_prototype/model/condition.dart';
import 'package:app_prototype/model/enum/gender.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../model/user.dart';
import 'home_screen.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

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

  final UserApi _userApi = UserApi();
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
      final conditions = await _userApi.fetchConditions();
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

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
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

  Widget _buildConditionsSection() {
    if (_isLoadingConditions) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Einschränkungen / Bedingungen",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Fehler beim Laden: $_conditionsError",
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bestehende Einschränkungen / Bedingungen",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedConditionIds.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _allConditions
                .where((c) => _selectedConditionIds.contains(c.id))
                .map((c) => Chip(
                      label: Text(c.label),
                      onDeleted: () {
                        setState(() {
                          _selectedConditionIds.remove(c.id);
                        });
                      },
                    ))
                .toList(),
          )
        else
          const Text(
            "Keine Einschränkungen ausgewählt.",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: "Suchen...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterConditions('');
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _filterConditions,
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _filteredConditions.isEmpty
              ? const Center(child: Text("Keine passenden Optionen gefunden"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredConditions.length,
                  itemBuilder: (context, index) {
                    final condition = _filteredConditions[index];
                    final isSelected = _selectedConditionIds.contains(condition.id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(condition.label),
                      subtitle: condition.comment.isNotEmpty
                          ? Text(
                              condition.comment,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedConditionIds.add(condition.id);
                          } else {
                            _selectedConditionIds.remove(condition.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
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