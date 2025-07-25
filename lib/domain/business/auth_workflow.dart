// domain/business/auth_business.dart
import 'package:tech_challenge_flutter/data/dao/auth_dao.dart';

import '../models/account_user.dart';
import '../models/auth_exception.dart';

class AuthWorkflow {
  final AuthDao _dao = AuthDao();

  // Obter usuário atual
  AccountUser? getCurrentUser() => _dao.getCurrentUser();

  // Stream para mudanças de autenticação
  Stream<AccountUser?> get authStateChanges => _dao.authStateChanges;

  // Registrar usuário (com validações de negócio)
  Future<AccountUser> register(String email, String password) async {
    // ⚡ BUSINESS: Validações
    _validateEmail(email);
    _validatePassword(password);

    // ⚡ BUSINESS: Regra - criar usuário e inicializar saldo
    final user = await _dao.createUser(email, password);
    await _dao.initializeUserBalance(user.id, email);

    return user;
  }

  // Login (com validações de negócio)
  Future<AccountUser> login(String email, String password) async {
    // ⚡ BUSINESS: Validações
    _validateEmail(email);
    _validatePassword(password);

    return await _dao.authenticate(email, password);
  }

  // Atualizar dados do usuário
  Future<AccountUser?> updateUser(String username) async {
    // ⚡ BUSINESS: Validação do nome
    _validateUsername(username);

    return await _dao.updateUserData(username);
  }

  // Logout
  Future<void> logout() async {
    await _dao.signOut();
  }

  // Deletar conta
  Future<void> deleteUser(String password) async {
    // ⚡ BUSINESS: Validação da senha
    _validatePassword(password);

    await _dao.deleteUserAccount(password);
  }

  // ⚡ BUSINESS: Regras de validação
  void _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw AuthException('invalid-email');
    }
    if (!email.contains('@') || !email.contains('.')) {
      throw AuthException('invalid-email');
    }
    if (email.length < 5) {
      throw AuthException('invalid-email');
    }
  }

  void _validatePassword(String password) {
    if (password.trim().isEmpty) {
      throw AuthException('weak-password');
    }
    if (password.length < 6) {
      throw AuthException('weak-password');
    }
  }

  void _validateUsername(String username) {
    if (username.trim().isEmpty) {
      throw AuthException('invalid-username');
    }
    if (username.length < 2) {
      throw AuthException('username-too-short');
    }
  }
}
