import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/models/auth_exception.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  Future<void> register(String email, String password) async {
    try {
      await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
