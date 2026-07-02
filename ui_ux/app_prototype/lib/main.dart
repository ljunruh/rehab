import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/models/models.dart';
import 'package:app_prototype/data/provider/exercise_provider.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:app_prototype/data/service/exercise_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/service/user_service.dart';
import 'navigation/app_shell.dart';
import 'state/ui_state.dart';

void main() async {
  // Stellen Sie sicher, dass Flutter-Bindings initialisiert sind
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [UserSchema],
    directory: appDir.path,
  );

  final userRepository = UserRepository(service: UserService(isar));
  final exerciseRepository = ExerciseRepository(service: ExerciseService(isar), api: ExerciseApi());



  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiState()),
        ChangeNotifierProvider(create: (_) => UserProvider(userRepository)..init()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider(exerciseRepository)),
      ],
      child: RehaApp()));
}

/// Wurzel der Reha App (UI/UX-Projekt).
///
/// Stellt den [UiState] bereit (Provider) und das App-Theme. Es gibt bewusst
/// keine Backend-/Lade-Logik: Die Demo-Daten liegen direkt im UiState, damit
/// die Oberfläche sofort sichtbar und durchklickbar ist.
class RehaApp extends StatelessWidget {
  const RehaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reha App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(),
    );
  }
}
