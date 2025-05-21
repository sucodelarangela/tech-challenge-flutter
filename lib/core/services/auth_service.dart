import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_flutter/core/models/account_user.dart';
import 'package:tech_challenge_flutter/core/models/auth_exception.dart';
import 'package:tech_challenge_flutter/utils/capitalize.dart';

class AuthService {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  // Converter User do Firebase para seu modelo AccountUser
  AccountUser? _toAccountUser(User user) {
    final name =
        user.displayName != null && user.displayName!.trim().isNotEmpty
            ? user.displayName
            : user.email!.split('@')[0];

    return AccountUser(
      id: user.uid,
      email: user.email!,
      name: capitalize(name!),
    );
  }

  // Obter usuário atual
  AccountUser? getCurrentUser() {
    final user = _firebase.currentUser;
    return user == null ? null : _toAccountUser(user);
  }

  // Stream para alterações no estado de autenticação
  Stream<AccountUser?> get authStateChanges {
    return _firebase.authStateChanges().map((User? user) {
      return user == null ? null : _toAccountUser(user);
    });
  }

  // Cadastro
  Future<AccountUser> register(String email, String password) async {
    try {
      UserCredential credential = await _firebase
          .createUserWithEmailAndPassword(email: email, password: password);
      return _toAccountUser(credential.user!)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Login
  Future<AccountUser> login(String email, String password) async {
    try {
      final credential = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toAccountUser(credential.user!)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebase.signOut();
  }

  // TODO: Criar exclusão de conta
}
