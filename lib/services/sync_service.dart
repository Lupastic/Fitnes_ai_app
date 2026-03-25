import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_repository.dart';
import '../models/daily_summary.dart';

class SyncService {
  final LocalRepository _repo;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncService(this._repo);

  Future<void> sync() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final items = _repo.unsynced();
    if (items.isEmpty) return;

    print("SyncService: Found ${items.length} items to sync.");

    for (final d in items) {
      try {
        final docId = _formatDateKey(d.date);
        await _fire
            .collection('users')
            .doc(user.uid)
            .collection('summaries')
            .doc(docId)
            .set(d.toMap(), SetOptions(merge: true));

        d.synced = true;
        await _repo.save(d); // Сохраняем обновленный статус локально
        print("SyncService: Synced data for $docId");
      } catch (e) {
        print("SyncService: Error syncing ${d.date}: $e");
      }
    }
  }

  String _formatDateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}
