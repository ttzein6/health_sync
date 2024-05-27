import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/models/prompt_model.dart';
import 'package:health_sync/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbohydratesController =
      TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  final TextEditingController _allergensController = TextEditingController();
  final TextEditingController promptTextController = TextEditingController();

  PromptData userPrompt = PromptData.empty();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImageUploadService.selectImage();
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _submit() async {
    var navState = Navigator.of(context);
    if (_formKey.currentState?.validate() == true) {
      showDialog(
        context: navState.context,
        builder: (context) => const Dialog.fullscreen(
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );

      String imageUrl = "";
      if (_image != null) {
        try {
          imageUrl = await ImageUploadService().uploadImage(_image!);
        } catch (_) {}
      }

      try {
        var meal = Meal(
          id: null,
          title: _nameController.text,
          nutritionInformation: NutritionInformation(
            calories: int.parse(_caloriesController.text),
            protein: int.parse(_proteinController.text),
            fat: int.parse(_fatController.text),
            carbohydrates: int.parse(_carbohydratesController.text),
          ),
          allergens: _allergensController.text
              .split(',')
              .map((s) => s.trim())
              .toList(),
          description: _descController.text,
          ingredients: _ingredientsController.text
              .split(',')
              .map((s) => s.trim())
              .toList(),
          timestamp: Timestamp.now(),
          imageUrl: imageUrl,
        );
        meal.id = "${Timestamp.now().millisecondsSinceEpoch}_${meal.hashCode}";
        BlocProvider.of<MealBloc>(navState.context).add(AddMeal(meal, () {
          navState.pop();
          navState.pop();
        }));
      } catch (e) {
        navState.pop();
        showDialog(
          context: navState.context,
          builder: (context) => AlertDialog.adaptive(
            title: const Text("Adding meal failed"),
            content: const Text("try again later"),
            actions: [
              TextButton(
                onPressed: () {
                  navState.pop();
                },
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: navState.context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text("Adding meal failed"),
          content: const Text("Fill required fields"),
          actions: [
            TextButton(
              onPressed: () {
                navState.pop();
              },
              child: const Text("Ok"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close)),
        title: const Text('Add Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _image == null
                  ? const Text('No image selected.')
                  : Align(
                      child: Image.file(
                        File(_image?.path ?? ""),
                        width: 200,
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descController,
                decoration:
                    const InputDecoration(labelText: 'Meal Description'),
                validator: (value) {
                  return null;
                },
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the calorie count';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the protein content';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fat content';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _carbohydratesController,
                decoration:
                    const InputDecoration(labelText: 'Carbohydrates (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the carbohydrate content';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _allergensController,
                decoration: const InputDecoration(
                    labelText: 'Allergens (comma separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the allergens';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Ingredients (comma separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ingredients';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
