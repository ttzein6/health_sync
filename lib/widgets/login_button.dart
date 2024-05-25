import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Function() onTap;
  final String label;
  const LoginButton({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
