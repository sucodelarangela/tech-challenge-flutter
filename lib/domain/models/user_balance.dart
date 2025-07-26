import 'package:cloud_firestore/cloud_firestore.dart';

class UserBalance {
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final String email;
  final DateTime lastUpdated;

  UserBalance({
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.email,
    required this.lastUpdated,
  });

  // Construtor para criar um UserBalance a partir de um Map (Firestore doc.data)
  factory UserBalance.fromMap(Map<String, dynamic> data) {
    return UserBalance(
      balance: (data['balance'] as num).toDouble(),
      totalIncome: (data['totalIncome'] as num).toDouble(),
      totalExpenses: (data['totalExpenses'] as num).toDouble(),
      email: data['email'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Converte para Map para salvar no Firestore (opcional)
  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'email': email,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
