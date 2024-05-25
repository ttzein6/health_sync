import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  static Future<File?> selectImage() async {
    File? image;
    var picker = ImagePicker();

    if (Platform.isAndroid || Platform.isIOS) {
      var imageSource = ImageSource.gallery;
      image = await picker
          .pickImage(source: imageSource, requestFullMetadata: false)
          .then((value) => value == null ? null : File(value.path));
    } else {
      image = await FilePicker.platform
          .pickFiles(
        allowMultiple: false,
        type: FileType.image,
      )
          .then((value) {
        return value == null || value.files.isEmpty
            ? null
            : File(value.files.first.xFile.path);
      });
    }
    return image;
  }

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
