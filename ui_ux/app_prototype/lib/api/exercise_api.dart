import 'dart:convert';

import 'package:app_prototype/api/core_api.dart';

import '../model/exercise.dart';

class ExerciseApi extends CoreApi {
  Future<List<Exercise>> fetchExercises() async {
    const query = '''
      SELECT ?uebung ?uebungLabel ?bodyPartLabel WHERE {
        ?uebung a v:Activity ;
                rdfs:label ?uebungLabel ;
                v:involvesBodyPart ?bodyPart .
        ?bodyPart rdfs:label ?bodyPartLabel .
        FILTER (lang(?uebungLabel) = "de")
      }
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        return bindings.map((json) => Exercise.fromSparqlJson(json)).toList();
      } else {
        throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }
}