import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Static cache to store user data in memory
  static Map<String, dynamic>? _cachedUserData;
  static Map<String, dynamic>? get cachedUserData => _cachedUserData;

  // Gets the current logged-in user's ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Reusable function to save data to the user's specific document
  Future<void> createOrUpdateUserData(Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    // Clear cache to force refresh on next fetch
    _cachedUserData = null;
  }

  // Reusable function to fetch user data with caching
  Future<Map<String, dynamic>?> getUserData({bool forceRefresh = false}) async {
    if (_cachedUserData != null && !forceRefresh) {
      return _cachedUserData;
    }

    final uid = currentUid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    _cachedUserData = doc.data();
    return _cachedUserData;
  }

  // Example: Saving Medical Info to a sub-collection
  Future<void> addDiagnosis(String conditionName) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('diagnoses').add({
      'name': conditionName,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
