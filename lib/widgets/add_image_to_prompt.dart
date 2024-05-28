import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:health_sync/services/prompt_view_model.dart';
import 'package:health_sync/utils/common_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'package:health_sync/main.dart' show camerasAvailable;

import 'package:health_sync/widgets/prompt_image_widget.dart';

class AddImageToPromptWidget extends StatefulWidget {
  const AddImageToPromptWidget({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  final double width;
  final double height;

  @override
  State<AddImageToPromptWidget> createState() => _AddImageToPromptWidgetState();
}

class _AddImageToPromptWidgetState extends State<AddImageToPromptWidget> {
  final ImagePicker picker = ImagePicker();

  bool flashOn = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PromptViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 8,
            top: 8,
          ),
          child: Text(
            'Meal Image',
            // style: MarketplaceTheme.dossierParagraph,
          ),
        ),
        SizedBox(
          height: widget.height,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: AddImage(
                  width: widget.width,
                  height: widget.height,
                  onTap: () async {
                    final image = await CommonFunctions.addImage(context);
                    viewModel.addImage(image);
                  },
                ),
              ),
              if (viewModel.userPrompt.image != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PromptImage(
                    width: widget.width,
                    file: viewModel.userPrompt.image!,
                    onTapIcon: () =>
                        viewModel.removeImage(viewModel.userPrompt.image!),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool flashOn = false;
  late CameraController controller;
  int currentCameraIndex = 0;
  List<CameraDescription> cameras = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void switchCamera() {
    if (cameras.isEmpty) {
      return;
    }
    currentCameraIndex = (currentCameraIndex + 1) % cameras.length;
    if (mounted) {
      setState(() {});
    } else {
      return;
    }
  }

  Future<void> initializeCamera() async {
    camerasAvailable = await availableCameras();
    cameras = [];
    bool addedFrontCamera = false;
    bool addedBackCamera = false;
    for (var camera in camerasAvailable) {
      if (camera.lensDirection.name == "back" && !addedBackCamera) {
        cameras.add(camera);
        addedBackCamera = true;
      } else if (camera.lensDirection.name == "front" && !addedFrontCamera) {
        cameras.add(camera);
        addedFrontCamera = true;
      }
    }
    controller = CameraController(
      cameras[currentCameraIndex],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.setFocusMode(FocusMode.auto);
  }

  void _onTapToFocus(TapDownDetails details) async {
    final offsetX =
        details.localPosition.dx / MediaQuery.of(context).size.width;
    final offsetY =
        details.localPosition.dy / MediaQuery.of(context).size.height;
    await controller.setFocusPoint(Offset(offsetX, offsetY));
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets mediaQueryPadding = MediaQuery.paddingOf(context);
    return FutureBuilder(
      future: initializeCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 14,
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: controller.value.previewSize!.width,
                      width: controller.value.previewSize!.height,
                      child: Center(
                        child: GestureDetector(
                            onTapDown: _onTapToFocus,
                            child: CameraPreview(controller)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(.7),
                padding: mediaQueryPadding.copyWith(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: StatefulBuilder(
                        builder: (context, setFlashState) {
                          return IconButton(
                            icon: Icon(
                              flashOn ? Symbols.flash_on : Symbols.flash_off,
                              size: 40,
                              color:
                                  flashOn ? Colors.yellowAccent : Colors.white,
                            ),
                            onPressed: () {
                              controller.setFlashMode(
                                  flashOn ? FlashMode.off : FlashMode.always);
                              setFlashState(() {
                                flashOn = !flashOn;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: IconButton(
                        icon: const Icon(
                          Symbols.cancel,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                color: Colors.black.withOpacity(.7),
                padding: mediaQueryPadding.copyWith(top: 0, right: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.switch_camera_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: switchCamera,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 70,
                    ),
                    onPressed: () async {
                      try {
                        final image = await controller.takePicture();
                        if (!context.mounted) return;
                        Navigator.of(context).pop(image);
                      } catch (e) {
                        rethrow;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddImage extends StatefulWidget {
  const AddImage({
    super.key,
    required this.onTap,
    this.height = 100,
    this.width = 100,
  });

  final VoidCallback onTap;
  final double height;
  final double width;

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool hovered = false;
  bool tappedDown = false;

  Color get buttonColor {
    var state = (hovered, tappedDown);
    return switch (state) {
      // tapped down state
      (_, true) =>
        Theme.of(context).buttonTheme.colorScheme!.secondary.withOpacity(.7),
      // hovered
      (true, _) =>
        Theme.of(context).buttonTheme.colorScheme!.secondary.withOpacity(.3),
      // base color
      (_, _) =>
        Theme.of(context).buttonTheme.colorScheme!.secondary.withOpacity(.3),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            tappedDown = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            tappedDown = false;
          });
          widget.onTap();
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: buttonColor,
              ),
              child: const Center(
                child: Icon(
                  Symbols.add_photo_alternate_rounded,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
