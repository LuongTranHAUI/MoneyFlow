import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class TransactionModel {
  static Transaction fromEntity(TransactionEntity entity) {
    return Transaction(
      id: entity.id,
      uuid: entity.uuid,
      amount: entity.amount,
      type: entity.type == 'income' ? TransactionType.income : TransactionType.expense,
      category: entity.category,
      description: entity.description,
      date: entity.date,
      accountId: entity.accountId,
      tags: entity.tags != null ? List<String>.from(jsonDecode(entity.tags!)) : null,
      attachments: entity.attachments != null 
          ? List<String>.from(jsonDecode(entity.attachments!)) 
          : null,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  static TransactionsCompanion toCompanion(Transaction transaction) {
    return TransactionsCompanion(
      id: transaction.id != null ? Value(transaction.id!) : const Value.absent(),
      uuid: Value(transaction.uuid),
      amount: Value(transaction.amount),
      type: Value(transaction.type == TransactionType.income ? 'income' : 'expense'),
      category: Value(transaction.category),
      description: Value(transaction.description),
      date: Value(transaction.date),
      accountId: Value(transaction.accountId),
      tags: Value(transaction.tags != null ? jsonEncode(transaction.tags) : null),
      attachments: Value(transaction.attachments != null 
          ? jsonEncode(transaction.attachments) 
          : null),
      isSynced: Value(transaction.isSynced),
      createdAt: Value(transaction.createdAt),
      updatedAt: Value(transaction.updatedAt),
    );
  }
  
  static Transaction createNew({
    required double amount,
    required TransactionType type,
    required String category,
    String? description,
    DateTime? date,
    String? accountId,
    List<String>? tags,
    List<String>? attachments,
  }) {
    final now = DateTime.now();
    return Transaction(
      uuid: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date ?? now,
      accountId: accountId,
      tags: tags,
      attachments: attachments,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}