import 'package:isar/isar.dart';

part 'pain_log.g.dart';

@Collection()
class PainLog {
  Id id = Isar.autoIncrement;

  int level = 0;
  String region = '';
  String note = '';

  @Index()
  DateTime date = DateTime.now();

  @Index()
  String dateKey = '';

  @Index()
  String? planId;

  @Index()
  String? exerciseId;

  PainLog({
    required this.level,
    required this.region,
    this.note = '',
    required this.date,
    required this.dateKey,
    this.planId,
    this.exerciseId,
  });

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

}