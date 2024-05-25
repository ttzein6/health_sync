import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:health_sync/services/image_upload_service.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';

import 'package:health_sync/services/auth_service.dart';
import 'package:health_sync/widgets/login_button.dart';
import 'package:health_sync/widgets/login_field.dart';
part 'login_page.dart';
part 'signup_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});
  static const routeName = '/auth';
  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool isLogin = true;
  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(registerOnTap: () {
        toggle();
      });
    }
    return RegisterPage(loginOnTap: () {
      toggle();
    });
  }
}
