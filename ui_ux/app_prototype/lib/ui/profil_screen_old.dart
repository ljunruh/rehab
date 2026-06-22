import 'package:app_prototype/data/api/user_api.dart';
import 'package:app_prototype/data/model/condition.dart';
import 'package:app_prototype/data/model/enum/gender.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../data/model/user.dart';
import '../features/profile/setup/profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  late Isar isar;
  final ConditionApi _conditionApi = ConditionApi();
  List<Condition> _allConditions = [];
  bool _isLoadingConditions = true;

  @override
  void initState() {
    super.initState();
    isar = Isar.getInstance()!;
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUser();
    await _loadConditions();
  }

  Future<void> _loadUser() async {
    final result = await isar.users.where().findFirst();

    setState(() {
      user = result;
    });
  }

  Future<void> _loadConditions() async {
    try {
      final conditions = await _conditionApi.fetchConditions();
      setState(() {
        _allConditions = conditions;
        _isLoadingConditions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingConditions = false;
      });
    }
  }

  Future<void> _deleteUser() async {
    await isar.writeTxn(() async {
      await isar.users.clear();
    });

    if (!mounted) return;

    // 👉 Setup erzwingen + kompletter Stack reset
    /*Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserSetupScreen()),
      (route) => false,
    );*/
  }

  Widget _buildConditionsSection() {
    if (user == null) return const SizedBox.shrink();

    if (_isLoadingConditions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final userConditions = _allConditions
        .where((c) => user!.conditions.contains(c.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Diagnosen / Einschränkungen:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (userConditions.isEmpty)
          const Text(
            "Keine Einschränkungen angegeben.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: userConditions.map((c) {
              return Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      if (c.comment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.comment,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${user!.name}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Age: ${user!.age}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Gender: ${user!.gender.label}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Height: ${user!.height} cm", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Weight: ${user!.weight} kg", style: const TextStyle(fontSize: 16)),
              
              _buildConditionsSection(),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _deleteUser,
                icon: const Icon(Icons.delete),
                label: const Text("delete Profil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}