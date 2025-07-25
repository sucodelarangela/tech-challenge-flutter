// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/domain/business/auth_workflow.dart';
import 'package:tech_challenge_flutter/domain/models/account_user.dart';

class AuthController with ChangeNotifier {
  final AuthWorkflow _business = AuthWorkflow();

  AccountUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Construtor - inicializa com usuário atual e escuta mudanças
  AuthController() {
    _currentUser = _business.getCurrentUser();

    // Escutar mudanças no estado de autenticação
    _business.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Getters
  bool get isAuth => _currentUser != null;
  AccountUser? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Registrar usuário
  Future<void> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _business.register(email, password);
      // _currentUser será atualizado automaticamente via authStateChanges
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _business.login(email, password);
      // _currentUser será atualizado automaticamente via authStateChanges
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar usuário
  Future<void> updateUser(String username) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _business.updateUser(username);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _business.logout();
      // _currentUser será atualizado automaticamente via authStateChanges
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Deletar usuário
  Future<void> deleteUser(String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _business.deleteUser(password);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Limpar erro
  void clearError() {
    _clearError();
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
