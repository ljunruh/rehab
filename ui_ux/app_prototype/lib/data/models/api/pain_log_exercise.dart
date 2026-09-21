import 'package:app_prototype/data/enum/body_part.dart';
import 'package:isar/isar.dart';

part 'pain_log_exercise.g.dart';

@Collection()
class PainLogExercise {
  Id id = Isar.autoIncrement;

  // Nach Name gespeichert (nicht Index), damit eine Umsortierung des Enums
  // keine gespeicherten Logs verfälscht – siehe Plan.region.
  @Enumerated(EnumType.name)
  @Index()
  BodyPart region;

  int level = 0;

  @Index()
  DateTime date = DateTime.now();

  @Index()
  String dateKey = '';

  @Index()
  String? planId;

  @Index()
  String? exerciseId;

  PainLogExercise({
    required this.level,
    required this.region,
    required this.date,
    required this.dateKey,
    this.planId,
    this.exerciseId
  });

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

}