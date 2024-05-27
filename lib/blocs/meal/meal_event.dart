part of 'meal_bloc.dart';

abstract class MealEvent {}

class LoadMeals extends MealEvent {}

class AddMeal extends MealEvent {
  final Meal meal;
  final Function() callBack;
  AddMeal(this.meal, this.callBack);
}

class LoadMoreMeals extends MealEvent {}

class ResetMeals extends MealEvent {}
