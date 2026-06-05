import 'package:flutter/material.dart';
import '../model/exercise.dart';
import '../api/exercise_api.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseApi _repository = ExerciseApi();
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    // Beim Starten des Screens laden wir die Daten einmalig
    _exercisesFuture = _repository.fetchExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehab App'),
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          // 1. Lade-Zustand
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Fehler-Zustand
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          // 3. Keine Daten gefunden
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Übungen gefunden.'));
          }

          // 4. Daten erfolgreich geladen -> Liste anzeigen
          final exercises = snapshot.data!;
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text(exercise.label),
                  subtitle: Text('Beansprucht: ${exercise.bodyPartLabel}'),
                  trailing: Text(
                    exercise.id.split('/').last,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}