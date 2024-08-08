import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/blocs/health_data/health_data_bloc.dart';

import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/screens/health/health_summary_screen.dart';
import 'package:health_sync/screens/meals/meal_bar_chart.dart';
import 'package:health_sync/screens/meals/meal_log_screen.dart';
import 'package:health_sync/screens/meals/meal_pie_chart.dart';
import 'package:health_sync/utils/validators.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          shrinkWrap: false,
          slivers: [
            SliverAppBar(
              centerTitle: true,
              stretch: false,
              floating: true,
              snap: true,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: Image.asset(
                    'assets/icons/icon.png',
                  ).image,
                ),
              ),
              elevation: 0,
              expandedHeight: 120,
              forceMaterialTransparency: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                          "Hello, ${context.watch<AuthBloc>().user?.name ?? ""} "),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          context.watch<AuthBloc>().user?.imageUrl ?? "",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Opacity(
                              opacity:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : 1,
                              child: const Icon(
                                Icons.account_circle_outlined,
                                size: 40,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.account_circle_outlined);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              primary: true,
              flexibleSpace: FlexibleSpaceBar(
                //  Theme.of(context).scaffoldBackgroundColor,
                title: Text(
                  "Dashboard",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  BlocBuilder<HealthDataBloc, HealthDataState>(
                    builder: (context, state) {
                      return state is HealthDataLoaded
                          ? getCaloriesCard(
                              context, state.activeEnergyBurnedToday)
                          : const CircularProgressIndicator.adaptive();
                    },
                  ),
                  const SizedBox(height: 15),
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
                                return const SizedBox();
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
                              return const CircularProgressIndicator.adaptive();
                            } else if (state is MealLoaded) {
                              if (state.meals.isEmpty) {
                                return const Text('No Data');
                              }
                              var todayMeals = state.meals
                                  .where((element) =>
                                      element.timestamp != null &&
                                      Validators.dayIsToday(
                                          element.timestamp!.toDate()))
                                  .toList();
                              if (todayMeals.isEmpty) {
                                return const Text('No Data');
                              }
                              return Container(
                                height: 300,
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
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
                            return const CircularProgressIndicator.adaptive();
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
                      const Text('Latest Meals',
                          style: TextStyle(fontSize: 24)),
                      BlocBuilder<MealBloc, MealState>(
                        builder: (context, state) {
                          if (state is MealLoading) {
                            return const CircularProgressIndicator.adaptive();
                          } else if (state is MealLoaded) {
                            var meals = state.meals;
                            meals.sort(
                                (a, b) => b.timestamp!.compareTo(a.timestamp!));
                            return meals.isEmpty
                                ? const Text('No Data')
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
            )
          ],
        ),
      ),
    );
  }
}
