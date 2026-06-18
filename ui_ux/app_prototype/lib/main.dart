import 'dart:io';
import 'package:app_prototype/ui/exercise_widget.dart';
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

  // Isar Instanz mit dem Exercise-Schema im Zielverzeichnis öffnen
  // ignore: unused_local_variable
  final isar = await Isar.open(
    [ExerciseSchema],
    directory: dbPath,
  );

  runApp(const RehabApp());
}

class RehabApp extends StatelessWidget {
  const RehabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRehab',
      debugShowCheckedModeBanner: false, // Entfernt das "Debug"-Banner oben rechts

      // Modernes Theme-Setup (Material 3)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        // Schickes Design für die App-Bar definieren
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),

      // Startbildschirm der App
      home: const ExerciseListScreen(),
    );
  }
}