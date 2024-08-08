// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final MessageType messageType;
  final String content;
  final String? imageUrl;
  final Timestamp timestamp;
  final bool isAi;

  Message(
      {required this.messageType,
      required this.content,
      this.imageUrl,
      this.isAi = false,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageType': messageType.toString(),
      'content': content,
      'isAi': isAi,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageType: MessageType.fromString(map['messageType']),
      content: map['content'] as String,
      timestamp: map['timestamp'],
      imageUrl: map['imageUrl'],
      isAi: map['isAi'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  Message copyWith({
    MessageType? messageType,
    String? content,
    String? imageUrl,
    Timestamp? timestamp,
    bool? isAi,
  }) {
    return Message(
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isAi: isAi ?? this.isAi,
    );
  }
}

enum MessageType {
  text,
  imageAndText;

  @override
  String toString() {
    return this == text ? "text" : "image";
  }

  static MessageType fromString(String string) {
    return string == "text" ? text : imageAndText;
  }
}
