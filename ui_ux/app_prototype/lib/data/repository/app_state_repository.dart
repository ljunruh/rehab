import 'package:app_prototype/data/models/api/app_state.dart';
import 'package:isar/isar.dart';

class AppStateRepository {
  final Isar isar;

  AppStateRepository(this.isar);

  /// AppState laden (Verwaltung des Reset-Stempels)
  Future<AppState?> getAppState() async {
    return isar.appStates.get(1);
  }

  /// AppState speichern/aktualisieren
  Future<void> saveAppState(AppState state) async {
    await isar.writeTxn(() async {
      await isar.appStates.put(state);
    });
  }
}