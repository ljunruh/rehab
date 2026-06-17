import 'package:isar/isar.dart';

part 'isar_test.g.dart';

@collection
class IsarTest {
  Id id = Isar.autoIncrement;

  String? name;
  int? age;
  String? fitnessLevel; 
  String? injury;
}