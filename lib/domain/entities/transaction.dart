import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final int? id;
  final String uuid;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final String? accountId;
  final List<String>? tags;
  final List<String>? attachments;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Transaction({
    this.id,
    required this.uuid,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    this.accountId,
    this.tags,
    this.attachments,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Transaction copyWith({
    int? id,
    String? uuid,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? date,
    String? accountId,
    List<String>? tags,
    List<String>? attachments,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        uuid,
        amount,
        type,
        category,
        description,
        date,
        accountId,
        tags,
        attachments,
        isSynced,
        createdAt,
        updatedAt,
      ];
}