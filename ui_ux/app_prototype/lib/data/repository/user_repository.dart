import 'package:app_prototype/data/api/user_api.dart';
import 'package:app_prototype/data/model/condition.dart';
import 'package:app_prototype/data/model/user.dart';
import 'package:app_prototype/data/service/user_service.dart';

class UserRepository {
  final ConditionApi conditionApi;
  final UserService service;

  UserRepository({
    required this.conditionApi,
    required this.service,
  });

  Future<User?> getUser() => service.getUser();

  Future<void> saveUser(User user) => service.saveUser(user);

  Future<void> deleteUser() => service.deleteUser();

  Future<List<Condition>> getConditions() {
    return conditionApi.fetchConditions();
  }
}