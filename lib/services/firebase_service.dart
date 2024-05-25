import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sync/models/health_data.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/models/meal_old.dart';
import 'package:health_sync/models/user.dart';

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
    QuerySnapshot snapshot = await _firestore
        .collection('meals')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(
            (doc) => Meal.fromJson((doc.data() as Map<String, dynamic>?) ?? {}))
        .toList();
  }
}
