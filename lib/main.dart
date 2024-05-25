import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:health_sync/firebase_options.dart';
import 'package:health_sync/repositories/auth_repository.dart';
import 'package:health_sync/repositories/health_data_repository.dart';
import 'package:health_sync/repositories/meal_repository.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/blocs/health_data/health_data_bloc.dart';
import 'package:health_sync/blocs/meal/meal_bloc.dart';
import 'package:health_sync/screens/auth/login_or_register.dart';

import 'package:health_sync/screens/home/home_screen.dart';
import 'package:health_sync/services/prompt_view_model.dart';
import 'package:health_sync/utils/device_info.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';

late CameraDescription camera;
late BaseDeviceInfo deviceInfo;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();
  final healthDataRepository = HealthDataRepository();
  final mealRepository = MealRepository();
  final themeStr = await rootBundle.loadString('assets/theme/theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson);
  deviceInfo = await DeviceInfo.initialize(DeviceInfoPlugin());
  if (DeviceInfo.isPhysicalDeviceWithCamera(deviceInfo)) {
    final cameras = await availableCameras();
    camera = cameras.first;
  }
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository)..add(AppStarted()),
        ),
        BlocProvider<HealthDataBloc>(
          create: (context) => HealthDataBloc(healthDataRepository),
        ),
        BlocProvider<MealBloc>(
          create: (context) => MealBloc(mealRepository)..add(LoadMeals()),
        ),
      ],
      child: MyApp(
        themeData: theme!,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeData themeData;
  const MyApp({super.key, required this.themeData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;
  @override
  void initState() {
    const apiKey = "AIzaSyCtiI8lgkEqsdw_qnrSb27fPD0IHTr6Bu8";
    // String.fromEnvironment('API_KEY', defaultValue: 'key not found');
    // if (apiKey == 'key not found') {
    //   throw InvalidApiKey(
    //     'Key not found in environment. Please add an API key.',
    //   );
    // }

    geminiVisionProModel = GenerativeModel(
      // model: 'gemini-pro-vision',
      model: "gemini-1.5-flash-latest",
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );

    geminiProModel = GenerativeModel(
      // model: 'gemini-pro',
      model: "gemini-1.5-flash-latest",
      apiKey: const String.fromEnvironment('API_KEY'),
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PromptViewModel(
        multiModalModel: geminiVisionProModel,
        textModel: geminiProModel,
      ),
      child: MaterialApp(
        title: 'health_sync',
        // themeMode: ThemeMode.light,
        // theme: AppThemes.lightTheme,
        // darkTheme: AppThemes.darkTheme,
        theme: widget.themeData,
        home: App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  App({super.key});
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _firebaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginOrRegister();
        });
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
