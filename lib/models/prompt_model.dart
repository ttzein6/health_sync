import 'dart:io';

class PromptData {
  PromptData({
    required this.image,
    required this.textInput,
    List<String>? additionalTextInputs,
  }) : additionalTextInputs = additionalTextInputs ?? [];

  PromptData.empty()
      : image = null,
        additionalTextInputs = [],
        textInput = '';

  File? image;
  String textInput;
  List<String> additionalTextInputs;

  PromptData copyWith({
    File? image,
    String? textInput,
    List<String>? additionalTextInputs,
  }) {
    return PromptData(
      image: image ?? this.image,
      textInput: textInput ?? this.textInput,
      additionalTextInputs: additionalTextInputs ?? this.additionalTextInputs,
    );
  }
}
