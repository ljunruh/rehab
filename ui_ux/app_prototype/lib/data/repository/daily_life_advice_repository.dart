import 'package:app_prototype/data/api/daily_life_advice_api.dart';
import 'package:app_prototype/data/models/api/daily_life_advice.dart';

class DailyLifeAdviceRepository {
  final DailyLifeAdviceApi _api = DailyLifeAdviceApi();

  /// Gibt Schonungstipps für die angegebenen Körperregionen zurück
  Future<List<DailyLifeAdviceCandidate>?> getAdviceByBodyParts(
    List<String> bodyParts,
  ) async {
    try {
      return await _api.fetchAdvicesByBodyParts(bodyParts);
    } catch (e) {
      print('Fehler beim Laden von Schonungstipps: $e');
      return null;
    }
  }

  /// Gibt alle Schonungstipps zurück
  Future<List<DailyLifeAdviceCandidate>?> getAllAdvice() async {
    try {
      return await _api.fetchAllAdvice();
    } catch (e) {
      print('Fehler beim Laden aller Schonungstipps: $e');
      return null;
    }
  }
}
