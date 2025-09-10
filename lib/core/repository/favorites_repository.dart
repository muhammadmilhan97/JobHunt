import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  FavoritesRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> toggleFavorite(String jobId) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _firestore.collection('favorites').doc('${uid}_$jobId');
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'jobSeekerId': uid,
        'jobId': jobId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isFavorite(String jobId) {
    final uid = _uid;
    if (uid == null) return Stream<bool>.value(false);
    final ref = _firestore.collection('favorites').doc('${uid}_$jobId');
    return ref.snapshots().map((d) => d.exists);
  }

  Stream<List<Job>> streamFavorites(String? userId) {
    final uid = userId ?? _uid;
    if (uid == null) return Stream<List<Job>>.empty();

    final favQuery = _firestore
        .collection('favorites')
        .where('jobSeekerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return favQuery.asyncMap((snapshot) async {
      final jobIds =
          snapshot.docs.map((d) => d.data()['jobId'] as String).toList();
      if (jobIds.isEmpty) return <Job>[];
      // Firestore whereIn limit 10 – chunk requests
      const batch = 10;
      final jobs = <Job>[];
      for (int i = 0; i < jobIds.length; i += batch) {
        final ids = jobIds.skip(i).take(batch).toList();
        final q = await _firestore
            .collection('jobs')
            .where(FieldPath.documentId, whereIn: ids)
            .get();
        jobs.addAll(q.docs.map((d) => Job.fromFirestore(d)));
      }
      return jobs;
    });
  }
}
