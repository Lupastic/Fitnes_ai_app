// lib/services/sync_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Добавил для получения UID
import '../services/local_repository.dart';
import '../models/daily_summary.dart';

class SyncService {
  final LocalRepository _repo;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncService(this._repo);

  Future<void> sync() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("SyncService: User not logged in, cannot sync to Firebase.");
      return;
    }

    final items = _repo.unsynced();
    for (final d in items) {
      try {
        await _fire
            .collection('users')
            .doc(user.uid) // Используем UID текущего пользователя
            .collection('summaries')
            .doc(d.date.toIso8601String()) // Используем дату как ID документа
            .set(d.toMap()); // Используем toMap() из DailySummary

        d.synced = true;
        await d.save(); // Сохраняем изменение в Hive
        print("DailySummary for ${d.date.toIso8601String()} synced successfully.");
      } catch (e) {
        print("Error syncing DailySummary for ${d.date.toIso8601String()}: $e");
        // Ошибка синхронизации, оставляем synced = false, чтобы попробовать позже
      }
    }
  }
}