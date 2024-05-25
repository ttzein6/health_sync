import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:health_sync/models/meal.dart';
import 'package:health_sync/models/prompt_model.dart';
import 'package:health_sync/services/firebase_service.dart';
import 'package:health_sync/services/gemini_ai_service.dart';
import 'package:health_sync/services/image_upload_service.dart';

class PromptViewModel extends ChangeNotifier {
  PromptViewModel({
    required this.multiModalModel,
    required this.textModel,
  });
  final FirebaseService firebaseService = FirebaseService();
  final ImageUploadService imageUploadService = ImageUploadService();
  final GenerativeModel multiModalModel;
  final GenerativeModel textModel;
  bool loadingNewMeal = false;

  PromptData userPrompt = PromptData.empty();
  TextEditingController promptTextController = TextEditingController();
  Meal? meal;
  String badImageFailure =
      "The meal data request either does not contain images, or does not contain images of food items. I cannot recommend a meal.";

  String? _geminiFailureResponse;
  String? get geminiFailureResponse => _geminiFailureResponse;
  set geminiFailureResponse(String? value) {
    _geminiFailureResponse = value;
    notifyListeners();
  }

  void notify() => notifyListeners();

  void addImage(File image) {
    userPrompt.image = image;
    notifyListeners();
  }

  void addAdditionalPromptContext(String text) {
    final existingInputs = userPrompt.additionalTextInputs;
    userPrompt.copyWith(additionalTextInputs: [...existingInputs, text]);
  }

  void removeImage(File image) {
    userPrompt.image = null;
    notifyListeners();
  }

  void resetPrompt() {
    userPrompt = PromptData.empty();
    notifyListeners();
  }

  // Creates an ephemeral prompt with additional text that the user shouldn't be
  // concerned with to send to Gemini, such as formatting.
  PromptData buildPrompt() {
    return PromptData(
      image: userPrompt.image,
      textInput: mainPrompt,
      additionalTextInputs: [format],
    );
  }

  Future<void> submitPrompt() async {
    loadingNewMeal = true;
    notifyListeners();
    // Create an ephemeral PromptData, preserving the user prompt data without
    // adding the additional context to it.
    var model = userPrompt.image == null ? textModel : multiModalModel;
    final prompt = buildPrompt();

    try {
      File? image = userPrompt.image;
      final content = await GeminiService.generateContent(model, prompt);
      if (kDebugMode) {
        log("promptTokenCount: ${content.usageMetadata?.promptTokenCount}");
        log("candidatesTokenCount: ${content.usageMetadata?.candidatesTokenCount}");
        log("TOTAL TOKEN COUNT: ${content.usageMetadata?.totalTokenCount}");
      }
      // handle no image or image of not-food
      if (content.text != null && content.text!.contains(badImageFailure)) {
        geminiFailureResponse = badImageFailure;
        print(geminiFailureResponse);
      } else {
        log("GENERATED CONTENT:\n${content.text}");
        try {
          meal = Meal.fromJson(jsonDecode(content.text ?? ""));
          try {
            if (image != null) {
              meal?.imageUrl = await imageUploadService.uploadImage(image);
            }
          } catch (e) {
            log("ERROR UPLOADING IMAGE: $e");
          }

          meal?.timestamp = Timestamp.now();
          meal?.id =
              "${Timestamp.now().millisecondsSinceEpoch}_${meal.hashCode}";
        } catch (e) {
          log("ERROR :\n$e");
        }
      }
    } catch (error) {
      geminiFailureResponse = 'Failed to reach Gemini. \n\n$error';
      if (kDebugMode) {
        print(error);
      }
      loadingNewMeal = false;
    }

    loadingNewMeal = false;
    resetPrompt();
    notifyListeners();
  }

  String get mainPrompt {
    return '''
You are a Cat who's a professional Nutritionist that travels around the world, and your travels inspire your knowledge of diverse cuisines and nutritional information.
Analyze the provided meal image and generate detailed meal data based on the image.
The data should include:
1. Meal name
2. Description of the meal
3. Type of cuisine
4. Calories
5. Carbohydrates
6. Protein
7. Fat

Assume the image represents one serving of the meal.

If there are no images attached, or if the image does not contain food items, respond exactly with: $badImageFailure

Ensure the meal data is based on visual cues from the image and general knowledge of typical meal compositions. Adhere to food safety and handling best practices.

${promptTextController.text.isNotEmpty ? promptTextController.text : ''}
''';
  }

  final String format = '''
Return the meal data as valid JSON using the following structure:
{
  "id": \$uniqueId,
  "title": \$mealTitle,
  "ingredients": \$ingredients,
  "description": \$description,
  "instructions": \$instructions,
  "cuisine": \$cuisineType,
  "allergens": \$allergens,
  "nutritionInformation": {
    "calories": "\$calories",
    "fat": "\$fat",
    "carbohydrates": "\$carbohydrates",
    "protein": "\$protein"
  }
}

Ensure the following data types:
- uniqueId should be unique and of type String.
- title, description, cuisine and instructions should be of String type.
- ingredients and allergens should be of List<String> type.
- nutritionInformation should be of type Map<String, int>.
Provide nutritional values in int type and without units (e.g., 30 instead of 30g).

''';
}
