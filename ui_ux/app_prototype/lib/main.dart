import 'package:app_prototype/data/api/user_api.dart';
import 'package:app_prototype/data/model/user.dart';
import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:app_prototype/data/repository/user_repository.dart';
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

  final userRepository = UserRepository(
    conditionApi: ConditionApi(),
    service: UserService(isar),
  );

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiState()),
        ChangeNotifierProvider(create: (_) => UserProvider(userRepository)),
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
