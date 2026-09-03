import 'package:flutter/material.dart';
import 'package:app_prototype/data/models/api/daily_life_advice.dart';
import 'package:app_prototype/data/repository/daily_life_advice_repository.dart';

class DailyLifeAdviceProvider extends ChangeNotifier {
  final DailyLifeAdviceRepository _repository = DailyLifeAdviceRepository();

  List<DailyLifeAdviceCandidate> _advice = [];
  bool _isLoading = false;
  String? _error;

  List<DailyLifeAdviceCandidate> get advice => _advice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Laden von Schonungstipps für spezifische Körperregionen
  Future<void> loadAdviceByBodyParts(List<String> bodyParts) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAdviceByBodyParts(bodyParts);
      _advice = result ?? [];
      // Zufällig mischen für UI-Variety
      _advice.shuffle();
    } catch (e) {
      _error = e.toString();
      _advice = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Laden aller Schonungstipps
  Future<void> loadAllAdvice() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAllAdvice();
      _advice = result ?? [];
      _advice.shuffle();
    } catch (e) {
      _error = e.toString();
      _advice = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gibt eine zufällige Auswahl von Tipps zurück (z.B. 4 für das 2x2 Grid).
  /// Bereits sichtbare Tipps werden bevorzugt ausgeschlossen.
  List<DailyLifeAdviceCandidate> getRandomAdvice(
    int count, {
    Set<String> excludedIds = const {},
  }) {
    if (_advice.isEmpty) return [];

    final available = _advice
        .where((advice) => !excludedIds.contains(advice.id))
        .toList()
      ..shuffle();

    if (available.length >= count) {
      return available.take(count).toList();
    }

    final fallback = [..._advice]..shuffle();
    return [...available, ...fallback]
        .fold<List<DailyLifeAdviceCandidate>>([], (selection, advice) {
      if (selection.length < count &&
          !selection.any((selected) => selected.id == advice.id)) {
        selection.add(advice);
      }
      return selection;
    });
  }
}
