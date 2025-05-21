import 'package:flutter/foundation.dart';
import 'package:tech_challenge_flutter/core/models/transaction.dart';
import 'package:tech_challenge_flutter/core/models/user_balance.dart';
import 'package:tech_challenge_flutter/core/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  UserBalance? _userBalance;
  List<TransactionModel>? _transactions;

  // Getters
  UserBalance? get userBalance => _userBalance;
  List<TransactionModel>? get transactions => _transactions;

  // Construtor que inicializa os dados se o usuário estiver autenticado
  TransactionProvider() {
    if (_transactionService.isUserAuthenticated) {
      loadBalance();
    }
  }

  // Salvar uma nova transação
  Future<void> saveTransaction(Map<String, Object> data) async {
    try {
      await _transactionService.saveTransaction(data);

      // Atualizar os dados após salvar a transação
      await loadBalance();
    } catch (e) {
      print('Erro ao salvar transação: $e');
      throw e;
    }
  }

  // Carregar o saldo do usuário
  Future<void> loadBalance() async {
    try {
      _userBalance = await _transactionService.getBalance();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar saldo: $e');
    }
  }

  // Carregar as transações do usuário - mantém compatibilidade com o código existente
  Future<List<TransactionModel>> loadTransactions() async {
    try {
      final transactions = await _transactionService.getTransactions();
      _transactions = transactions; // também armazena internamente
      notifyListeners();
      return transactions; // retorna para manter compatibilidade
    } catch (e) {
      print('Erro ao carregar transações: $e');
      throw e; // propaga o erro para o componente chamar
    }
  }

  // Excluir uma transação
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionService.deleteTransaction(id);

      // Atualizar os dados após excluir a transação
      await loadBalance();
    } catch (e) {
      print('Erro ao excluir transação: $e');
      throw e;
    }
  }
}
