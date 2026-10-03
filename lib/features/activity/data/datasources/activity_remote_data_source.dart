import 'dart:async' show TimeoutException;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';

class ActivityRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ActivityRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  // ============================================================
  // ACTIVITIES COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> _activitiesCollection(
      String uid,
      ) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('activities');
  }

  // ============================================================
  // ADD ACTIVITY
  // ============================================================

  Future<String> addActivity(
      ActivityModel activity,
      ) async {
    debugPrint('========================================');
    debugPrint('🔥 ADD ACTIVITY STARTED');
    debugPrint('========================================');

    final user = auth.currentUser;

    // ----------------------------------------------------------
    // CHECK AUTH USER
    // ----------------------------------------------------------

    if (user == null) {
      debugPrint('❌ USER IS NOT LOGGED IN');

      throw Exception(
        'No authenticated user found. Please login again.',
      );
    }

    final uid = user.uid;

    debugPrint('✅ USER FOUND');
    debugPrint('UID: $uid');

    try {
      // --------------------------------------------------------
      // FIRESTORE COLLECTION
      // --------------------------------------------------------

      final collection = _activitiesCollection(uid);

      debugPrint(
        '📁 Collection: users/$uid/activities',
      );

      // --------------------------------------------------------
      // CREATE DOCUMENT
      // --------------------------------------------------------

      final document = collection.doc();

      debugPrint(
        '📄 Document ID: ${document.id}',
      );

      // --------------------------------------------------------
      // DATA
      // --------------------------------------------------------

      final data = {
        ...activity.toMap(),
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      debugPrint('📦 DATA READY');
      debugPrint('DATA: $data');

      // --------------------------------------------------------
      // FIRESTORE WRITE
      // --------------------------------------------------------

      debugPrint('🔥 WRITING TO FIRESTORE...');

      await document.set(data).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'Firestore write timed out after 15 seconds.',
          );
        },
      );

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      debugPrint('========================================');
      debugPrint('✅ FIRESTORE WRITE SUCCESSFUL');
      debugPrint(
        'Path: users/$uid/activities/${document.id}',
      );
      debugPrint('========================================');

      return document.id;
    } on TimeoutException catch (e) {
      debugPrint('========================================');
      debugPrint('❌ FIRESTORE TIMEOUT');
      debugPrint('❌ $e');
      debugPrint('========================================');

      throw Exception(
        'Firestore connection timed out. '
            'Please check your Firebase/Firestore configuration.',
      );
    } on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('❌ FIREBASE ERROR');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('Details: ${e.toString()}');
      debugPrint('========================================');

      throw Exception(
        'Firebase error: ${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('========================================');
      debugPrint('❌ ACTIVITY SAVE ERROR');
      debugPrint('Error: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET ACTIVITIES
  // ============================================================

  Stream<List<ActivityModel>> getActivities() {
    final user = auth.currentUser;

    if (user == null) {
      return Stream.error(
        Exception(
          'No authenticated user found. Please login again.',
        ),
      );
    }

    return _activitiesCollection(user.uid)
        .orderBy(
      'date',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs.map(
              (doc) {
            return ActivityModel.fromMap(
              doc.data(),
              doc.id,
            );
          },
        ).toList();
      },
    );
  }

  // ============================================================
  // DELETE ACTIVITY
  // ============================================================

  Future<void> deleteActivity(
      String activityId,
      ) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    await _activitiesCollection(user.uid)
        .doc(activityId)
        .delete();
  }

  // ============================================================
  // GET ACTIVITY BY ID
  // ============================================================

  Future<ActivityModel?> getActivityById(
      String activityId,
      ) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    final document = await _activitiesCollection(user.uid)
        .doc(activityId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return ActivityModel.fromMap(
      document.data()!,
      document.id,
    );
  }
}
