import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_challenge_flutter/core/models/account_user.dart';
import 'package:tech_challenge_flutter/core/models/auth_exception.dart';
// import 'package:tech_challenge_flutter/utils/capitalize.dart';

class AuthService {
  final FirebaseAuth _firebase = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Converter User do Firebase para seu modelo AccountUser
  AccountUser? _toAccountUser(User user) {
    // final name =
    //     user.displayName != null && user.displayName!.trim().isNotEmpty
    //         ? user.displayName
    //         : user.email!.split('@')[0];

    return AccountUser(
      id: user.uid,
      email: user.email!,
      name: user.displayName ?? '',
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

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'balance': 0.0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'email': email,
        'lastUpdated': DateTime.now(),
      });

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

  Future<AccountUser?> updateUserData(String username) async {
    try {
      final user = _firebase.currentUser;
      if (user == null) return null;
      await user.updateDisplayName(username);
      await user.reload();
      return getCurrentUser();
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

  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebase.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await _deleteUserData(user.uid);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> _deleteUserData(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Buscar e excluir todas as transações
    final transactions =
        await firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .get();

    // Excluir imagens das transações
    for (final doc in transactions.docs) {
      final imageUrl = doc.data()['image'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Erro ao excluir imagem: $e');
        }
      }
      await doc.reference.delete();
    }

    // Excluir documento do usuário
    await firestore.collection('users').doc(userId).delete();
  }
}
