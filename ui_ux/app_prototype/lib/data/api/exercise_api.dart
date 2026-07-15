import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/skill_level.dart';

import '../models/graph/exercise.dart';

class ExerciseApi extends CoreApi {
  /**
   * Planerstellung: Gib alle Exercises zurück die die Problemzonen nicht beeinflussen.
   */
  Future<List<Exercise>> fetchAllExercisesExcludeContraindications(List<String> contraindications) async {
    String injuries = contraindications.map((e) => "rehab:$e").join(" ");

    final query =
    '''
SELECT
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?duration
    ?instruction
    # Verpackt alle Values der Property in einem Value
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)
WHERE {

    # Filter für alle Übungen, die diese Object Properties besitzen müssen.
    # Übungen ohne diese Properties führen in der App zu unvollständigen Daten.
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contraindication a rehab:Contraindication .
    ?trainingsEffect a rehab:TrainingsEffect .
    ?bodyPart a rehab:BodyPart .

    # Entfernt Übungen, deren Kontraindikationen mit den
    # vom Benutzer angegebenen Einschränkungen kollidieren.
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication { $injuries }
        ?exercise rehab:hasContraindication ?selectedContraindication
    }

    # Pflichtfelder
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction ;
              rehab:hasDuration ?duration ;
              rdfs:label ?exerciseLabel .

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}
GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        try {
          return bindings.map((json) {
            try {
              return Exercise.fromSparqlJson(json);
            } catch (innerError, stackTrace) {
              print('--- PARSE ERROR IN fetchAllExercises ---');
              print('JSON: $json');
              print('Error: $innerError');
              print('Stacktrace:\n$stackTrace');
              rethrow;
            }
          }).toList();
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }

  /**
   * Planempfehlung: Gib alle Exercises zurück die die Problemzonen nicht beeinflussen gefilter über Körperregion, Traingsziel und Schwierigkeitslevel.
   */
  Future<List<Exercise>> fetchExercisesByParamsExcludeContraindications(BodyPart bodyPart, Goal goal, List<String> contraindications, SkillLevel skillLevel) async {
    String difficulty = _getDifficulties(skillLevel);
    String goals = "rehab:${goal.labelEN}"; //Kann später zu mehr Goals erweitert werden
    String bodyParts = "rehab:${bodyPart.labelEN}"; //Kann später zu mehr BodyParts erweitert werden
    String injuries = contraindications.map((e) => "rehab:$e").join(" ");

    final query = '''
SELECT
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?duration
    ?instruction
    # Verpackt alle Values der Property in einem Value
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)

WHERE {
    # Filterparameter (werden zur Laufzeit übergeben)
    # Trainingslevel
    VALUES ?difficulty { $difficulty }
    # Gewünschte Trainingseffekte
    VALUES ?trainingsEffect { $goals }
    # Gewünschte Körperbereiche
    VALUES ?bodyPart { $bodyParts }

    # Übungen müssen alle benötigten Object Properties besitzen
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .
    ?contraindication a rehab:Contraindication .
    ?trainingsEffect a rehab:TrainingsEffect .
    ?bodyPart a rehab:BodyPart .

    # Entfernt Übungen, die mit den angegebenen Contraindications kollidieren
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication { $injuries }
        ?exercise rehab:hasContraindication ?selectedContraindication
    }

    # Pflichtfelder
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction ;
              rehab:hasDuration ?duration ;
              rdfs:label ?exerciseLabel .

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}

GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        //TODO[API]: Prüfen warum das nur im try-catch funktioniert.
        try {
          List<Exercise> values = bindings.map((json) {
            try {
              return Exercise.fromSparqlJson(json);
            } catch (innerError, stackTrace) {
              print('--- PARSE ERROR IN fetchFilteredExercises ---');
              print('JSON: $json');
              print('Error: $innerError');
              print('Stacktrace:\n$stackTrace');
              rethrow;
            }
          }).toList();
          return values;
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }

  String _getDifficulties(SkillLevel skillLevel) {
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
