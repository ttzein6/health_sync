import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sync/models/user.dart' as userModel;

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  Future<void> signUp(String email, String password, String name) async {
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userModel.User user = userModel.User(
      id: userCredential.user!.uid,
      name: name,
      email: email,
    );

    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<String> getUserId() async {
    return _firebaseAuth.currentUser!.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
