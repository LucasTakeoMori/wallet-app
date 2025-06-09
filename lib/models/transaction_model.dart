import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  }) : id = const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: map['amount'] as double,
      category: map['category'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date']),
    );
  }
}
