import 'dart:convert';

import 'package:app_prototype/api/core_api.dart';

import '../model/condition.dart';

class UserApi extends CoreApi {
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
