// data/auth_dao.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_challenge_flutter/domain/models/account_user.dart';
import 'package:tech_challenge_flutter/domain/models/auth_exception.dart';

class AuthDao {
  final FirebaseAuth _firebase = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Método movido do AuthService original
  AccountUser? _toAccountUser(User user) {
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

  // Criar usuário (sem validações - só acesso aos dados)
  Future<AccountUser> createUser(String email, String password) async {
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

  // Inicializar saldo do usuário
  Future<void> initializeUserBalance(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'balance': 0.0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'email': email,
        'lastUpdated': DateTime.now(),
      });
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Autenticar usuário (sem validações - só acesso aos dados)
  Future<AccountUser> authenticate(String email, String password) async {
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

  // Atualizar dados do usuário
  Future<AccountUser?> updateUserData(String username) async {
    try {
      final user = _firebase.currentUser;
      if (user == null) return null;

      await user.updateDisplayName(username);
      await user.reload();

      // Recarrega o usuário atual para pegar os dados atualizados
      final updatedUser = _firebase.currentUser;
      return updatedUser != null ? _toAccountUser(updatedUser) : null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  // Logout
  Future<void> signOut() async {
    await _firebase.signOut();
  }

  // Deletar conta
  Future<void> deleteUserAccount(String password) async {
    try {
      final user = _firebase.currentUser;
      if (user == null) throw AuthException('user-not-found');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
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

  // Deletar dados do usuário (método privado)
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
