import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sync/models/meal.dart';

class MealRepository {
  final FirebaseFirestore _firestore;

  MealRepository() : _firestore = FirebaseFirestore.instance;

  Future<void> addMeal(String userId, Meal meal) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    CollectionReference<Meal> mealsCol = userDoc
        .collection('meals')
        .withConverter<Meal>(
            fromFirestore: (snapshot, _) =>
                Meal.fromJson(snapshot.data() ?? {}),
            toFirestore: (meal, _) => meal.toJson());
    return await mealsCol.doc(meal.id!).set(meal);
  }

  Future<int> getMealsCount(String userId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    CollectionReference<Meal> mealsCol = userDoc
        .collection('meals')
        .withConverter<Meal>(
            fromFirestore: (snapshot, _) =>
                Meal.fromJson(snapshot.data() ?? {}),
            toFirestore: (meal, _) => meal.toJson());
    return await mealsCol.count().get().then((value) => value.count ?? 0);
  }

  Future<(List<Meal>, DocumentSnapshot? lastMeal)> getMeals(String userId,
      {DocumentSnapshot? lastDocument, int limit = 15}) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    CollectionReference<Meal> mealsCol = userDoc
        .collection('meals')
        .withConverter<Meal>(
            fromFirestore: (snapshot, _) =>
                Meal.fromJson(snapshot.data() ?? {}),
            toFirestore: (meal, _) => meal.toJson());
    Query<Meal> query =
        mealsCol.orderBy('timestamp', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot<Meal> snapshot =
        await query.get().then((value) => value).catchError((e) => throw e);

    return (
      snapshot.docs.map((e) => e.data()).toList(),
      snapshot.docs.lastOrNull
    );
  }
}
