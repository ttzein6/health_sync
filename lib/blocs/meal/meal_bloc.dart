import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/models/meal.dart';

import 'package:health_sync/repositories/meal_repository.dart';
part 'meal_event.dart';
part 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealRepository mealRepository;

  MealBloc(this.mealRepository) : super(MealInitial()) {
    on<MealEvent>((event, emit) async {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      if (event is LoadMeals) {
        emit(MealLoading());
        try {
          final meals = await mealRepository.getMeals(userId);
          emit(MealLoaded(meals));
        } catch (e) {
          emit(MealError(e.toString()));
        }
      } else if (event is AddMeal) {
        try {
          await mealRepository.addMeal(userId, event.meal);
        } catch (e) {
          emit(MealError(e.toString()));
        }
      }
    });
  }
}
