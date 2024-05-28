import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_sync/main.dart';
import 'package:health_sync/utils/device_info.dart';
import 'package:image_picker/image_picker.dart';

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
