import 'dart:math';

import 'package:app_prototype/data/api/recipe_api.dart';
import 'package:app_prototype/data/models/api/recipe.dart';
import 'package:isar/isar.dart';

class RecipeRepository {
  final Isar isar;
  final RecipeApi api;
  final Random _random;

  RecipeRepository(
    this.isar, {
    required this.api,
    Random? random,
  }) : _random = random ?? Random();

  Future<List<Recipe>> getUnlockedRecipesSortedByDateDesc() async {
    final recipes = await isar.recipes.where().findAll();
    recipes.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return recipes;
  }

  Future<Recipe?> getLatestUnlockedRecipe() async {
    final recipes = await getUnlockedRecipesSortedByDateDesc();
    if (recipes.isEmpty) return null;
    return recipes.first;
  }

  Future<List<RecipeCandidate>> getNotUnlockedRecipes() async {
    final unlocked = await isar.recipes.where().findAll();
    final unlockedIds = unlocked.map((recipe) => recipe.id).toList();
    return api.fetchNotUnlockedRecipes(unlockedIds);
  }

  Future<Recipe?> unlockRandomRecipe() async {
    final candidates = await getNotUnlockedRecipes();
    if (candidates.isEmpty) return null;

    final chosen = candidates[_random.nextInt(candidates.length)];
    final recipe = Recipe(
      id: chosen.id,
      hasDescription: chosen.hasDescription,
      hasHealthBenefit: chosen.hasHealthBenefit,
      hasPreparationTime: chosen.hasPreparationTime,
      unlockedAt: DateTime.now(),
    );

    await isar.writeTxn(() async {
      await isar.recipes.put(recipe);
    });

    return recipe;
  }
}
