// lib/models/daily_summary.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

part 'daily_summary.g.dart';

@HiveType(typeId: 1) 
class DailySummary extends HiveObject {
  @HiveField(0) DateTime date;
  @HiveField(1) int waterCups;
  @HiveField(2) double sleepHours;
  @HiveField(3) int calories;
  @HiveField(4) int steps;
  @HiveField(5) bool synced;

  @HiveField(6) int yogaSessions;
  @HiveField(7) int plankMinutes;
  @HiveField(8) double runningKm;
  @HiveField(9) int meditationMinutes;
  @HiveField(10) int sugarFreeDays;

  DailySummary({
    required this.date,
    required this.waterCups,
    required this.sleepHours,
    required this.calories,
    required this.steps,
    this.synced = false,
    this.yogaSessions = 0,
    this.plankMinutes = 0,
    this.runningKm = 0.0,
    this.meditationMinutes = 0,
    this.sugarFreeDays = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), 
      'waterCups': waterCups,
      'sleepHours': sleepHours,
      'calories': calories,
      'steps': steps,
      'yogaSessions': yogaSessions,
      'plankMinutes': plankMinutes,
      'runningKm': runningKm,
      'meditationMinutes': meditationMinutes,
      'sugarFreeDays': sugarFreeDays,
      'synced': synced,
    };
  }

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      date: (map['date'] as Timestamp).toDate(),
      waterCups: map['waterCups'] as int? ?? 0,
      sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 0.0,
      calories: map['calories'] as int? ?? 0,
      steps: map['steps'] as int? ?? 0,
      synced: map['synced'] as bool? ?? false,
      yogaSessions: map['yogaSessions'] as int? ?? 0,
      plankMinutes: map['plankMinutes'] as int? ?? 0,
      runningKm: (map['runningKm'] as num?)?.toDouble() ?? 0.0,
      meditationMinutes: map['meditationMinutes'] as int? ?? 0,
      sugarFreeDays: map['sugarFreeDays'] as int? ?? 0,
    );
  }
}