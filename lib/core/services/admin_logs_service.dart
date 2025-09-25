import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLogsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamLogs({
    int limit = 50,
  }) {
    return _firestore
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}


