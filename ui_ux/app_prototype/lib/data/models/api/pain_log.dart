import 'package:app_prototype/data/enum/body_part.dart';
import 'package:isar/isar.dart';

part 'pain_log.g.dart';

@Collection()
class PainLog {
  Id id;

  // Nach Name gespeichert (nicht Index), damit eine Umsortierung des Enums
  // keine gespeicherten Logs verfälscht – siehe Plan.region.
  @Enumerated(EnumType.name)
  @Index()
  BodyPart region;
  int level = 0;
  String note = '';

  @Index()
  DateTime date = DateTime.now();

  @Index()
  String dateKey = '';

  PainLog({
    this.id = Isar.autoIncrement,
    required this.level,
    required this.region,
    this.note = '',
    required this.date,
    required this.dateKey,
  });

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

}