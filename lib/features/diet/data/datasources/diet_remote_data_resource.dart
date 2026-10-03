import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/meal_log_model.dart';

class DietRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DietRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _logsCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('diet_logs');
  }

  DocumentReference<Map<String, dynamic>> _goalDoc(String uid) {
    return firestore.collection('users').doc(uid).collection('goals').doc('diet');
  }

  String get _uid {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found. Please login again.');
    }
    return user.uid;
  }

  Future<String> addMealLog(MealLogModel log) async {
    final collection = _logsCollection(_uid);
    final document = collection.doc();

    await document.set({
      ...log.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> deleteMealLog(String logId) async {
    await _logsCollection(_uid).doc(logId).delete();
  }

  /// Streams all meal logs for "today" (local device date).
  Stream<List<MealLogModel>> getTodayLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _logsCollection(_uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealLogModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Streams the user's custom daily calorie goal. Null if not set.
  Stream<int?> getCalorieGoal() {
    return _goalDoc(_uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return (data['calorieGoal'] as num?)?.toInt();
    });
  }

  Future<void> setCalorieGoal(int calorieGoal) async {
    await _goalDoc(_uid).set({'calorieGoal': calorieGoal}, SetOptions(merge: true));
  }
}
