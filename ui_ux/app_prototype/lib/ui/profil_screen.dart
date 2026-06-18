import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../model/user.dart';
import 'user_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final isar = Isar.getInstance()!;
    final result = await isar.users.where().findFirst();

    setState(() {
      user = result;
    });
  }

  Future<void> _deleteUser() async {
    final isar = Isar.getInstance()!;

    await isar.writeTxn(() async {
      await isar.users.clear();
    });

    if (!mounted) return;

    // 👉 Setup erzwingen + kompletter Stack reset
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserSetupScreen()),
          (route) => false,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user!.name}"),
            Text("Alter: ${user!.age}"),
            Text("Geschlecht: ${user!.gender}"),
            Text("Größe: ${user!.height} cm"),
            Text("Gewicht: ${user!.weight} kg"),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _deleteUser,
              icon: const Icon(Icons.delete),
              label: const Text("Profil löschen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}