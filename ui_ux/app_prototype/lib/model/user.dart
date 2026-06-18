import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  late int age;
  late String gender;
  late double height;
  late double weight;
}