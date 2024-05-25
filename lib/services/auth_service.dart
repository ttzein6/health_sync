import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/models/user.dart' as userModel;
import 'package:image_picker/image_picker.dart';

class Auth {
  static Future<userModel.User?> getUserById(String? id) async {
    if (id == null) return null;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .withConverter<userModel.User>(
            fromFirestore: (snapshot, _) =>
                userModel.User.fromMap(snapshot.data() ?? {}),
            toFirestore: (u, _) => u.toMap())
        .get()
        .then((value) => value.data());
  }

  static Future login(
    BuildContext context,
    String email,
    String password,
  ) async {
    return await FirebaseAuth.instanceFor(app: Firebase.app())
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      context.read<AuthBloc>().add(AppStarted());
      return value;
    });
  }

  static Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  static Future register({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required int age,
    required int height,
    required int weight,
    required File image,
    required String gender,
  }) async {
    var imageUrl = await uploadImage(image);
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    userModel.User user = userModel.User(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      age: age,
      gender: gender,
      height: height,
      weight: weight,
      imageUrl: imageUrl,
    );

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap())
        .then((value) {
      context.read<AuthBloc>().add(SetActiveUser(user: user));
    });
  }
}

Future<String> uploadImage(File imageFile) async {
  String imageName = path.basename(imageFile.path) +
      DateTime.now().millisecondsSinceEpoch.toString();
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('user_images/$imageName');
  UploadTask uploadTask = ref.putFile(File(imageFile.path));
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  String imageUrl = await taskSnapshot.ref.getDownloadURL();
  return imageUrl;
}
