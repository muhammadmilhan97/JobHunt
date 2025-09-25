import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _docPath = 'config/app';

  static Future<Map<String, dynamic>> fetchSettings() async {
    final doc = await _firestore.doc(_docPath).get();
    return doc.data() ?? {};
  }

  static Future<void> updateSettings(Map<String, dynamic> updates) async {
    await _firestore.doc(_docPath).set(updates, SetOptions(merge: true));
  }
}
