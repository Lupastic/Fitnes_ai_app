import 'package:flutter/material.dart';

enum QuestDifficulty { easy, medium, hard }

class Quest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final QuestDifficulty difficulty;
  final int points;
  final bool Function(dynamic contextData) isCompleted;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.points,
    required this.isCompleted,
  });
}
