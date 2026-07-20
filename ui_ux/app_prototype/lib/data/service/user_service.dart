import 'package:app_prototype/data/api/user_api.dart'; // NEU
import 'package:app_prototype/data/models/models.dart';
import 'package:isar/isar.dart';

class UserService {
  final Isar isar;
  final UserApi _userApi = UserApi(); // NEU: Instanz der API

  UserService(this.isar);

  Future<User?> getUser() async => isar.users.where().findFirst();

  Future<void> saveUser(User user) async {
    // 1. Lokal in Isar speichern
    await isar.writeTxn(() async {
      await isar.users.clear();
      await isar.users.put(user);
    });

    // 2. NEU: Synchronisation mit Fuseki-Backend (Akzeptanzkriterium 1)
    await _userApi.updateUserProfile(user);
  }

  // Löscht alle App-Daten!
  Future<void> deleteUser() async {
    // 1. Lokal alle Isar-Daten löschen
    await isar.writeTxn(() async {
      await isar.clear();
    });

    // 2. NEU: Aus dem Fuseki-Backend über die API löschen (Akzeptanzkriterium 3)
    await _userApi.deleteUserProfile();
  }
}