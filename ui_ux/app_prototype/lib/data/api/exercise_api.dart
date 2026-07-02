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

    final List<String> activeFilters = [];
    final List<String> valuesBlocks = [];

    // Difficulty filter
    valuesBlocks.add('VALUES ?difficulty { $difficulty }');
    activeFilters.add('?exercise rehab:hasDifficultyLevel ?difficulty .');

    // BodyPart filter
    if (bodyPart != BodyPart.none) {
      String bodyPartName = bodyPart.name[0].toUpperCase() + bodyPart.name.substring(1);
      activeFilters.add('?exercise rehab:rehabilitates rehab:$bodyPartName .');
    }

    // Goal filter
    if (goal != Goal.none) {
      String goalName = goal.name[0].toUpperCase() + goal.name.substring(1);
      activeFilters.add('?exercise (rehab:improves|rehab:hasTrainingEffect) rehab:$goalName .');
    }

    // Injury filter
    final filteredInjuries = injury.where((i) => i != Injury.none).toList();
    if (filteredInjuries.isNotEmpty) {
      final injuryURIs = filteredInjuries.map((i) {
        String name = i.name[0].toUpperCase() + i.name.substring(1);
        return 'rehab:$name';
      }).join(' ');

      valuesBlocks.add('VALUES ?selectedInjury { $injuryURIs }');

      activeFilters.add('''
    FILTER NOT EXISTS { ?selectedInjury rehab:excludesExercise ?exercise }
    FILTER NOT EXISTS { ?exercise rehab:hasContraindication ?selectedInjury }
    FILTER NOT EXISTS { ?exercise rehab:hasContraindication/rehab:forCondition ?selectedInjury }
      ''');
    }

    final query = '''
SELECT ?exercise ?label ?comment WHERE {
    ${valuesBlocks.join('\n    ')}

    ?exercise a/rdfs:subClassOf* rehab:Exercise .

    ${activeFilters.join('\n    ')}

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

  String _getDifficulties(SkillLevel skillLevel, int painLevel) {
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
