import 'package:drift/drift.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  RealColumn get budgetAmount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Budget {
  final int id;
  final String category;
  final String icon;
  final int color;
  final double budgetAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.category,
    required this.icon,
    required this.color,
    required this.budgetAmount,
    this.spentAmount = 0,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  double get remainingAmount => budgetAmount - spentAmount;
  double get percentageUsed => budgetAmount > 0 ? (spentAmount / budgetAmount * 100) : 0;
  bool get isOverBudget => spentAmount > budgetAmount;
}