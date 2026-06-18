import 'dart:io';
import 'package:app_prototype/model/user.dart';
import 'package:app_prototype/ui/exercise_widget.dart';
import 'package:app_prototype/ui/home_screen.dart';
import 'package:app_prototype/ui/user_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_prototype/model/exercise.dart';

void main() async {
  // Stellen Sie sicher, dass Flutter-Bindings initialisiert sind
  WidgetsFlutterBinding.ensureInitialized();

  // Zielverzeichnis: api/data_storage
  String dbPath = '/home/daniel/Desktop/Uni/Bachelorprojekt/Repo/rehab/api/data_storage';

  // Robustheits-Check: Falls der absolute Pfad nicht existiert (z. B. auf einem anderen System),
  // nutzen wir einen relativen Pfad oder den Standard-Anwendungsordner.
  final absoluteDir = Directory(dbPath);
  if (!await absoluteDir.exists()) {
    final relativeDir = Directory('../../api/data_storage');
    if (await relativeDir.exists()) {
      dbPath = relativeDir.path;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = appDir.path;
    }
  }

  final isar = await Isar.open(
    [UserSchema],
    directory: dbPath,
  );

  final userExists = await isar.users.where().findFirst() != null;

  runApp(RehabApp(userExists: userExists));
}

class RehabApp extends StatelessWidget {
  final bool userExists;

  const RehabApp({
    super.key,
    required this.userExists,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: userExists
          ? const HomeScreen()
          : const UserSetupScreen(),
    );
  }
}