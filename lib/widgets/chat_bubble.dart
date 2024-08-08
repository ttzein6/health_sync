import 'package:health_sync/models/message.dart';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:flutter/material.dart';
import 'package:health_sync/utils/common_functions.dart';

class ChatBubble extends StatelessWidget {
  final bool isSender;
  final Message message;
  final String? senderImage;
  final bool showUserImage;
  const ChatBubble({
    super.key,
    required this.showUserImage,
    required this.message,
    required this.isSender,
    this.senderImage,
  });
  Widget textBubble(String message) {
    return BubbleNormal(
      isSender: isSender,
      text: message,
      color: // isSender ? const Color(0xFF1B97F3) :
          const Color(0xFFE8E8EE),
      tail: showUserImage,
      textStyle:
          //  isSender
          //     ? const TextStyle(color: Colors.white, fontSize: 16)
          //     :
          const TextStyle(color: Colors.black87, fontSize: 14),
    );
  }

  Widget imageBubble(BuildContext context, Message message) {
    return BubbleNormalImage(
      id: message.imageUrl ?? "",
      image: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.imageUrl ?? "",
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator.adaptive(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                fit: BoxFit.fill,
              ), // Or Image.asset for local images
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.transparent,
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      color: //isSender ? const Color(0xFF1B97F3) :
          const Color(0xFFE8E8EE),
      tail: showUserImage,
      isSender: isSender,
      onTap: () {
        CommonFunctions.onImageTap.call(context, message.imageUrl ?? "");
      },
    );
  }

  Widget userImageWidget() => const SizedBox(
        width: 30,
        height: 30,
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/icons/icon.png'),
        ),
      );
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender && showUserImage)
            userImageWidget()
          else
            const SizedBox(
              width: 30,
            ),
          Expanded(
            child: message.messageType == MessageType.text
                ? textBubble(message.content)
                : imageBubble(context, message),
          ),
        ],
      );
}
