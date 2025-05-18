import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/models/auth_exception.dart';

class Auth with ChangeNotifier {
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
      // RESPOSTA: UserCredential(additionalUserInfo: AdditionalUserInfo(isNewUser: true, profile: {}, providerId: null, username: null, authorizationCode: null), credential: null, user: User(displayName: null, email: aes.caldas@gmail.com, isEmailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2025-05-17 22:31:39.431Z, lastSignInTime: 2025-05-17 22:31:39.431Z), phoneNumber: null, photoURL: null, providerData, [UserInfo(displayName: null, email: aes.caldas@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: aes.caldas@gmail.com)], refreshToken: null, tenantId: null, uid: qQvw1BmnslUCrMCsSvuaUO7gr3A2))
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
      // RESPOSTA: UserCredential(additionalUserInfo: AdditionalUserInfo(isNewUser: false, profile: {}, providerId: null, username: null, authorizationCode: null), credential: null, user: User(displayName: null, email: aes.caldas@gmail.com, isEmailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2025-05-17 22:31:39.431Z, lastSignInTime: 2025-05-17 22:31:39.431Z), phoneNumber: null, photoURL: null, providerData, [UserInfo(displayName: null, email: aes.caldas@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: aes.caldas@gmail.com)], refreshToken: null, tenantId: null, uid: qQvw1BmnslUCrMCsSvuaUO7gr3A2))
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
