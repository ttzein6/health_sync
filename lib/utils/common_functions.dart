import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/material.dart';
import 'package:health_sync/main.dart';
import 'package:health_sync/utils/device_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class CommonFunctions {
  static Future<XFile> showCamera() async {
    ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
    );
    // final image = await showGeneralDialog<XFile?>(
    //   context: context,
    //   transitionBuilder: (context, animation, secondaryAnimation, child) {
    //     return AnimatedOpacity(
    //       opacity: animation.value,
    //       duration: const Duration(milliseconds: 100),
    //       child: child,
    //     );
    //   },
    //   pageBuilder: (context, animation, secondaryAnimation) {
    //     return const Dialog.fullscreen(
    //       insetAnimationDuration: Duration(seconds: 1),
    //       child: CameraView(),
    //     );
    //   },
    // );

    if (image != null) {
      return image;
    } else {
      throw "failed to take image";
    }
  }

  static Future<XFile> pickImage() async {
    ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image;
    } else {
      throw "failed to take image";
    }
  }

  static Future onImageTap(BuildContext context, String imageUrl) async {
    bool shareLoading = false;
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
              Positioned(
                bottom: 20,
                // alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatefulBuilder(builder: (context, setBuilderState) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          setBuilderState(() {
                            shareLoading = true;
                          });
                          Uint8List imageBytes =
                              await http.readBytes(Uri.parse(imageUrl));
                          setBuilderState(() {
                            shareLoading = false;
                          });

                          Share.shareXFiles([
                            XFile.fromData(imageBytes, mimeType: 'image/jpeg')
                          ]);
                        },
                        label: shareLoading
                            ? const CircularProgressIndicator.adaptive()
                            : const Text("Share"),
                        icon: shareLoading ? null : const Icon(Icons.share),
                      );
                    }),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        saveImageToGallery(context, imageUrl);
                      },
                      label: const Text("Save image to gallery"),
                      icon: const Icon(Icons.save_alt),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  static Future saveImageToGallery(
      BuildContext context, String imageUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? message;
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(imageUrl));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename =
          '${dir.path}/food-app-${DateTime.now().millisecondsSinceEpoch}.png';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Image saved to disk';
      }
    } catch (e) {
      message = e.toString();
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFe91e63),
      ));
    }
  }

  static Future<File> addImage(BuildContext context) async {
    if (DeviceInfo.isPhysicalDeviceWithCamera(deviceInfo)) {
      return await showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (context) => SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 150,
                child: Column(
                  children: [
                    ListTile(
                      title: const Row(
                        children: [
                          Icon(Icons.camera),
                          SizedBox(width: 5),
                          Text("Take a Photo"),
                        ],
                      ),
                      onTap: () => showCamera().then((value) =>
                          Navigator.of(context).pop(File(value.path))),
                    ),
                    ListTile(
                      title: const Row(
                        children: [
                          Icon(Icons.photo),
                          SizedBox(width: 5),
                          Text("Select from Gallery"),
                        ],
                      ),
                      onTap: () => pickImage().then((value) =>
                          Navigator.of(context).pop(File(value.path))),
                    ),
                  ],
                ),
              ));
    } else {
      return await pickImage().then((value) => File(value.path));
    }
  }
}
