import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<String> uploadImage(File image) async {
    userId = FirebaseAuth.instance.currentUser?.uid;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        _storage.ref().child('images/$userId/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
