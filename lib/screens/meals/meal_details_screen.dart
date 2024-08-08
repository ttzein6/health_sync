import 'package:flutter/material.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/utils/common_functions.dart';
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
                  Center(
                    child: Text(
                      '${meal.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (meal.imageUrl != null &&
                      meal.imageUrl?.isNotEmpty == true)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: GestureDetector(
                              onTap: () => CommonFunctions.onImageTap(
                                  context, meal.imageUrl ?? ""),
                              child: Hero(
                                tag: meal.imageUrl ?? meal.id!,
                                child: Image.network(
                                  meal.imageUrl!,
                                  fit: BoxFit.fitWidth,
                                  frameBuilder: (context, child, frame,
                                          wasSynchronouslyLoaded) =>
                                      Container(
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (meal.nutritionInformation?.calories != null)
                        NutritionFactsWidget(
                          unit: 'Calories',
                          value: (meal.nutritionInformation?.calories ?? 0)
                              .toString(),
                        ),
                      const SizedBox(
                        width: 16,
                      ),
                      if (meal.nutritionInformation?.protein != null)
                        NutritionFactsWidget(
                          unit: 'Protein',
                          value: '${meal.nutritionInformation?.protein}g',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (meal.nutritionInformation?.fat != null)
                        NutritionFactsWidget(
                          unit: 'Fat',
                          value: '${meal.nutritionInformation?.fat}g',
                        ),
                      const SizedBox(width: 16),
                      if (meal.nutritionInformation?.carbohydrates != null)
                        NutritionFactsWidget(
                          unit: 'Carbs',
                          value: '${meal.nutritionInformation?.carbohydrates}g',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (meal.ingredients != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "Ingredients",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Wrap(
                          children: [
                            for (var ing in meal.ingredients!)
                              IngerdientWidget(
                                text: ing,
                              ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (meal.timestamp != null)
                    Text(
                      'Time: ${DateFormat("dd-MM-yyyy HH:mm:ss").format(meal.timestamp!.toDate())}',
                      // style: const TextStyle(fontSize: 16),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 16),
                  if (meal.description != null)
                    const Text(
                      "Description",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  if (meal.description != null)
                    Text('${meal.description}',
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

class NutritionFactsWidget extends StatelessWidget {
  const NutritionFactsWidget(
      {super.key, required this.value, required this.unit});
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black45)),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              )),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class IngerdientWidget extends StatelessWidget {
  const IngerdientWidget({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
