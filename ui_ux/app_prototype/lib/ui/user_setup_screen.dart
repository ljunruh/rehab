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

  String gender = "Male";

  Future<void> _save() async {
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
          "Geschlecht",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _genderOption("Male"),
            _genderOption("Female"),
            _genderOption("Divers"),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: gender,
          onChanged: (newValue) {
            setState(() {
              gender = newValue!;
            });
          },
        ),
        Text(value),
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
            TextField(controller: _age, decoration: const InputDecoration(labelText: "Alter")),
            TextField(controller: _height, decoration: const InputDecoration(labelText: "Größe")),
            TextField(controller: _weight, decoration: const InputDecoration(labelText: "Gewicht")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              child: const Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }
}