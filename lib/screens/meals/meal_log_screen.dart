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
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      mealBloc = BlocProvider.of<MealBloc>(context)..add(LoadMeals());
    });
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
            onTap: () => showDialog(
              context: context,
              builder: (context) => const Dialog.fullscreen(
                child: AddMealScreen(),
              ),
            ),
          ),
          SpeedDialChild(
            label: "Add meal using AI",
            child: const Icon(Icons.memory),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () => showDialog(
              context: context,
              builder: (context) => const Dialog.fullscreen(
                child: AddMealGemini(),
              ),
            ),
          ),
        ],
      ),
      // FloatingActionButton.small(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (context) => Dialog.fullscreen(
      //         child: AddMealScreen(),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async =>
            BlocProvider.of<MealBloc>(context).add(LoadMeals()),
        child: BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state is MealLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MealLoaded) {
              return ListView.builder(
                itemCount: state.meals.length,
                itemBuilder: (context, index) {
                  final meal = state.meals[index];
                  return MealTile(meal: meal);
                },
              );
            } else if (state is MealError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const Center(child: Text('No Meals Logged'));
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
