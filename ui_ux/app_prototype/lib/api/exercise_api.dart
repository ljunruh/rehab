import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/exercise.dart';

class ExerciseApi {
  // kIsWeb Prüft ob Plattform Web ist.
  // Für den Android-Emulator nutzt man '10.0.22' statt 'localhost'.
  static final String _host = kIsWeb
      ? 'localhost:3030'
      : (Platform.isAndroid ? '10.0.2.2:3030' : 'localhost:3030');

  final String _fusekiUrl = 'http://$_host/rehab/query';

  Future<List<Exercise>> fetchExercises() async {
    const query = '''
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX v: <http://reha-app.org/vocab#>

      SELECT ?uebung ?uebungLabel ?bodyPartLabel WHERE {
        ?uebung a v:Activity ;
                rdfs:label ?uebungLabel ;
                v:involvesBodyPart ?bodyPart .
        ?bodyPart rdfs:label ?bodyPartLabel .
        FILTER (lang(?uebungLabel) = "de")
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_fusekiUrl),
        headers: {
          'Content-Type': 'application/sparql-query',
          'Accept': 'application/sparql-results+json',
        },
        body: query,
      );

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