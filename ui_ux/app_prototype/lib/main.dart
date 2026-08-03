import 'package:app_prototype/data/api/exercise_api.dart';
import 'package:app_prototype/data/models/api/app_state.dart';
import 'package:app_prototype/data/models/api/plan.dart';
import 'package:app_prototype/data/models/api/pain_log.dart';
import 'package:app_prototype/data/models/api/plan_log_exercise.dart';
import 'package:app_prototype/data/models/models.dart';
import 'package:app_prototype/data/provider/calender_provider.dart';
import 'package:app_prototype/data/provider/exercise_provider.dart';
import 'package:app_prototype/data/provider/pain_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/pain_log_provider.dart';
import 'package:app_prototype/data/provider/plan_log_exercise_provider.dart';
import 'package:app_prototype/data/provider/plan_provider.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:app_prototype/data/repository/app_state_repository.dart';
import 'package:app_prototype/data/repository/exercise_repository.dart';
import 'package:app_prototype/data/repository/pain_log_exercise_repository.dart';
import 'package:app_prototype/data/repository/pain_log_repository.dart';
import 'package:app_prototype/data/repository/plan_log_exercise_repository.dart';
import 'package:app_prototype/data/repository/plan_repository.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/api/pain_log_exercise.dart';
import 'features/intro/intro_screen.dart';
import 'navigation/app_shell.dart';
import 'state/ui_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Diese Zeile schaltet den Linux/Windows Support für den video_player frei
  fvp.registerWith(options: {'platforms': ['windows', 'macos', 'linux']});

  final appDir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      AppStateSchema,
      UserSchema,
      PlanSchema,
      PainLogSchema,
      PainLogExerciseSchema,
      PlanLogExerciseSchema,
    ],
    directory: appDir.path
  );

  final appStateRepository = AppStateRepository(isar);
  final userRepository = UserRepository(isar);
  final exerciseRepository = ExerciseRepository(api: ExerciseApi(), userRepository: userRepository);
  final planRepository = PlanRepository(isar);
  final painLogRepository = PainLogRepository(isar);
  final painLogExerciseRepository = PainLogExerciseRepository(isar);
  final planLogExerciseRepository = PlanLogExerciseRepository(isar);

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiState()),
        ChangeNotifierProvider(create: (_) => UserProvider(userRepository)..init()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider(exerciseRepository)),
        ChangeNotifierProvider(create: (_) => PlanProvider(planRepo: planRepository, appStateRepo: appStateRepository)),
        ChangeNotifierProvider(create: (_) => PainLogProvider(painLogRepository)),
        ChangeNotifierProvider(create: (_) => PainLogExerciseProvider(painLogExerciseRepository)),
        ChangeNotifierProvider(create: (_) => PlanLogExerciseProvider(planLogExerciseRepository)),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
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
      home: const _RootGate(),
    );
  }
}

/// Zeigt beim Start das animierte Intro und blendet danach sanft zur App.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _ready
          ? AppShell(key: const ValueKey('app'))
          : IntroScreen(
              key: const ValueKey('intro'),
              onDone: () => setState(() => _ready = true),
            ),
    );
  }
}
