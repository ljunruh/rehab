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
  final Goal goal;
  final List<Exercise> exercises;
  final int sessionsPerWeek;
  final int completedSessions;
  final String source; // "empfohlen" | "eigen"
  final bool archived;

  @ignore
  final Color? color;

  @ignore
  final String? description;

  Plan({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.name,
    required this.region,
    required this.goal,
    this.exercises = const [],
    this.sessionsPerWeek = 3,
    this.completedSessions = 0,
    this.source = 'eigen',
    this.archived = false,
    this.color,
    this.description,
  });

  Plan copyWith({
    Id? isarId,
    String? id,
    String? name,
    BodyPart? region,
    Goal? goal,
    List<Exercise>? exercises,
    int? sessionsPerWeek,
    int? completedSessions,
    String? source,
    bool? archived,
    Color? color,
    String? description,
  }) {
    return Plan(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      goal: goal ?? this.goal,
      exercises: exercises ?? this.exercises,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      completedSessions: completedSessions ?? this.completedSessions,
      source: source ?? this.source,
      archived: archived ?? this.archived,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  int get duration {
    return exercises.fold(0, (sum, exercise) => sum + exercise.duration);
  }
}
