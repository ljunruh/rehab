import 'package:app_prototype/data/models/api/recipe.dart';
import 'package:app_prototype/data/repository/recipe_repository.dart';
import 'package:flutter/material.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository recipeRepo;

  RecipeProvider(this.recipeRepo) {
    _loadUnlockedRecipes();
  }

  List<Recipe> _history = [];
  List<Recipe> get history => _history;

  Recipe? _currentRecipe;
  Recipe? get currentRecipe => _currentRecipe;

  int _lastProcessedStreak = -1;

  Future<void> _loadUnlockedRecipes() async {
    _history = await recipeRepo.getUnlockedRecipesSortedByDateDesc();
    _currentRecipe = _history.isNotEmpty ? _history.first : null;
    notifyListeners();
  }

  /// Schaltet bei steigender Wochenstreak genau ein neues Rezept frei.
  Future<void> syncWithWeeklyStreak(int weeklyStreak) async {
    if (weeklyStreak == _lastProcessedStreak) return;
    _lastProcessedStreak = weeklyStreak;

    _history = await recipeRepo.getUnlockedRecipesSortedByDateDesc();

    if (weeklyStreak <= 0) {
      _currentRecipe = null;
      notifyListeners();
      return;
    }

    if (weeklyStreak > _history.length) {
      final unlocked = await recipeRepo.unlockRandomRecipe();
      if (unlocked != null) {
        _history = await recipeRepo.getUnlockedRecipesSortedByDateDesc();
      }
    }

    _currentRecipe = _history.isNotEmpty ? _history.first : null;
    notifyListeners();
  }
}
