import 'package:app_prototype/data/enum/body_part.dart';
import 'package:app_prototype/data/enum/goal.dart';
import 'package:app_prototype/data/models/api/exercise.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'plan.g.dart';

@Collection()
class Plan {
  Id isarId;

  @Index(unique: true)
  final String id;
  final String name;

  @enumerated
  final BodyPart region;

  @enumerated
  final List<Goal> goals;

  /// Ziele des Plans.
  @ignore
  List<Goal> get allGoals {
    return goals.where((g) => g != Goal.none).toList();
  }

  /// Ziele, die von den aktuell enthaltenen Übungen wirklich abgedeckt werden.
  /// Ohne gewählte Ziele bleibt der Plan bewusst ohne Tags.
  @ignore
  List<Goal> get effectiveGoals {
    if (allGoals.isEmpty) return const [];
    final covered = exercises
        .expand((e) => e.trainingsEffects.map(GoalExt.fromString))
        .where((g) => g != Goal.none)
        .toSet();
    if (covered.isEmpty) return allGoals;
    return allGoals.where(covered.contains).toList();
  }

  final List<Exercise> exercises;
  final int sessionsPerWeek;
  final int completedSessions;
  final String source; // "empfohlen" | "eigen"
  final bool archived;

  /// Speicherung als Integer für Isar
  final int colorValue;

  /// Bequemes Color-Getter für den Rest der App
  @ignore
  Color get color => Color(colorValue);

  @ignore
  final String? description;

  Plan({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.name,
    required this.region,
    this.goals = const [],
    this.exercises = const [],
    this.sessionsPerWeek = 3,
    this.completedSessions = 0,
    this.source = 'eigen',
    this.archived = false,
    this.colorValue = 0xFF1F4E47, // Default-Wert als int (AppColors.sageDeep)
    this.description,
  });

  Plan copyWith({
    Id? isarId,
    String? id,
    String? name,
    BodyPart? region,
    List<Goal>? goals,
    List<Exercise>? exercises,
    int? sessionsPerWeek,
    int? completedSessions,
    String? source,
    bool? archived,
    Color? color,
    int? colorValue,
    String? description,
  }) {
    return Plan(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      goals: goals ?? this.goals,
      exercises: exercises ?? this.exercises,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      completedSessions: completedSessions ?? this.completedSessions,
      source: source ?? this.source,
      archived: archived ?? this.archived,
      colorValue: colorValue ?? (color != null ? color.toARGB32() : this.colorValue),
      description: description ?? this.description,
    );
  }

  int get duration {
    return exercises.fold(0, (sum, exercise) => sum + exercise.duration);
  }
}
