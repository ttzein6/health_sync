part of 'meal_bloc.dart';

abstract class MealEvent {}

class LoadMeals extends MealEvent {}

class AddMeal extends MealEvent {
  final Meal meal;
  AddMeal(this.meal);
}
