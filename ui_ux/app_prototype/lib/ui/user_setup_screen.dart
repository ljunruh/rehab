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

  Gender gender = Gender.male;

  Future<void> _create() async {
    final isar = Isar.getInstance()!;

    final user = User()
      ..name = _name.text
      ..age = int.parse(_age.text)
      ..gender = gender
      ..height = double.parse(_height.text)
      ..weight = double.parse(_weight.text);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup"),
        automaticallyImplyLeading: false, // 👈 kein Zurück möglich
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 20),
            _buildGenderSelector(),
            TextField(controller: _age, decoration: const InputDecoration(labelText: "Age")),
            TextField(controller: _height, decoration: const InputDecoration(labelText: "Height")),
            TextField(controller: _weight, decoration: const InputDecoration(labelText: "Weight")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _create,
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}