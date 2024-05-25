import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String? id;
  String? title;
  List<String>? ingredients;
  String? description;
  String? instructions;
  String? cuisine;
  List<String>? allergens;
  Timestamp? timestamp;
  String? imageUrl;
  NutritionInformation? nutritionInformation;

  Meal({
    this.id,
    this.title,
    this.ingredients,
    this.description,
    this.instructions,
    this.cuisine,
    this.allergens,
    this.nutritionInformation,
    this.imageUrl,
    this.timestamp,
  });

  Meal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    ingredients = json['ingredients'].cast<String>();
    description = json['description'];
    try {
      instructions = json['instructions'];
    } catch (_) {}
    cuisine = json['cuisine'];
    allergens = json['allergens'].cast<String>();
    timestamp = json['timestamp'];
    imageUrl = json['imageUrl'];
    nutritionInformation = json['nutritionInformation'] != null
        ? NutritionInformation.fromJson(json['nutritionInformation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['ingredients'] = ingredients;
    data['description'] = description;
    data['instructions'] = instructions;
    data['cuisine'] = cuisine;
    data['allergens'] = allergens;
    data['imageUrl'] = imageUrl;
    data['timestamp'] = timestamp;
    if (nutritionInformation != null) {
      data['nutritionInformation'] = nutritionInformation!.toJson();
    }
    return data;
  }
}

class NutritionInformation {
  int? calories;
  int? fat;
  int? carbohydrates;
  int? protein;

  NutritionInformation(
      {this.calories, this.fat, this.carbohydrates, this.protein});

  NutritionInformation.fromJson(Map<String, dynamic> json) {
    calories = json['calories'];
    fat = json['fat'];
    carbohydrates = json['carbohydrates'];
    protein = json['protein'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['calories'] = calories;
    data['fat'] = fat;
    data['carbohydrates'] = carbohydrates;
    data['protein'] = protein;
    return data;
  }
}
