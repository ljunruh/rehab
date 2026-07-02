import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';

import '../models/graph/exercise.dart';

class ExerciseApi extends CoreApi {
  /*
  Lese alle Exercises aus und gebe Exercise, Label und Description zurück.
  TODO[API]: Ist veraltet und muss angepasst werden durch Injury.
  Wir später bei Planerstellung und -empfehlung genutzt
  */
  Future<List<Exercise>> fetchExercises() async {
    const query =
    '''
      SELECT ?exercise ?label ?comment WHERE {
	?exercise a/rdfs:subClassOf* rehab:Exercise .
  	OPTIONAL { ?exercise rdfs:label ?label . }
	OPTIONAL { ?exercise rdfs:comment ?comment . }
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
