import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/models/models.dart';

class UserApi extends CoreApi {

  /// Akzeptanzkriterium 1: Profil an API (Fuseki) übertragen
  Future<bool> updateUserProfile(User user) async {
    // Wandelt die Kontraindikationen in rehab-Ressourcen um (z.B. rehab:KneePain)
    String contraindicationsTriples = user.contraindication
        .map((e) => 'rehab:CurrentUser rehab:hasContraindication rehab:$e .')
        .join('\n');

    final query = '''
    DELETE WHERE {
      rehab:CurrentUser ?p ?o .
    };
    INSERT DATA {
      rehab:CurrentUser a rehab:User ;
                        rehab:hasName "${user.name}" ;
                        rehab:hasAge ${user.age} ;
                        rehab:hasHeight ${user.height} ;
                        rehab:hasWeight ${user.weight} ;
                        rehab:hasDifficultyLevel rehab:${_getDifficultyLabel(user.skillLevel)} .

      $contraindicationsTriples
    }
    ''';

    try {
      final response = await postQuery(query);
      return response.statusCode == 200;
    } catch (e) {
      print('API Error beim Updaten des Profils: \$e');
      return false;
    }
  }

  /// Akzeptanzkriterium 3: Profil aus der API / Fuseki löschen
  Future<bool> deleteUserProfile() async {
    final query = '''
    DELETE WHERE {
      rehab:CurrentUser ?p ?o .
    }
    ''';

    try {
      final response = await postQuery(query);
      return response.statusCode == 200;
    } catch (e) {
      print('API Error beim Löschen des Profils: \$e');
      return false;
    }
  }

  String _getDifficultyLabel(dynamic skillLevel) {
    return skillLevel.toString().split('.').last.toUpperCase();
  }
}