import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application.dart';

class ApplicationsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ApplicationsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<Application>> streamForSeeker(String? userId) {
    final uid = userId ?? _uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('applications')
        .where('jobSeekerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Stream<List<Application>> streamForJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Future<Application?> getById(String id) async {
    try {
      final doc = await _firestore.collection('applications').doc(id).get();
      if (doc.exists) {
        return Application.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get application by ID: $e');
    }
  }

  /// Get all applications for an employer across all their jobs
  Stream<List<Application>> streamForEmployer(String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Future<void> updateStatus(String applicationId, String newStatus) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }
}
