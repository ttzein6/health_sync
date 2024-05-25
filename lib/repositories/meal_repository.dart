import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sync/models/meal.dart';

class MealRepository {
  final FirebaseFirestore _firestore;

  MealRepository() : _firestore = FirebaseFirestore.instance;

  Future<void> addMeal(String userId, Meal meal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .add(meal.toJson());
  }

  Future<List<Meal>> getMeals(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) => Meal.fromJson(doc.data())).toList();
    });
  }
}
