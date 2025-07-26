import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String description;
  final double value;
  final String category;
  final Timestamp date;
  final String image;
  final bool isIncome;
  final Timestamp createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.value,
    required this.category,
    required this.date,
    required this.image,
    required this.isIncome,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      value: (map['value'] as num).toDouble(),
      category: map['category'] ?? '',
      date: map['date'] as Timestamp,
      image: map['image'] ?? '',
      isIncome: map['isIncome'] ?? false,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'value': value,
      'category': category,
      'date': date,
      'image': image,
      'isIncome': isIncome,
      'createdAt': createdAt,
    };
  }
}
