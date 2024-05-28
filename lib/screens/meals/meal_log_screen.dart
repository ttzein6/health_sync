import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/screens/meals/add_meal_gemini.dart';
import 'package:health_sync/screens/meals/add_meal_screen.dart';
import 'package:health_sync/screens/meals/meal_details_screen.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  late MealBloc mealBloc;
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      mealBloc = BlocProvider.of<MealBloc>(context)..add(LoadMeals());
      _scrollController.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreMeals();
    }
  }

  _fetchMoreMeals() {
    mealBloc.add(LoadMoreMeals());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Log')),
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        activeBackgroundColor: Theme.of(context).colorScheme.onBackground,
        foregroundColor: Theme.of(context).colorScheme.primary,
        // activeForegroundColor: Colors.black,
        // animatedIconTheme: IconThemeData(),
        spacing: 20,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            label: "Add meal",
            child: const Icon(Icons.format_align_center),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => BlocProvider<MealBloc>.value(
                  value: mealBloc,
                  child: const AddMealScreen(),
                ),
              ),
            ),
          ),
          SpeedDialChild(
            label: "Add meal using AI",
            child: const Icon(Icons.memory),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => BlocProvider<MealBloc>.value(
                  value: mealBloc,
                  child: const AddMealGemini(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async =>
            BlocProvider.of<MealBloc>(context).add(LoadMeals()),
        child: BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state is MealLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (state is MealLoaded) {
              final todayMeals = <Meal>[];
              final yesterdayMeals = <Meal>[];
              final otherMeals = <Meal>[];

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final yesterday = today.subtract(const Duration(days: 1));

              for (final meal in state.meals) {
                final mealDate = meal.timestamp!.toDate();
                final mealDay =
                    DateTime(mealDate.year, mealDate.month, mealDate.day);

                if (mealDay == today) {
                  todayMeals.add(meal);
                } else if (mealDay == yesterday) {
                  yesterdayMeals.add(meal);
                } else {
                  otherMeals.add(meal);
                }
              }
              if (todayMeals.isEmpty &&
                  yesterdayMeals.isEmpty &&
                  otherMeals.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: 0.8 * MediaQuery.sizeOf(context).height,
                      child: const Center(child: Text('No Meals Logged')),
                    )),
                  ],
                );
              }
              return ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (todayMeals.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Today\'s Meals',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...todayMeals.map((meal) => MealTile(meal: meal)),
                  ],
                  if (yesterdayMeals.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Yesterday\'s Meals',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...yesterdayMeals.map((meal) => MealTile(meal: meal)),
                  ],
                  if (otherMeals.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Other Meals',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...otherMeals.map((meal) => MealTile(meal: meal)),
                  ],
                  if (state.loadingNewMeals)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                ],
              );
            } else if (state is MealError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: Text('No Meals Logged')),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MealTile extends StatelessWidget {
  final Meal meal;
  const MealTile({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => MealDetailsScreen(meal: meal)));
      },
      leading: meal.imageUrl == null || meal.imageUrl?.isEmpty == true
          ? null
          : SizedBox.square(
              dimension: 50,
              child: CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(meal.imageUrl!),
              ),
            ),
      title: Text(meal.title ?? ""),
      subtitle: Text('Calories: ${meal.nutritionInformation?.calories}'),
    );
  }
}
