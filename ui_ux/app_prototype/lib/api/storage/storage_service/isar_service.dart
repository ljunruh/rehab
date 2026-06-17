import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../storage_model/isar_test.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _initIsar();
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [IsarTestSchema],
      directory: dir.path,
    );
  }

Future<void> saveUser(IsarTest user) async {
  final isar = await db;
  await isar.writeTxn(() async {
    user.id = 1; // immer dieselbe ID → überschreibt statt neu anlegen
    await isar.isarTests.put(user);
  });
}

  Future<IsarTest?> loadUser() async {
    final isar = await db;
    return await isar.isarTests.where().findFirst();
  }
}