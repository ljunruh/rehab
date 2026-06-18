import 'package:app_prototype/ui/profil_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Willkommen 👋",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}