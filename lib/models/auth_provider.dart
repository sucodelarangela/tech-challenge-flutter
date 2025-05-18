import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/models/auth_exception.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  User? _user;

  Auth() {
    _firebase.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuth => _user != null;
  User? get user => _user;

  Future<void> register(String email, String password) async {
    try {
      final userCredential = await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> logout() async {
    await _firebase.signOut();
  }
}
