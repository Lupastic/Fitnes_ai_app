// lib/models/history_entry.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime timestamp;

  HistoryEntry({required this.title, required this.timestamp});

  // Методы для преобразования в Map и обратно для Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp), // Используем Timestamp для Firestore
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      title: map['title'] as String? ?? 'No Title', // Добавил безопасное приведение
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(), // Fallback, если Timestamp некорректен
    );
  }
}