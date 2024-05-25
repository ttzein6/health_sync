import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  final bool obsucreText;
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final bool showBorder;
  const LoginField({
    super.key,
    this.keyboardType,
    required this.hintText,
    required this.textEditingController,
    this.showBorder = true,
    this.obsucreText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.white,
      keyboardType: keyboardType ?? TextInputType.text,
      controller: textEditingController,
      obscureText: obsucreText,
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: showBorder
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              )
            : InputBorder.none,
        focusedBorder: showBorder
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              )
            : InputBorder.none,
      ),
    );
  }
}
