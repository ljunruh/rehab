import 'package:app_prototype/model/enum/gender.dart';
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  late int age;
  @enumerated
  late Gender gender;
  late double height;
  late double weight;

  List<String> conditions = [];
}