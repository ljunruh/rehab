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
  Future<List<Exercise>> fetchFilteredExercises(BodyPart bodyPart, Goal goal, List<String> injury, SkillLevel skillLevel) async {
    String difficulty = _getDifficulties(skillLevel);
    String goals = "rehab:${goal.labelEN}"; //Kann später zu mehr Goals erweitert werden
    String bodyParts = "rehab:${bodyPart.labelEN}"; //Kann später zu mehr BodyParts erweitert werden
    String injuries = injury.map((e) => "rehab:$e").join(" ");

    final query = '''
SELECT
	?exercise 
	?exerciseLabel
	?difficultyLabel
	# Verpack alle Values der Property in einem Value
	(GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
	(GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
	(GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
	?description
	?duration
	?instruction
	(GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
	(GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)
WHERE {
  	#rehab:Advanced -> keine Profi Übungen
    VALUES ?difficulty { $difficulty }
  	#rehab:Strength rehab:Coordination rehab:Flexibility rehab:Focus rehab:Mobility rehab:Posture rehab:Relaxation rehab:Stability -> Übungen die kein Strength Ziel haben
  	VALUES ?trainingsEffect { $goals }
  	#rehab:UpperBack -> Übungen die den UpperBack nicht beanspruchen rehab:Ankles rehab:Arms rehab:Back rehab:Biceps rehab:Calves rehab:Chest rehab:Core rehab:Elbows rehab:Glutes rehab:Hamstrings rehab:Hip rehab:Knees rehab:Legs rehab:LowerBack rehab:Neck rehab:Obliques rehab:Pelvic rehab:Psoas rehab:Quadriceps rehab:Shoulders rehab:Spine rehab:Thighs rehab:Triceps rehab:Wrists
  	VALUES ?bodyPart { $bodyParts }
  
  	# Filter auf Übungen anhand übergebener VALUES Parameter
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
  			  rehab:hasContraindication ?contraindication;
       		  rehab:improves ?trainingsEffect ;
  			  rehab:engagedBodyPart ?bodyPart .
	?contraindication a rehab:Contraindication .
	?contraindication rdfs:label ?contraindicationLabel .
  	?trainingsEffect a rehab:TrainingsEffect .
  	?trainingsEffect rdfs:label ?trainingsEffectLabel .
  	?bodyPart a rehab:BodyPart .
  	?bodyPart rdfs:label ?bodyPartLabel .

  	FILTER NOT EXISTS {
    	VALUES ?selectedContraindication { $injuries } # -> Übungen rausnehmen die diese Problemzonen beanspruchen würden
    	?exercise rehab:hasContraindication ?selectedContraindication
  	}
  
  	# Text Properties zur Übungsbeschreibung
  	OPTIONAL { ?exercise rdfs:label ?exerciseLabel }
  	OPTIONAL { ?exercise rehab:hasDescription ?description }
  	OPTIONAL { ?exercise rehab:duration ?duration }
  	OPTIONAL { ?exercise rehab:hasInstruction ?instruction }
  	OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
  	OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    
  	#Erstelle aus einer URI ein Labelersatz: http://purl.org/PhysicalTherapy#Deadlift -> Deadlift 
  	BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
} GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?description
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
        List<Exercise> values = bindings.map((json) => Exercise.fromSparqlJson(json)).toList();
        return values;
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
