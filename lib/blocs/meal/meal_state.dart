part of 'meal_bloc.dart';

abstract class MealState {}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final List<Meal> meals;
  final bool loadingNewMeals;
  MealLoaded(this.meals, {this.loadingNewMeals = false});
}

class MealError extends MealState {
  final String error;
  MealError(this.error);
}
