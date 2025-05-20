import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/core/models/account_user.dart';
import 'package:tech_challenge_flutter/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AccountUser? _currentUser;

  AuthProvider() {
    // Inicializar com o usuário atual (caso já esteja logado)
    _currentUser = _authService.getCurrentUser();

    // Escutar mudanças no estado de autenticação
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Getters
  bool get isAuth => _currentUser != null;
  AccountUser? get user => _currentUser;

  // Métodos que delegam para o serviço
  Future<void> register(String email, String password) async {
    await _authService.register(email, password);
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
