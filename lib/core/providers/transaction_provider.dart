import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tech_challenge_flutter/core/models/transaction.dart';
import 'package:tech_challenge_flutter/core/models/user_balance.dart';
import 'package:tech_challenge_flutter/core/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  UserBalance? _userBalance;
  List<TransactionModel>? _transactions;
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;

  // Getters
  UserBalance? get userBalance => _userBalance;
  List<TransactionModel>? get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;

  // Construtor que inicializa os dados se o usuário estiver autenticado
  TransactionProvider() {
    if (_transactionService.isUserAuthenticated) {
      loadBalance();
      loadTransactions();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _hasError = error != null;
    _error = error;
    notifyListeners();
  }

  // Salvar uma nova transação
  Future<void> saveTransaction(Map<String, Object> data) async {
    _setLoading(true);
    _setError(null);

    try {
      await _transactionService.saveTransaction(data);
      await loadBalance();
      await loadTransactions();
      notifyListeners();
    } catch (e) {
      print('Erro ao salvar transação: $e');
      _setError('Erro ao salvar transação: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Carregar o saldo do usuário
  Future<void> loadBalance() async {
    _setLoading(true);
    _setError(null);

    try {
      _userBalance = await _transactionService.getBalance();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar saldo: $e');
      _setError('Erro ao carregar saldo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Carregar as transações do usuário - mantém compatibilidade com o código existente
  Future<List<TransactionModel>> loadTransactions() async {
    _setLoading(true);
    _setError(null);

    try {
      final transactions = await _transactionService.getTransactions();
      _transactions = transactions;
      notifyListeners();
      return transactions; // retorna para manter compatibilidade
    } catch (e) {
      print('Erro ao carregar transações: $e');
      _setError('Erro ao carregar transações: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir uma transação
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _transactionService.deleteTransaction(id);
      await loadBalance();
      await loadTransactions();
      notifyListeners();
    } catch (e) {
      print('Erro ao excluir transação: $e');
      _setError('Erro ao excluir transação: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Método para limpar erros manualmente (opcional)
  void clearError() {
    _setError(null);
  }

  // Download da imagem
  Future<String?> downloadImage(String imageUrl, String fileName) async {
    _setLoading(true);

    try {
      if (Platform.isAndroid) {
        await Permission.storage.request().isGranted;
      } else {
        await Permission.photos.request().isGranted;
      }

      // Baixar usando Dio
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List bytes = Uint8List.fromList(response.data);

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: "downloaded_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        return 'Imagem salva na galeria com sucesso!';
      } else {
        print('Falha no download, status code: ${response.statusCode}');
        return 'Falha no download, status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Erro ao baixar imagem: $e');
      return 'Falha no download, status code: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
}
