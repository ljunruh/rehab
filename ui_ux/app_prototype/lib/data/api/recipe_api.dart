import 'dart:convert';

import 'package:app_prototype/data/api/core_api.dart';
import 'package:app_prototype/data/models/api/recipe.dart';

class RecipeApi extends CoreApi {
  Future<List<RecipeCandidate>> fetchNotUnlockedRecipes(List<String> unlockedRecipeIds) async {
    final String exclusionBlock;

    if (unlockedRecipeIds.isEmpty) {
      exclusionBlock = '';
    } else {
      final values = unlockedRecipeIds
          .map((id) => '"${id.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"')
          .join(' ');

      exclusionBlock = '''
  FILTER NOT EXISTS {
    VALUES ?alreadyUnlockedId { $values }
    FILTER(?recipeId = ?alreadyUnlockedId)
  }
''';
    }

    final query = '''
SELECT ?recipeId ?hasDescription ?hasHealthBenefit ?hasPreparationTime
WHERE {
  ?recipe a rehab:RecipeOfTheWeek ;
          rehab:hasDescription ?hasDescription ;
          rehab:hasHealthBenefit ?hasHealthBenefit ;
          rehab:hasPreparationTime ?hasPreparationTime .

  BIND(REPLACE(STR(?recipe), "^.*[#/]", "") AS ?recipeId)
  $exclusionBlock
}
''';

    final response = await postQuery(query);
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Rezepte: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> bindings = data['results']['bindings'] as List<dynamic>;

    return bindings
        .cast<Map<String, dynamic>>()
        .map(RecipeCandidate.fromSparqlJson)
        .where((recipe) => recipe.id.isNotEmpty)
        .toList();
  }
}
