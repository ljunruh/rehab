import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CoreApi {
  // kIsWeb Prüft ob Plattform Web ist.
  // Für den Android-Emulator nutzt man '10.0.22' statt 'localhost'.
  static final String _host = kIsWeb
      ? 'localhost:3030'
      : (Platform.isAndroid ? '10.0.2.2:3030' : 'localhost:3030');

  final String _fusekiUrl = 'http://$_host/rehab/query';

  /// Standard SPARQL Prefixe
  String get _defaultPrefixes => '''
  PREFIX re: <http://www.w3.org/2000/10/swap/reason#>
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX rehab: <http://purl.org/PhysicalTherapy#>
  ''';

  /// Standard Headers (immer dabei)
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/sparql-query',
    'Accept': 'application/sparql-results+json',
  };

  /// Generic POST SPARQL Query Request
  Future<http.Response> postQuery(
    String query, {
    Map<String, String>? extraHeaders,
    String? extraPrefixes,
  }) async {
    final headers = {
      ..._defaultHeaders,
      if (extraHeaders != null) ...extraHeaders,
    };

    final fullQuery = '''
    $_defaultPrefixes
    ${extraPrefixes ?? ''}
    #
    $query
    ''';

    return await http.post(
      Uri.parse(_fusekiUrl),
      headers: headers,
      body: fullQuery,
    );
  }
}
