import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';

import '../models/condition.dart';

class ConditionApi extends CoreApi {
  /*
  Lese alle Conditions aus und gebe Condition, Label und Description zurück.
  TODO[API]: Ist veraltet und muss angepasst werden durch Injury.
  Wir später bei Planerstellung und -empfehlung genutzt
  */
  Future<List<Condition>> fetchConditions() async {
    const query = '''
      SELECT ?condition ?label ?comment WHERE {
        ?condition a/rdfs:subClassOf* rehab:Condition .
        OPTIONAL { ?condition rdfs:label ?label . }
        OPTIONAL { ?condition rdfs:comment ?comment . }
      }
    ''';

    try {
      final response = await postQuery(query);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];
        return bindings.map((json) => Condition.fromSparqlJson(json)).toList();
      } else {
        throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }
}
