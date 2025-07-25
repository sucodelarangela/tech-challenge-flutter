import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/domain/models/user_balance.dart';
import 'package:tech_challenge_flutter/data/dao/transaction_dao.dart';

class TransactionController with ChangeNotifier {
  final TransactionDao _transactionDao = TransactionDao();

  UserBalance? _userBalance;
  List<TransactionModel>? _transactions;

  bool _isLoading = false;
  bool _hasError = false;
  String? _error;

  // Flags para cache e lazy loading
  bool _balanceLoaded = false;
  bool _transactionsLoaded = false;

  TransactionController() {
    if (_transactionDao.isUserAuthenticated) {
      loadBalance();
      loadTransactions();
    }
  }

  String? get error => _error;
  bool get hasError => _hasError;
  bool get isLoading => _isLoading;
  List<TransactionModel>? get transactions => _transactions;
  // Getters
  UserBalance? get userBalance => _userBalance;

  /// Limpa completamente os caches de saldo e transações
  void clearCache() {
    _balanceLoaded = false;
    _transactionsLoaded = false;
    _userBalance = null;
    _transactions = null;
    notifyListeners();
  }

  /// Limpa apenas o estado de erro
  void clearError() {
    _setError(null);
  }

  /// Limpa apenas o cache de transações
  void clearTransactions() {
    _transactionsLoaded = false;
    _transactions = null;
    notifyListeners();
  }

  /// Exclui e força recarga de cache
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _transactionDao.deleteTransaction(id);
      await loadBalance(forceRefresh: true);
      await loadTransactions(forceRefresh: true);
    } catch (e) {
      _setError('Erro ao excluir transação: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Download de imagem
  Future<String?> downloadImage(String imageUrl, String fileName) async {
    _setLoading(true);
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }

      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data);
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: fileName,
      );

      if (result['isSuccess'] == true) {
        return 'Imagem salva na galeria com sucesso!';
      } else {
        return 'Falha no download, status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Falha no download: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega saldo com cache + lazy loading
  Future<void> loadBalance({bool forceRefresh = false}) async {
    if (_balanceLoaded && !forceRefresh) return;

    _setLoading(true);
    _setError(null);

    try {
      // repassa forceRefresh ao service
      _userBalance = await _transactionDao.getBalance(
        forceRefresh: forceRefresh,
      );
      _balanceLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar saldo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega transações com cache + lazy loading
  Future<List<TransactionModel>> loadTransactions({
    bool forceRefresh = false,
  }) async {
    if (_transactionsLoaded && !forceRefresh) {
      return _transactions!;
    }

    _setLoading(true);
    _setError(null);

    try {
      // repassa forceRefresh ao service
      final txs = await _transactionDao.getTransactions(
        forceRefresh: forceRefresh,
      );
      _transactions = txs;
      _transactionsLoaded = true;
      notifyListeners();
      return txs;
    } catch (e) {
      _setError('Erro ao carregar transações: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Salva e força recarga de cache
  Future<void> saveTransaction(Map<String, Object> data) async {
    _setLoading(true);
    _setError(null);

    try {
      await _transactionDao.saveTransaction(data);
      await loadBalance(forceRefresh: true);
      await loadTransactions(forceRefresh: true);
    } catch (e) {
      _setError('Erro ao salvar transação: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setError(String? error) {
    _hasError = error != null;
    _error = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
