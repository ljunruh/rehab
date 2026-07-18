import 'package:app_prototype/data/models/models.dart';
import 'package:isar/isar.dart';

//TODO[API]: Prüfen ob Nutzung von Service ohne Repo ausreicht
class UserRepository {
  final Isar isar;

  UserRepository(this.isar);

  Future<User?> getUser() async => isar.users.where().findFirst();

  Future<void> saveUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.clear();
      await isar.users.put(user);
    });
  }

  // Löscht alle App-Daten!
  Future<void> deleteUser() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}