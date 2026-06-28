import 'package:app_prototype/data/models/models.dart';
import 'package:app_prototype/data/service/user_service.dart';

class UserRepository {
  final UserService service;

  UserRepository({
    required this.service,
  });

  Future<User?> getUser() => service.getUser();

  Future<void> saveUser(User user) => service.saveUser(user);

  Future<void> deleteUser() => service.deleteUser();
}