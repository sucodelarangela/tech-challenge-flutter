class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'deposit' ou 'transfer'

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }
}
