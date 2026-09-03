import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/models/api/daily_life_advice.dart';

class DailyLifeAdviceApi extends CoreApi {
  /// Abfrage aller Schonungstipps für die aktiven Körperregionen.
  Future<List<DailyLifeAdviceCandidate>> fetchAdvicesByBodyParts(
    List<String> bodyParts,
  ) async {
    if (bodyParts.isEmpty) {
      return [];
    }

    final bodyPartFilters = bodyParts.map((part) => 'rehab:$part').join(' ');

    final query = '''
SELECT ?adviceId ?bodyPartLabel ?category ?advice
WHERE {
  VALUES ?bodyPart { $bodyPartFilters }

  ?adviceResource a rehab:Schonungshinweis ;
                  rehab:belongsToBodyPart ?bodyPart ;
                  rehab:hasDailyLifeCategory ?categoryResource ;
                  rehab:hasDailyLifeAdvice ?advice .

  BIND(REPLACE(STR(?adviceResource), "^.*[#/]", "") AS ?adviceId)
  BIND(REPLACE(STR(?bodyPart), "^.*[#/]", "") AS ?bodyPartLabel)
  BIND(REPLACE(STR(?categoryResource), "^.*[#/]", "") AS ?category)
}
ORDER BY ?bodyPartLabel ?category ?advice
''';

    final response = await postQuery(query);
    if (response.statusCode != 200) {
      throw Exception(
        'Fehler beim Laden der Schonungstipps: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> bindings = data['results']['bindings'] as List<dynamic>;

    return bindings
        .cast<Map<String, dynamic>>()
        .map(DailyLifeAdviceCandidate.fromSparqlJson)
        .where((advice) => advice.id.isNotEmpty && advice.advice.isNotEmpty)
        .toList();
  }

  /// Abfrage aller Schonungstipps (ohne Filter)
  Future<List<DailyLifeAdviceCandidate>> fetchAllAdvice() async {
    final query = '''
SELECT ?adviceId ?bodyPartLabel ?category ?advice
WHERE {
  ?adviceResource a rehab:Schonungshinweis ;
                  rehab:belongsToBodyPart ?bodyPart ;
                  rehab:hasDailyLifeCategory ?categoryResource ;
                  rehab:hasDailyLifeAdvice ?advice .

  BIND(REPLACE(STR(?adviceResource), "^.*[#/]", "") AS ?adviceId)
  BIND(REPLACE(STR(?bodyPart), "^.*[#/]", "") AS ?bodyPartLabel)
  BIND(REPLACE(STR(?categoryResource), "^.*[#/]", "") AS ?category)
}
ORDER BY ?bodyPartLabel ?category ?advice
''';

    final response = await postQuery(query);
    if (response.statusCode != 200) {
      throw Exception(
        'Fehler beim Laden der Schonungstipps: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> bindings = data['results']['bindings'] as List<dynamic>;

    return bindings
        .cast<Map<String, dynamic>>()
        .map(DailyLifeAdviceCandidate.fromSparqlJson)
        .where((advice) => advice.id.isNotEmpty && advice.advice.isNotEmpty)
        .toList();
  }
}
