import 'package:flutter/material.dart';
import '../storage_model/isar_test.dart';
import '../storage_service/isar_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _service = IsarService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _fitnessController = TextEditingController();
  final _injuryController = TextEditingController();
  String _status = '';

Future<void> _save() async {
  final user = IsarTest()
    ..id = 1
    ..name = _nameController.text
    ..age = int.tryParse(_ageController.text)
    ..fitnessLevel = _fitnessController.text
    ..injury = _injuryController.text;

  await _service.saveUser(user);
  setState(() => _status = 'Gespeichert!');
}

  Future<void> _load() async {
    final user = await _service.loadUser();
    if (user != null) {
      _nameController.text = user.name ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _fitnessController.text = user.fitnessLevel ?? '';
      _injuryController.text = user.injury ?? '';
      setState(() => _status = 'Geladen!');
    } else {
      setState(() => _status = 'Kein User gefunden.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profil Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _ageController, decoration: const InputDecoration(labelText: 'Alter'), keyboardType: TextInputType.number),
            TextField(controller: _fitnessController, decoration: const InputDecoration(labelText: 'Fitness Level')),
            TextField(controller: _injuryController, decoration: const InputDecoration(labelText: 'Verletzung')),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(onPressed: _save, child: const Text('Speichern')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _load, child: const Text('Laden')),
              ],
            ),
            Text(_status),
          ],
        ),
      ),
    );
  }
}