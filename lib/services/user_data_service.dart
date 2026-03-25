import 'dart:convert';
import 'package:crypto/crypto.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../models/history_entry.dart';
import '../models/daily_summary.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String formatDateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  DocumentReference? getUserDocRef() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> updateProfileData({
    String? name,
    Map<String, int>? goals,
    String? languageCode,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    int? age,
    String? goalType,
    String? pinCode,
    List<String>? selectedChallenges,
    List<String>? completedQuests,
    int? points,
  }) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return;

    final Map<String, dynamic> dataToUpdate = {};
    if (name != null) dataToUpdate['name'] = name;
    if (goals != null) dataToUpdate['goals'] = goals;
    // Используем 'languageCode' для консистентности с провайдером
    if (languageCode != null) dataToUpdate['languageCode'] = languageCode;
    if (weight != null) dataToUpdate['weight'] = weight;
    if (weightUnit != null) dataToUpdate['weightUnit'] = weightUnit;
    if (height != null) dataToUpdate['height'] = height;
    if (heightUnit != null) dataToUpdate['heightUnit'] = heightUnit;
    if (age != null) dataToUpdate['age'] = age;
    if (goalType != null) dataToUpdate['goalType'] = goalType;
    
    if (pinCode != null) {
      dataToUpdate['pinCode'] = _hashPin(pinCode);
    }
    
    if (selectedChallenges != null) dataToUpdate['selectedChallenges'] = selectedChallenges;
    if (completedQuests != null) dataToUpdate['completedQuests'] = completedQuests;
    if (points != null) dataToUpdate['points'] = points;

    try {
      await userDocRef.set(dataToUpdate, SetOptions(merge: true));
      developer.log("Profile updated successfully with languageCode: $languageCode", name: "UserDataService");
    } catch (e, stackTrace) {
      developer.log("Error updating profile", error: e, stackTrace: stackTrace, name: "UserDataService");
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => {
        'name': doc.data()['name'] ?? 'Anonymous',
        'points': doc.data()['points'] ?? 0,
        'uid': doc.id,
      }).toList();
    } catch (e) {
      developer.log("Error fetching leaderboard", error: e);
      return [];
    }
  }

  Future<void> saveDailySummary(DailySummary summary) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return;
    try {
      final docId = formatDateKey(summary.date);
      await userDocRef.collection('summaries').doc(docId).set(summary.toMap(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      developer.log("Error saving summary", error: e, stackTrace: stackTrace, name: "UserDataService");
    }
  }

  Future<DailySummary?> getDailySummary(DateTime date) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return null;
    try {
      final docId = formatDateKey(date);
      final doc = await userDocRef.collection('summaries').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return DailySummary.fromMap(doc.data()!);
      }
    } catch (e, stackTrace) {
      developer.log("Error fetching summary", error: e, stackTrace: stackTrace, name: "UserDataService");
    }
    return null;
  }

  Future<List<DailySummary>> getSummariesForLastDays(int days) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return [];
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      final querySnapshot = await userDocRef
          .collection('summaries')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(startDate.year, startDate.month, startDate.day)))
          .get();
      
      Map<String, DailySummary> grouped = {};
      for (var doc in querySnapshot.docs) {
        final summary = DailySummary.fromMap(doc.data());
        final key = formatDateKey(summary.date);
        if (grouped.containsKey(key)) {
          final existing = grouped[key]!;
          grouped[key] = DailySummary(
            date: existing.date,
            waterCups: existing.waterCups + summary.waterCups,
            steps: existing.steps + summary.steps,
            calories: existing.calories + summary.calories,
            sleepHours: existing.sleepHours + summary.sleepHours,
          );
        } else {
          grouped[key] = summary;
        }
      }
      final list = grouped.values.toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    } catch (e, stackTrace) {
      developer.log("Error fetching range", error: e, stackTrace: stackTrace, name: "UserDataService");
      return [];
    }
  }

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return;
    try {
      await userDocRef.collection('history').add(entry.toMap());
    } catch (e, stackTrace) {
      developer.log("Error adding history entry", error: e, stackTrace: stackTrace, name: "UserDataService");
    }
  }

  Future<List<HistoryEntry>> getUserHistory() async {
    final userDocRef = getUserDocRef();
    if (userDocRef == null) return [];
    try {
      final snapshot = await userDocRef.collection('history').orderBy('timestamp', descending: true).limit(10).get();
      return snapshot.docs.map((doc) => HistoryEntry.fromMap(doc.data())).toList();
    } catch (e, stackTrace) {
      developer.log("Error fetching history", error: e, stackTrace: stackTrace, name: "UserDataService");
      return [];
    }
  }
}
