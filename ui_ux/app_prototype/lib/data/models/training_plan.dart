import 'package:flutter/material.dart';

/// Modell eines Trainingsplans (reines UI-Modell).
///
/// Pro Körperregion existiert genau ein aktiver Plan (Logik im UiState).
/// Ohne JSON-Serialisierung — Anbindung an die API macht die Backend-Gruppe.
class TrainingPlan {
  final String id;
  final String name;
  final String region;
  final String goal;
  final List<String> exerciseIds;
  final int sessionsPerWeek;
  final int completedSessions;
  final String source; // "empfohlen" | "eigen"
  final bool archived;

  /// Kalenderfarbe des Plans (StyleGuide §11). Optional.
  final Color? color;

  /// Optionale Beschreibung (bei Empfehlungsplänen vorhanden).
  final String? description;

  const TrainingPlan({
    required this.id,
    required this.name,
    required this.region,
    required this.goal,
    this.exerciseIds = const [],
    this.sessionsPerWeek = 3,
    this.completedSessions = 0,
    this.source = 'eigen',
    this.archived = false,
    this.color,
    this.description,
  });

  TrainingPlan copyWith({
    String? name,
    String? region,
    String? goal,
    List<String>? exerciseIds,
    int? sessionsPerWeek,
    int? completedSessions,
    String? source,
    bool? archived,
    Color? color,
    String? description,
  }) {
    return TrainingPlan(
      id: id,
      name: name ?? this.name,
      region: region ?? this.region,
      goal: goal ?? this.goal,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      completedSessions: completedSessions ?? this.completedSessions,
      source: source ?? this.source,
      archived: archived ?? this.archived,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }
}
