import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/health_data/health_data_bloc.dart';

import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/screens/meals/meal_bar_chart.dart';
import 'package:health_sync/screens/meals/meal_log_screen.dart';
import 'package:health_sync/screens/meals/meal_pie_chart.dart';
import 'package:health_sync/utils/validators.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Wrap(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Health Summary', style: TextStyle(fontSize: 24)),
                  BlocBuilder<HealthDataBloc, HealthDataState>(
                    builder: (context, state) {
                      if (state is HealthDataLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is HealthDataLoaded) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.healthData.length,
                          itemBuilder: (context, index) {
                            final data = state.healthData[index];
                            return ListTile(
                              title: Text('Health Metric: ${data.metric}'),
                              subtitle: Text('Value: ${data.value}'),
                            );
                          },
                        );
                      } else if (state is HealthDataError) {
                        return Text('Error: ${state.error}');
                      } else {
                        return const Text('No Data');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox.square(
                dimension: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Today Calories Data',
                          style: TextStyle(fontSize: 24)),
                      BlocBuilder<MealBloc, MealState>(
                        builder: (context, state) {
                          if (state is MealLoading) {
                            return const CircularProgressIndicator();
                          } else if (state is MealLoaded) {
                            if (state.meals.isEmpty) {
                              return const Text('No Data');
                            }
                            List<Meal> todayMeals = [];
                            try {
                              todayMeals = state.meals
                                  .where((element) =>
                                      element.timestamp != null &&
                                      Validators.dayIsToday(
                                          element.timestamp?.toDate()))
                                  .toList();
                            } catch (e) {
                              log("Error list: $e");
                            }
                            int todayCalories = 0;

                            for (var meal in todayMeals) {
                              todayCalories +=
                                  meal.nutritionInformation?.calories ?? 0;
                            }

                            if (todayMeals.isEmpty) return const SizedBox();
                            return Text(
                              "Total: $todayCalories",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            );
                          } else if (state is MealError) {
                            return Text('Error: ${state.error}');
                          } else {
                            return const Text('No Meals Logged');
                          }
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: BlocBuilder<MealBloc, MealState>(
                      builder: (context, state) {
                        if (state is MealLoading) {
                          return const CircularProgressIndicator();
                        } else if (state is MealLoaded) {
                          if (state.meals.isEmpty) return const Text('No Data');
                          var todayMeals = state.meals
                              .where((element) =>
                                  element.timestamp != null &&
                                  Validators.dayIsToday(
                                      element.timestamp!.toDate()))
                              .toList();
                          if (todayMeals.isEmpty) return const Text('No Data');
                          return Container(
                            height: 300,
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: MealBarChart(meals: todayMeals),
                          );
                        } else if (state is MealError) {
                          return Text('Error: ${state.error}');
                        } else {
                          return const Text('No Meals Logged');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today Meals Data',
                      style: TextStyle(fontSize: 24)),
                  BlocBuilder<MealBloc, MealState>(
                    builder: (context, state) {
                      if (state is MealLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is MealLoaded) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Builder(builder: (context) {
                            if (state.meals.isEmpty) {
                              return const Text('No Data');
                            }
                            List<Meal> todayMeals = state.meals
                                .where((element) =>
                                    element.timestamp != null &&
                                    Validators.dayIsToday(
                                        element.timestamp!.toDate()))
                                .toList();
                            if (todayMeals.isEmpty) {
                              return const Text('No Data');
                            }
                            return SizedBox(
                                height: 300,
                                child: MealPieChart(meals: todayMeals));
                          }),
                        );
                      } else if (state is MealError) {
                        return Text('Error: ${state.error}');
                      } else {
                        return const Text('No Meals Logged');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Meals', style: TextStyle(fontSize: 24)),
                  BlocBuilder<MealBloc, MealState>(
                    builder: (context, state) {
                      if (state is MealLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is MealLoaded) {
                        var meals = state.meals;
                        meals.sort(
                            (a, b) => b.timestamp!.compareTo(a.timestamp!));
                        return meals.isEmpty
                            ? const Text('No Data')
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: min(meals.length, 4),
                                itemBuilder: (context, index) {
                                  final meal = meals[index];
                                  return MealTile(meal: meal);
                                },
                              );
                      } else if (state is MealError) {
                        return Text('Error: ${state.error}');
                      } else {
                        return const Text('No Meals Logged');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
