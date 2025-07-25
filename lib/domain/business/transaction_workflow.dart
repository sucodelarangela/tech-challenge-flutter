// domain/business/transaction_business.dart
import 'dart:io';
import 'package:tech_challenge_flutter/data/dao/transaction_dao.dart';
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/domain/models/user_balance.dart';

class TransactionWorkflow {
  final TransactionDao _dao = TransactionDao();

  // Buscar transações
  Future<List<TransactionModel>> getTransactions({
    bool forceRefresh = false,
  }) async {
    return await _dao.getTransactions(forceRefresh: forceRefresh);
  }

  // Buscar saldo
  Future<UserBalance?> getBalance({bool forceRefresh = false}) async {
    return await _dao.getBalance(forceRefresh: forceRefresh);
  }

  // Salvar transação (com validações de negócio)
  Future<void> saveTransaction(Map<String, Object> data) async {
    // ⚡ BUSINESS: Validações
    _validateTransactionData(data);

    // ⚡ BUSINESS: Validar imagem se fornecida
    final imagePath = data['image'] as String?;
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('http')) {
      _validateImageFile(imagePath);
    }

    // ⚡ BUSINESS: Garantir que category determina isIncome
    final category = data['category'] as String;
    final isIncome = _determineTransactionType(category);

    // Delegar para DAO (que já cuida do saldo automaticamente)
    await _dao.saveTransaction(data);
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    // ⚡ BUSINESS: Validação
    if (id.trim().isEmpty) {
      throw Exception('ID da transação não pode ser vazio');
    }

    // Delegar para DAO (que já cuida do saldo automaticamente)
    await _dao.deleteTransaction(id);
  }

  // Download de imagem (funcionalidade de negócio)
  Future<String?> downloadImage(String imageUrl, String fileName) async {
    // Essa funcionalidade pode ficar no business ou ser movida para um serviço específico
    // Por ora, vou manter aqui como estava no Provider original

    // TODO: Implementar download de imagem
    // Esta lógica estava no TransactionProvider original
    throw UnimplementedError('Download de imagem ainda não implementado');
  }

  // ⚡ BUSINESS: Validações
  void _validateTransactionData(Map<String, Object> data) {
    final description = data['description']?.toString() ?? '';
    final value = data['value'] as double?;
    final category = data['category']?.toString() ?? '';

    if (description.trim().isEmpty) {
      throw Exception('Descrição é obrigatória');
    }

    if (value == null || value <= 0) {
      throw Exception('Valor deve ser maior que zero');
    }

    if (category.trim().isEmpty) {
      throw Exception('Categoria é obrigatória');
    }

    if (!['Entrada', 'Saída'].contains(category)) {
      throw Exception('Categoria deve ser "Entrada" ou "Saída"');
    }
  }

  void _validateImageFile(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      throw Exception('Arquivo de imagem não encontrado');
    }

    // Validação adicional de tamanho será feita no DAO
    // Aqui podemos fazer validações de tipo de arquivo, etc.
    final extension = imagePath.toLowerCase();
    if (!extension.endsWith('.jpg') &&
        !extension.endsWith('.jpeg') &&
        !extension.endsWith('.png')) {
      throw Exception('Apenas imagens JPG, JPEG e PNG são permitidas');
    }
  }

  // ⚡ BUSINESS: Regra de negócio
  bool _determineTransactionType(String category) {
    return category == 'Entrada';
  }

  // ⚡ BUSINESS: Método utilitário para filtrar transações
  List<TransactionModel> filterTransactionsByCategory(
    List<TransactionModel> transactions,
    String category,
  ) {
    return transactions.where((tx) => tx.category == category).toList();
  }

  // ⚡ BUSINESS: Método utilitário para calcular total por período
  double calculateTotalForPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate, {
    bool onlyIncome = false,
    bool onlyExpenses = false,
  }) {
    final filtered = transactions.where((tx) {
      final txDate = tx.date.toDate();
      final isInPeriod = txDate.isAfter(startDate) && txDate.isBefore(endDate);

      if (onlyIncome) return isInPeriod && tx.isIncome;
      if (onlyExpenses) return isInPeriod && !tx.isIncome;
      return isInPeriod;
    });

    return filtered.fold(0.0, (sum, tx) => sum + tx.value);
  }
}
