import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/skill_level.dart';

import '../models/api/exercise.dart';

class ExerciseApi extends CoreApi {
  /**
   * Planerstellung: Gib alle Exercises zurück die die Problemzonen nicht beeinflussen.
   */
  Future<List<Exercise>> fetchAllExercisesExcludeContraindications(
    List<String> contraindications,
  ) async {
    String injuries = contraindications.map((e) => "rehab:$e").join(" ");

    final query =
        '''
SELECT
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?duration
    ?instruction
    ?video
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
    		  rdfs:label ?exerciseLabel ;
    		  rdfs:comment ?description .
  
  	FILTER(
    LANGMATCHES(LANG(?contraindicationLabel), "en")	&&
    LANGMATCHES(LANG(?trainingsEffectLabel), "en") &&
    LANGMATCHES(LANG(?bodyPartLabel), "en") &&
    LANGMATCHES(LANG(?exerciseLabel), "de") &&
    LANGMATCHES(LANG(?description), "de")
  )

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    OPTIONAL { ?exercise rehab:hasVideoUrl ?video }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}
GROUP BY
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
    ?video
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
   * Planerstellung: Gib alle Exercises für eine ausgewählte Körperregion zurück,
   * die die Problemzonen des Nutzers nicht beeinflussen (ohne Filterung nach Schwierigkeitsgrad).
   */
  Future<List<Exercise>> fetchExercisesForPlanCreation(
    BodyPart bodyPart,
    List<String> contraindications,
  ) async {
    String bodyParts = "rehab:${bodyPart.labelEN}";
    String injuries = contraindications.map((e) => "rehab:$e").join(" ");

    final query =
        '''
SELECT
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?duration
    ?instruction
    ?video
    # Verpackt alle Values der Property in einem Value
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)

WHERE {
    # Filterparameter (werden zur Laufzeit übergeben)
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
    		  rdfs:label ?exerciseLabel ;
    		  rdfs:comment ?description .
  
  	FILTER(
    LANGMATCHES(LANG(?contraindicationLabel), "en")	&&
    LANGMATCHES(LANG(?trainingsEffectLabel), "en") &&
    LANGMATCHES(LANG(?bodyPartLabel), "en") &&
    LANGMATCHES(LANG(?exerciseLabel), "de") &&
    LANGMATCHES(LANG(?description), "de")
  )

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    OPTIONAL { ?exercise rehab:hasVideoUrl ?video }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}

GROUP BY
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
    ?video
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        try {
          List<Exercise> values = bindings.map((json) {
            try {
              return Exercise.fromSparqlJson(json);
            } catch (innerError, stackTrace) {
              print('--- PARSE ERROR IN fetchExercisesForPlanCreation ---');
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

  /**
   * Planempfehlung: Gib alle Exercises zurück die die Problemzonen nicht beeinflussen gefiltert über Körperregion, MEHRERE Trainingsziele (List<Goal>) und Schwierigkeitslevel.
   */
  Future<List<Exercise>> fetchExercisesForRecommendation(
    BodyPart bodyPart,
    List<Goal> goals,
    List<String> contraindications,
    SkillLevel skillLevel,
  ) async {
    String difficulty = _getDifficulties(skillLevel);
    String goalsStr = goals.map((g) => "rehab:${g.labelEN}").join(" ");
    String bodyParts = "rehab:${bodyPart.labelEN}";
    String injuries = contraindications.map((e) => "rehab:$e").join(" ");

    final query =
        '''
SELECT
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?duration
    ?instruction
    ?video
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
    VALUES ?trainingsEffect { $goalsStr }
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
    		  rdfs:label ?exerciseLabel ;
    		  rdfs:comment ?description .
  
  	FILTER(
    LANGMATCHES(LANG(?contraindicationLabel), "en")	&&
    LANGMATCHES(LANG(?trainingsEffectLabel), "en") &&
    LANGMATCHES(LANG(?bodyPartLabel), "en") &&
    LANGMATCHES(LANG(?exerciseLabel), "de") &&
    LANGMATCHES(LANG(?description), "de")
  )

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    OPTIONAL { ?exercise rehab:hasVideoUrl ?video }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}

GROUP BY
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
    ?video
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        try {
          List<Exercise> values = bindings.map((json) {
            try {
              return Exercise.fromSparqlJson(json);
            } catch (innerError, stackTrace) {
              print('--- PARSE ERROR IN fetchExercisesForRecommendation ---');
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

  /**
   * Veraltete Methode (wird durch fetchExercisesForRecommendation ersetzt). für sicherheit falls es noch was
   * von alten methoden aufgerufen wird .
   */
  Future<List<Exercise>> fetchExercisesByParamsExcludeContraindications(
    BodyPart bodyPart,
    Goal goal,
    List<String> contraindications,
    SkillLevel skillLevel,
  ) async {
    return fetchExercisesForRecommendation(
      bodyPart,
      [goal],
      contraindications,
      skillLevel,
    );
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
