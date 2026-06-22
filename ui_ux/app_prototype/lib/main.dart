import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/ui_state.dart';
import 'navigation/app_shell.dart';

void main() {
  runApp(const RehaApp());
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
    return ChangeNotifierProvider(
      create: (_) => UiState(),
      child: MaterialApp(
        title: 'Reha App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}
