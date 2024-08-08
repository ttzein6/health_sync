import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/models/health_data.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/models/message.dart';
import 'package:health_sync/models/user.dart';
import 'package:health_sync/services/dietation_prompt_model.dart';
import 'package:health_sync/services/image_upload_service.dart';
import 'package:path_provider/path_provider.dart';
part 'dietation_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<User> getUser(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    return User.fromMap((doc.data() as Map<String, dynamic>?) ?? {});
  }

  Future<void> addHealthData(HealthData healthData) async {
    await _firestore.collection('health_data').add(healthData.toMap());
  }

  Future<List<HealthData>> getHealthData(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('health_data')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            HealthData.fromMap((doc.data() as Map<String, dynamic>?) ?? {}))
        .toList();
  }

  Future<void> addMeal(Meal meal) async {
    await _firestore.collection('meals').add(meal.toJson());
  }

  Future<List<Meal>> getMeals(String userId) async {
    Query query = _firestore
        .collection('meals')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(5);
    QuerySnapshot snapshot = await query.get();

    return snapshot.docs
        .map(
            (doc) => Meal.fromJson((doc.data() as Map<String, dynamic>?) ?? {}))
        .toList();
  }
}
