import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/injury.dart';
import 'package:app_prototype/data/enum/skill_level.dart';

import '../models/graph/exercise.dart';

class ExerciseApi extends CoreApi {
  /*
  Lese alle Exercises aus und gebe Exercise, Label und Description zurück.
  */
  Future<List<Exercise>> fetchAllExercises() async {
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

  /*
  Lese alle für Planerstellung passenden Exercises.
  */
  Future<List<Exercise>> fetchFilteredExercises(BodyPart bodyPart, Goal goal, int painLevel, List<Injury> injury, SkillLevel skillLevel) async {
    String difficulty = _getDifficulties(skillLevel, painLevel);

    final query =
    '''
SELECT ?exercise ?label ?comment ?difficulty
WHERE {
    VALUES ?difficulty { $difficulty }

    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty .

    OPTIONAL { ?exercise rdfs:label ?label }
    OPTIONAL { ?exercise rdfs:comment ?comment }
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

  _getDifficulties(SkillLevel skillLevel, int painLevel) {
    if (painLevel > 3) {
      return "rehab:Beginner";
    }

    switch (skillLevel) {
      case SkillLevel.beginner:
        return "rehab:Beginner";
      case SkillLevel.intermediate:
        return "rehab:Beginner rehab:Intermediate";
      case SkillLevel.advanced:
        return "rehab:Beginner rehab:Intermediate rehab:Advanced";
    }
  }
}
