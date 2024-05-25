import 'package:flutter/material.dart';
import 'package:health_sync/models/meal.dart';
import 'package:intl/intl.dart';

class MealDetailsScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meal Name: ${meal.title}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (meal.imageUrl != null &&
                      meal.imageUrl?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.network(
                        meal.imageUrl!,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  if (meal.nutritionInformation?.calories != null)
                    Text('Calories: ${meal.nutritionInformation?.calories}',
                        style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  if (meal.ingredients != null)
                    Text('Ingredients: ${meal.ingredients?.join(', ')}',
                        style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if (meal.nutritionInformation?.protein != null)
                    Text('Protein: ${meal.nutritionInformation?.protein}g',
                        style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if (meal.nutritionInformation?.fat != null)
                    Text('Fat: ${meal.nutritionInformation?.fat}g',
                        style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if (meal.nutritionInformation?.carbohydrates != null)
                    Text(
                        'Carbohydrates: ${meal.nutritionInformation?.carbohydrates}g',
                        style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if (meal.timestamp != null)
                    Text(
                        'Time: ${DateFormat("dd-MM-yyyy HH:mm:ss").format(meal.timestamp!.toDate())}',
                        style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
