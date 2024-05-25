// import 'package:cloud_firestore/cloud_firestore.dart';

// class Meal {
//   String? id;
//   final String? name;
//   final int? calories;
//   final List<String>? ingredients;
//   final Timestamp? timestamp;
//   final int? protein;
//   final int? fat;
//   final int? carbohydrates;
//   final String? imageUrl;
//   Meal({
//     this.id,
//     this.name,
//     this.calories,
//     this.ingredients,
//     this.timestamp,
//     this.carbohydrates,
//     this.fat,
//     this.imageUrl,
//     this.protein,
//   });

//   factory Meal.fromMap(Map<String, dynamic> data) {
//     return Meal(
//       id: data['id'],
//       name: data['name'],
//       calories: data['calories'],
//       ingredients: List<String>.from(data['ingredients']),
//       timestamp: data['timestamp'],
//       protein: data['protein'],
//       fat: data['fat'],
//       carbohydrates: data['carbohydrates'],
//       imageUrl: data['imageUrl'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'calories': calories,
//       'ingredients': ingredients,
//       'timestamp': timestamp,
//       'protein': protein,
//       'fat': fat,
//       'carbohydrates': carbohydrates,
//       'imageUrl': imageUrl,
//     };
//   }
// }
