import 'package:app_prototype/ui/exercise_widget.dart';
import 'package:flutter/material.dart';

void main() {
  // Falls du später Plugins wie Hive/Isar für lokale Daten initialisierst,
  // kommt das genau hier vor runApp() hin.
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