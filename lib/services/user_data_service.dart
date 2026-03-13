// lib/services/user_data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/history_entry.dart';
import '../models/daily_summary.dart'; // Добавил для DailySummary

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Метод для получения ссылки на документ текущего пользователя (теперь публичный)
  DocumentReference? getUserDocRef() {
    final user = _auth.currentUser;
    if (user == null) {
      // print("Error: User not logged in."); // Избегаем спама в консоли, если это ожидаемо
      return null;
    }
    return _firestore.collection('users').doc(user.uid);
  }

  // Метод для обновления полей профиля (имя, цели, язык)
  Future<void> updateProfileData({
    String? name,
    Map<String, int>? goals,
    String? languageCode,
  }) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return;

    final Map<String, dynamic> dataToUpdate = {};
    if (name != null) dataToUpdate['name'] = name;
    if (goals != null) dataToUpdate['goals'] = goals; // Goals сохраняются как Map
    if (languageCode != null) dataToUpdate['language'] = languageCode;

    try {
      await userDocRef.set(dataToUpdate, SetOptions(merge: true));
      print("Profile data updated in Firestore.");
    } catch (e) {
      print("Error updating profile data: $e");
    }
  }

  // Метод для добавления записи в подколлекцию "history"
  Future<void> addHistoryEntry(HistoryEntry entry) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return;

    try {
      await userDocRef.collection('history').add(entry.toMap());
      print("History entry added to Firestore.");
    } catch (e) {
      print("Error adding history entry: $e");
    }
  }

  // Метод для получения всех целей пользователя (пример чтения данных)
  Future<Map<String, int>> getUserGoals() async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return {};

    try {
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()! as Map<String, dynamic>; // Явное приведение здесь
        final Map<String, dynamic>? goalsData = data['goals'] as Map<String, dynamic>?;
        if (goalsData != null) {
          return goalsData.map((key, value) => MapEntry(key, (value as num).toInt()));
        }
      }
      return {};
    } catch (e) {
      print("Error getting user goals: $e");
      return {};
    }
  }

  // Метод для получения истории пользователя
  Future<List<HistoryEntry>> getUserHistory() async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return [];

    try {
      final querySnapshot = await userDocRef
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(10) // Ограничьте количество загружаемых записей, если нужно
          .get();

      return querySnapshot.docs
          .map((doc) => HistoryEntry.fromMap(doc.data() as Map<String, dynamic>)) // Явное приведение
          .toList();
    } catch (e) {
      print("Error getting user history: $e");
      return [];
    }
  }

  // Метод для получения DailySummary
  Future<DailySummary?> getDailySummary(DateTime date) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return null;

    try {
      final docId = '${date.year}-${date.month}-${date.day}'; // Формат ID как в LocalRepository
      final docSnapshot = await userDocRef.collection('summaries').doc(docId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return DailySummary.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print("Error getting daily summary: $e");
      return null;
    }
  }
}