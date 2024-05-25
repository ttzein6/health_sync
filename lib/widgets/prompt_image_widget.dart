import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

typedef OnTapRemoveImageCallback = void Function(XFile);

class PromptImage extends StatelessWidget {
  const PromptImage({
    super.key,
    required this.file,
    this.onTapIcon,
    this.width = 100,
  });

  final File file;
  final VoidCallback? onTapIcon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(
                  10,
                ),
              ),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  image: CrossImage.decoration(file),
                ),
              ),
            ),
          ),
          if (onTapIcon != null)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: onTapIcon,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Symbols.remove,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CrossImage extends StatelessWidget {
  const CrossImage({
    super.key,
    required this.file,
    this.fit = BoxFit.cover,
    this.height = 100,
    this.width = 100,
  });

  final File file;
  final BoxFit fit;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: fit,
      );
    } else {
      return Image.file(
        File(file.path),
        height: height,
        width: width,
      );
    }
  }

  static DecorationImage decoration(File file, {BoxFit fit = BoxFit.cover}) {
    final image = kIsWeb ? NetworkImage(file.path) : FileImage(File(file.path));
    return DecorationImage(image: image as ImageProvider, fit: fit);
  }
}
