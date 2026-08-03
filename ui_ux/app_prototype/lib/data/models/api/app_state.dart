import 'package:isar/isar.dart';

part 'app_state.g.dart';

@Collection()
class AppState {
  Id id = 1;

  /// Der Stempel für den nächsten anstehenden Reset (Montag 00:00 Uhr)
  DateTime nextResetDate;

  AppState({
    required this.nextResetDate,
  });
}