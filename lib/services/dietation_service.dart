part of 'firebase_service.dart';

enum DietationServiceStatus {
  loading,
  ready,
}

class DietationService {
  DietationServiceStatus status = DietationServiceStatus.loading;
  final AuthBloc authBloc;
  ChatSession? _chatSession;

  DietationService({
    required this.authBloc,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ImageUploadService imageUploadService = ImageUploadService();
  static String apiKey =
      // const String.fromEnvironment('API_KEY',
      //     defaultValue:
      //         'key not found');
      "AIzaSyCtiI8lgkEqsdw_qnrSb27fPD0IHTr6Bu8";
  final GenerativeModel geminiModel = GenerativeModel(
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

  Future<void> initializeChat() async {
    try {
      List<Content> history = [];
      List<Message> messages = await getChatMessages().first;
      Directory docsDir = await getApplicationDocumentsDirectory();
      String path = "${docsDir.path}/DietationImages";

      // Ensure the directory exists
      Directory(path).createSync(recursive: true);

      log("INITIALIZE CHAT $path");

      for (var message in messages) {
        if (message.imageUrl != null &&
            messages.indexOf(message) < 3 &&
            messages.indexOf(message) > messages.length - 3) {
          // Extract file name from URL
          Uri uri = Uri.parse(message.imageUrl!);
          // String fileName = uri.pathSegments.last;
          String fileName = uri.pathSegments.last.replaceAll('/', '');
          String filePath = "$path/$fileName";

          File file = File(filePath);
          if (!(await file.exists())) {
            await file.writeAsBytes(await http.readBytes(uri));
            log("FILE $filePath downloaded");
          }
          history.add(Content(
            message.isAi ? 'model' : 'user',
            [
              DataPart('image/jpeg', file.readAsBytesSync()),
              TextPart(message.content),
            ],
          ));
        } else {
          history.add(Content(
            message.isAi ? 'model' : 'user',
            [TextPart(message.content)],
          ));
        }
      }

      log("INITIALIZE HISTORY ${history.length}");
      _chatSession = geminiModel.startChat(history: history);
      if (_chatSession != null) {
        log("CHAT SESSION INITIALIZED: ${_chatSession?.history}");
        status = DietationServiceStatus.ready;
      } else {
        log("ERROR: Chat session initialization failed.");
      }
    } catch (e) {
      log("ERROR INITIALIZING CHAT: $e");
    }
  }

  Stream<List<Message>> getChatMessages() {
    DocumentReference userDoc =
        _firestore.collection('users').doc(_auth.currentUser!.uid);
    CollectionReference<Message> chatRef =
        userDoc.collection('dietation').withConverter<Message>(
              fromFirestore: (snapshot, _) =>
                  Message.fromMap(snapshot.data() ?? {}),
              toFirestore: (message, _) => message.toMap(),
            );
    return chatRef.orderBy('timestamp', descending: true).snapshots().map(
          (querySnapshot) => querySnapshot.docs.map((e) => e.data()).toList(),
        );
  }

  Future<void> sendMessage(Message message,
      {File? image, bool isAi = false}) async {
    DocumentReference userDoc =
        _firestore.collection('users').doc(_auth.currentUser!.uid);
    CollectionReference<Message> chatRef =
        userDoc.collection('dietation').withConverter<Message>(
              fromFirestore: (snapshot, _) =>
                  Message.fromMap(snapshot.data() ?? {}),
              toFirestore: (message, _) => message.toMap(),
            );

    if (image != null) {
      try {
        Directory docsDir = await getApplicationDocumentsDirectory();
        String path = "${docsDir.path}/DietationImages";

        // Ensure the directory exists
        try {
          Directory(path).createSync(recursive: true);
        } catch (_) {}
        String imageUrl = await imageUploadService.uploadImage(image);
        Uri uri = Uri.parse(imageUrl);
        // String fileName = uri.pathSegments.last;
        String fileName = uri.pathSegments.last.replaceAll('/', '');
        String filePath = "$path/$fileName";
        File file = File(filePath);
        if (!(await file.exists())) {
          await file.writeAsBytes(await image.readAsBytes());
          log("FILE $filePath downloaded");
        }
        message = message.copyWith(imageUrl: imageUrl);
      } catch (e) {
        log("ERROR UPLOADING IMAGE TO FB STORAGE:\n$e");
      }
    }

    await chatRef.add(message).then((value) async {
      if (!isAi) await askDietation(message, image: image);
    });
  }

  Future<void> askDietation(Message message, {File? image}) async {
    if (_chatSession == null) {
      log("Chat session is not initialized.");
      return;
    }

    User user = authBloc.user!;
    String prompt = preparePrompt(user, message.content);

    GenerateContentResponse result =
        await _chatSession!.sendMessage(Content('user', [
      if (image != null) DataPart('image/jpeg', image.readAsBytesSync()),
      TextPart(prompt),
    ]));

    log("RESULT: ${result.text}");
    if (result.text != null) {
      Message aiMessage = Message(
        content: result.text!,
        messageType: MessageType.text,
        timestamp: Timestamp.now(),
        isAi: true,
      );
      await sendMessage(aiMessage, isAi: true);
    }
  }

  String preparePrompt(User user, String query) {
    DietationPromptModel dietationPromptModel = DietationPromptModel();
    return dietationPromptModel.mainPrompt.replaceAll("\$query", query);
  }
}
