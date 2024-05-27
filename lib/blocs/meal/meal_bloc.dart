import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/models/meal.dart';

import 'package:health_sync/repositories/meal_repository.dart';
part 'meal_event.dart';
part 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealRepository mealRepository;

  MealBloc(this.mealRepository) : super(MealInitial()) {
    List<Meal> meals = [];
    DocumentSnapshot? lastMeal;
    int mealsCount = 0;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    on<LoadMeals>((event, emit) async {
      emit(MealLoading());
      try {
        mealsCount = await mealRepository.getMealsCount(userId);
        log("MEAL CUONT: $mealsCount");
        (meals, lastMeal) = await mealRepository.getMeals(userId);
        emit(MealLoaded(meals));
      } catch (e) {
        emit(MealError(e.toString()));
        rethrow;
      }
    });
    on<LoadMoreMeals>((event, emit) async {
      if (mealsCount > meals.length) {
        emit(MealLoaded(meals, loadingNewMeals: true));
        List<Meal> newMeals;
        try {
          (newMeals, lastMeal) =
              await mealRepository.getMeals(userId, lastDocument: lastMeal);
          meals.addAll(newMeals);
          emit(MealLoaded(meals));
        } catch (e) {
          emit(MealLoaded(meals));
          rethrow;
        }
      }
    });
    on<AddMeal>((event, emit) async {
      try {
        await mealRepository.addMeal(userId, event.meal);
        event.callBack.call();
        add(LoadMeals());
      } catch (e) {
        emit(MealError(e.toString()));
      }
    });
    on<ResetMeals>((event, emit) {
      meals = [];
      lastMeal = null;
      mealsCount = 0;
      userId = FirebaseAuth.instance.currentUser!.uid;
      emit(MealInitial());
      add(LoadMeals());
    });
  }
}
