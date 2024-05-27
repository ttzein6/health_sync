import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/services/prompt_view_model.dart';
import 'package:health_sync/utils/extensions.dart';
import 'package:health_sync/widgets/add_image_to_prompt.dart';

class AddMealGemini extends StatefulWidget {
  const AddMealGemini({super.key});

  @override
  State<AddMealGemini> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddMealGemini> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PromptViewModel>();
    isLoading = viewModel.loadingNewMeal;
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add Meal Using AI"),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(
                  8,
                ),
                child: SizedBox(
                  height: constraints.isMobile ? 150 : 230,
                  child: AddImageToPromptWidget(
                    height: constraints.isMobile ? 100 : 200,
                    width: constraints.isMobile ? 100 : 200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _TextField(
                  controller: viewModel.promptTextController,
                  onChanged: (value) {
                    viewModel.notify();
                  },
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : ElevatedButton(
                      onPressed: () async {
                        await viewModel.submitPrompt().then((_) async {
                          if (viewModel.meal != null) {
                            var mealBloc = BlocProvider.of<MealBloc>(context);
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  BlocProvider<MealBloc>.value(
                                value: mealBloc,
                                child: MealDetail(
                                  meal: viewModel.meal!,
                                ),
                              ),
                            );
                          }
                        });
                      },
                      child: const Icon(
                        Icons.insights,
                      ),
                    )
            ],
          ),
        ),
      );
    });
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final Null Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      scrollPadding: const EdgeInsets.only(bottom: 150),
      maxLines: null,
      onChanged: onChanged,
      minLines: 3,
      controller: controller,
      // style: WidgetStateTextStyle.resolveWith(
      //     (states) => MarketplaceTheme.dossierParagraph),
      decoration: InputDecoration(
        fillColor: Theme.of(context).splashColor,
        hintText: "Add additional context...",
        // hintStyle: WidgetStateTextStyle.resolveWith(
        //   (states) => MarketplaceTheme.dossierParagraph,
        // ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.black45),
        ),
        filled: true,
      ),
    );
  }
}

class MealDetail extends StatelessWidget {
  final Meal meal;

  const MealDetail({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.title ?? 'Meal Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                meal.title ?? 'No Title',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Description: ${meal.description ?? 'No Description'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Cuisine: ${meal.cuisine ?? 'No Cuisine'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...?meal.ingredients?.map((ingredient) => Text(ingredient)),
              // const SizedBox(height: 10),
              // const Text(
              //   'Instructions:',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              // ...?meal.instructions?.map((instruction) => Text(instruction)),
              const SizedBox(height: 10),
              const Text(
                'Allergens:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...?meal.allergens?.map((allergen) => Text(allergen)),
              const SizedBox(height: 10),
              if (meal.nutritionInformation != null) ...[
                const Text(
                  'Nutrition Information:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Calories: ${meal.nutritionInformation!.calories ?? "0"}'),
                Text('Fat: ${meal.nutritionInformation!.fat ?? "0"}g'),
                Text(
                    'Carbohydrates: ${meal.nutritionInformation!.carbohydrates ?? "0"}g'),
                Text('Protein: ${meal.nutritionInformation!.protein ?? "0"}g'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        fixedSize: MaterialStatePropertyAll(Size(200, 50))),
                    onPressed: () async {
                      var navState = Navigator.of(context);
                      // final userId = FirebaseAuth.instance.currentUser!.uid;
                      BlocProvider.of<MealBloc>(context).add(AddMeal(meal, () {
                        context.read<PromptViewModel>().meal = null;
                        context
                            .read<PromptViewModel>()
                            .promptTextController
                            .clear();
                        context.read<PromptViewModel>().resetPrompt();
                        navState.pop();
                        navState.pop();
                      }));
                      // await FirebaseFirestore.instance
                      //     .collection('users')
                      //     .doc(userId)
                      //     .collection('meals')
                      //     .doc(meal.id)
                      //     .set(meal.toJson())
                      //     .whenComplete(() {
                      //   BlocProvider.of<MealBloc>(navState.context)
                      //       .add(LoadMeals());
                      //   context.read<PromptViewModel>().meal = null;
                      //   context
                      //       .read<PromptViewModel>()
                      //       .promptTextController
                      //       .clear();
                      //   context.read<PromptViewModel>().resetPrompt();
                      //   navState.pop();
                      //   navState.pop();
                      // });
                    },
                    child: const Text("Add meal"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
