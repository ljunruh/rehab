import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/enum/contraindication.dart';
import 'package:app_prototype/data/enum/skill_level.dart';

import '../models/api/exercise.dart';

class ExerciseApi extends CoreApi {

  final String exceptionExerciseSubClasses = "rehab:Mobilisation rehab:Relaxation rehab:Stretching";
  //TODO[API]: Prüfen ob das noch gebraucht wird, da wir anscheinend immer bodypart, goal und skillLevel mit einbeziehen
  Future<List<Exercise>> fetchAllExercisesExcludeContraindications(List<String> contraindications, List<String> joints) async {
    String complaints = contraindications.map((e) => "rehab:$e").join(" ");
    String injuries = joints.map((e) => "rehab:$e").join(" ");

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
    
    # 1. Entfernt Übungen, die mit betroffenen Gelenken (Joints) kollidieren
    FILTER NOT EXISTS {
        VALUES ?selectedJoints { $injuries }
    	# Stellt sicher, dass das ausgewählte Element ein Joint ist (Subclass von BodyPart)
        ?selectedJoints a/rdfs:subClassOf* rehab:Joint .
        ?exercise rehab:engagedBodyPart ?selectedJoints .
    }
  
    # 2. Entfernt Übungen mit angegebenen Contraindications,
    # AUSSER die Übung stammt von den Klassen Mobilisation, Relaxation oder Stretching ab.
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication { $complaints }
        ?exercise rehab:hasContraindication ?selectedContraindication .

        # Ausnahmeregel: Wenn die Übung vom Typ (oder einer Subklasse von)
        # Mobilisation, Relaxation oder Stretching ist, greift der Ausschluss NICHT.
        FILTER NOT EXISTS {
            VALUES ?exceptionClass { $exceptionExerciseSubClasses }
            ?exercise a/rdfs:subClassOf* ?exceptionClass .
        }
    }

    # Übungen müssen diese Labels besitzen
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction ;
              rehab:hasDuration ?duration ;
              rdfs:label ?exerciseLabel ;
              rdfs:comment ?description .
  
    # Labels sind mehrsprachig und werden auf die notwendige Sprache für die Datenverarbeitung beschränkt
    FILTER(
        LANGMATCHES(LANG(?contraindicationLabel), "en") &&
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
} GROUP BY
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
   * Planerstellung ("Eigenen Plan erstellen"): Gib alle Exercises für eine
   * Körperregion zurück, die die Problemzonen (Beschwerden und Gelenke) nicht
   * beeinflussen — OHNE Filterung nach Trainingsziel oder Schwierigkeitslevel.
   * Der Nutzer wählt hier selbst manuell Übungen aus einer vollständigen
   * Liste, im Gegensatz zur zielgetriebenen Planempfehlung.
   */
  Future<List<Exercise>> fetchExercisesForPlanCreation(BodyPart bodyPart, List<String> contraindications, List<String> joints) async {
    String bodyParts = "rehab:${bodyPart.labelEN}";
    String complaints = contraindications.map((e) => "rehab:$e").join(" ");
    String injuries = joints.map((e) => "rehab:$e").join(" ");

    final query = '''
SELECT
    ?exercise
    ?exerciseLabel
    ?description
    ?difficultyLabel
    ?duration
    ?instruction
    ?video
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)

WHERE {
    # Gewünschte Körperbereiche
    VALUES ?bodyPart { $bodyParts }

    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .
    ?contraindication a rehab:Contraindication .
    ?trainingsEffect a rehab:TrainingsEffect .
    ?bodyPart a rehab:BodyPart .

    # 1. Entfernt Übungen, die mit betroffenen Gelenken (Joints) kollidieren
    FILTER NOT EXISTS {
        VALUES ?selectedJoints { $injuries }
        ?selectedJoints a/rdfs:subClassOf* rehab:Joint .
        ?exercise rehab:engagedBodyPart ?selectedJoints .
    }

    # 2. Entfernt Übungen mit angegebenen Contraindications,
    # AUSSER die Übung stammt von den Klassen Mobilisation, Relaxation oder Stretching ab.
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication { $complaints }
        ?exercise rehab:hasContraindication ?selectedContraindication .
        FILTER NOT EXISTS {
            VALUES ?exceptionClass { $exceptionExerciseSubClasses }
            ?exercise a/rdfs:subClassOf* ?exceptionClass .
        }
    }

    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction ;
              rehab:hasDuration ?duration ;
              rdfs:label ?exerciseLabel ;
              rdfs:comment ?description .

    FILTER(
        LANGMATCHES(LANG(?contraindicationLabel), "en") &&
        LANGMATCHES(LANG(?trainingsEffectLabel), "en") &&
        LANGMATCHES(LANG(?bodyPartLabel), "en") &&
        LANGMATCHES(LANG(?exerciseLabel), "de") &&
        LANGMATCHES(LANG(?description), "de")
    )

    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    OPTIONAL { ?exercise rehab:hasVideoUrl ?video }

    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
} GROUP BY
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
              print('--- PARSE ERROR IN fetchExercisesForPlanCreation ---');
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
   * Planempfehlung -erstellung: Gib alle Exercises zurück die die Problemzonen (Beschwerden und Gelenke) nicht beeinflussen
   * gefilter über Körperregion, Traingsziel und Schwierigkeitslevel.
   */
  Future<List<Exercise>> fetchExercisesByParamsExcludeContraindications(BodyPart bodyPart, Goal goal, SkillLevel skillLevel, List<String> contraindications, List<String> joints) async {
    String difficulty = _getDifficulties(skillLevel);
    String goals = "rehab:${goal.labelEN}"; //Kann später zu mehr Goals erweitert werden
    String bodyParts = "rehab:${bodyPart.labelEN}"; //Kann später zu mehr BodyParts erweitert werden
    String complaints = contraindications.map((e) => "rehab:$e").join(" ");
    String injuries = joints.map((e) => "rehab:$e").join(" ");

    final query = '''
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

    # 1. Entfernt Übungen, die mit betroffenen Gelenken (Joints) kollidieren
    FILTER NOT EXISTS {
        VALUES ?selectedJoints { $injuries }
    	# Stellt sicher, dass das ausgewählte Element ein Joint ist (Subclass von BodyPart)
        ?selectedJoints a/rdfs:subClassOf* rehab:Joint .
        ?exercise rehab:engagedBodyPart ?selectedJoints .
    }
  
    # 2. Entfernt Übungen mit angegebenen Contraindications,
    # AUSSER die Übung stammt von den Klassen Mobilisation, Relaxation oder Stretching ab.
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication { $complaints }
        ?exercise rehab:hasContraindication ?selectedContraindication .

        # Ausnahmeregel: Wenn die Übung vom Typ (oder einer Subklasse von)
        # Mobilisation, Relaxation oder Stretching ist, greift der Ausschluss NICHT.
        FILTER NOT EXISTS {
            VALUES ?exceptionClass { $exceptionExerciseSubClasses }
            ?exercise a/rdfs:subClassOf* ?exceptionClass .
        }
    }

    # Übungen müssen diese Labels besitzen
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction ;
              rehab:hasDuration ?duration ;
              rdfs:label ?exerciseLabel ;
              rdfs:comment ?description .
  
    # Labels sind mehrsprachig und werden auf die notwendige Sprache für die Datenverarbeitung beschränkt
    FILTER(
        LANGMATCHES(LANG(?contraindicationLabel), "en") &&
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
} GROUP BY
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
