import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/models/message.dart';
import 'package:health_sync/services/firebase_service.dart';
import 'package:health_sync/widgets/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';

class DietationScreen extends StatefulWidget {
  const DietationScreen({super.key});

  @override
  State<DietationScreen> createState() => _DietationScreenState();
}

class _DietationScreenState extends State<DietationScreen> {
  final TextEditingController messageController = TextEditingController();
  late DietationService dietationService;
  @override
  void initState() {
    dietationService = DietationService(authBloc: context.read<AuthBloc>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/ai.png',
              width: 24,
              height: 24,
            ),
            const Flexible(child: Text("AI Dietation")),
          ],
        ),
      ),
      body: FutureBuilder(
          future: dietationService.initializeChat(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  child: getMessagesList(),
                ),
                getMessageWidget(),
              ],
            );
          }),
    );
  }

  Widget getMessagesList() {
    return StreamBuilder(
      stream: dietationService.getChatMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data?.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            var message = snapshot.data!.elementAt(index);
            // return ListTile(
            //   title: Text(message.content),
            // );
            return ChatBubble(
                showUserImage: true, message: message, isSender: !message.isAi);
          },
        );
      },
    );
  }

  Widget getMessageWidget() {
    ImagePicker imagePicker = ImagePicker();
    bool showIcons = true;
    XFile? pickedImage;
    bool loadingSendMessage = false;
    FocusNode focusNode = FocusNode();
    return SafeArea(
      child: StatefulBuilder(
        builder: (context, setBuilderState) {
          messageController.addListener(() {
            if (messageController.text.isEmpty && showIcons == false) {
              setBuilderState(() {
                showIcons = true;
              });
            }
            if (messageController.text.isNotEmpty && showIcons == true) {
              setBuilderState(() {
                showIcons = false;
              });
            }
          });
          return Column(
            children: [
              if (loadingSendMessage)
                const Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/icons/icon.png'),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: LoadingIndicator(
                            indicatorType: Indicator.pacman) //indicator
                        )
                  ],
                ),
              Padding(
                padding: MediaQuery.viewInsetsOf(context).copyWith(
                  bottom: MediaQuery.viewInsetsOf(context).bottom + 10,
                ),
                child: Row(
                  children: [
                    if (showIcons)
                      IconButton(
                        onPressed: () async {
                          await imagePicker
                              .pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          )
                              .then((imageXFile) {
                            log("Image picked : ${imageXFile?.path}");
                            setBuilderState(() {
                              pickedImage = imageXFile;
                            });
                          });
                        },
                        icon: const Icon(Icons.camera_alt),
                      ),
                    if (showIcons)
                      IconButton(
                        onPressed: () async {
                          await imagePicker
                              .pickImage(source: ImageSource.gallery)
                              .then((imageXFile) {
                            log("Image picked : ${imageXFile?.path}");
                            setBuilderState(() {
                              pickedImage = imageXFile;
                            });
                          });
                        },
                        icon: const Icon(Icons.image_outlined),
                      ),
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromRGBO(233, 233, 233, 1),
                          ),
                          child: Column(
                            children: [
                              if (pickedImage != null)
                                Container(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.8),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setBuilderState(() {
                                            pickedImage = null;
                                          });
                                        },
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 100,
                                            maxWidth: 100,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Image.file(
                                                File(pickedImage!.path),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setBuilderState(() {
                                                      pickedImage = null;
                                                    });
                                                  },
                                                  icon: const Icon(Icons.close),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        maxLength: 250,
                                        focusNode: focusNode,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        buildCounter: (context,
                                                {required currentLength,
                                                required isFocused,
                                                required maxLength}) =>
                                            currentLength == maxLength
                                                ? Text(
                                                    '$currentLength/$maxLength',
                                                    semanticsLabel:
                                                        'character count',
                                                  )
                                                : null,
                                        minLines: null,
                                        maxLines: null,
                                        controller: messageController,
                                        onTapOutside: (event) {
                                          focusNode.unfocus();
                                        },
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 15),
                                          hintText: "Ask me anything...",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    if (!showIcons)
                                      InkWell(
                                        onTap: () {
                                          messageController.clear();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: const Icon(
                                            Icons.close,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (loadingSendMessage ||
                            messageController.text == "") {
                          return;
                        }
                        setBuilderState(() {
                          loadingSendMessage = true;
                        });

                        await dietationService
                            .sendMessage(
                          Message(
                              messageType: pickedImage != null
                                  ? MessageType.imageAndText
                                  : MessageType.text,
                              content: messageController.text,
                              timestamp: Timestamp.now()),
                          image: pickedImage == null
                              ? null
                              : File(pickedImage!.path),
                        )
                            .then((value) {
                          messageController.clear();
                          setBuilderState(() {
                            loadingSendMessage = false;
                            pickedImage = null;
                          });
                        });
                      },
                      icon: loadingSendMessage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: LoadingIndicator(
                                  indicatorType:
                                      Indicator.lineScale) //indicator
                              )
                          : const Icon(
                              Icons.send,
                            ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
