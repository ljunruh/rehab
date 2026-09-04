import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CoreApi {
  static String? _cachedHost;

  /// Asynchroner Getter zur Ermittlung der Host-Adresse
  static Future<String> get _host async {
    if (_cachedHost != null) return _cachedHost!;

    if (kIsWeb) {
      _cachedHost = 'localhost:3030';
    } else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // isPhysicalDevice ist true auf dem echten S10 Lite (Termux),
      // und false im Android Studio Emulator.
      if (androidInfo.isPhysicalDevice) {
        _cachedHost = '127.0.0.1:3030'; // Auf Android ist 127.0.0.1 oft stabiler als 'localhost'
      } else {
        _cachedHost = '10.0.2.2:3030';   // PC-Host vom Android-Emulator
      }
    } else {
      _cachedHost = '127.0.0.1:3030';   // iOS / Desktop
    }

    return _cachedHost!;
  }

  /// Standard SPARQL Prefixe
  String get _defaultPrefixes => '''
  PREFIX re: <http://www.w3.org/2000/10/swap/reason#>
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX rehab: <http://purl.org/PhysicalTherapy#>
  ''';

  /// Standard Headers
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

    // 1. Host auflösen mit await
    final hostAddress = await _host;

    // 2. Ziel-URL zur Laufzeit dynamisch bauen
    final fusekiUrl = 'http://$hostAddress/rehab/query';

    debugPrint('---> [SPARQL POST] URL: $fusekiUrl');
    debugPrint('---> [SPARQL QUERY]:\n$fullQuery');

    try {
      final response = await http.post(
        Uri.parse(fusekiUrl),
        headers: headers,
        body: fullQuery,
      );

      debugPrint('<--- [SPARQL RESPONSE] Status Code: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('<--- [SPARQL ERROR BODY]: ${response.body}');
      }
      return response;
    } catch (e, stack) {
      debugPrint('<--- [SPARQL NETWORK ERROR]: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}
