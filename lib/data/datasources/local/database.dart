import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:finance_tracker/core/constants/app_constants.dart';

part 'database.g.dart';

@DataClassName('TransactionEntity')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  RealColumn get amount => real()();
  TextColumn get type => text().withLength(min: 1, max: 10)(); // income, expense
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get accountId => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array
  TextColumn get attachments => text().nullable()(); // JSON array
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CategoryEntity')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get type => text()(); // income, expense, both
  IntColumn get parentId => integer().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BudgetEntity')
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

@DataClassName('GoalEntity')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get category => text().withDefault(const Constant('general'))(); // general, emergency_fund
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AccountEntity')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash, bank, credit, investment
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('VND'))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SyncLogEntity')
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncTableName => text()();
  TextColumn get operation => text()(); // insert, update, delete
  TextColumn get recordId => text()();
  TextColumn get data => text()(); // JSON data
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
}

@DataClassName('UserProfileEntity')
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('VND'))();
  TextColumn get language => text().withDefault(const Constant('vi'))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('NotificationEntity')
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get data => text().nullable()();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserEntity')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get fullName => text()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isEmailVerified => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get resetPasswordToken => text().nullable()();
  DateTimeColumn get resetPasswordExpiry => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

// Investment Tables
@DataClassName('InvestmentEntity')
class Investments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Tên đầu tư
  TextColumn get symbol => text()(); // Mã cổ phiếu/crypto
  TextColumn get type => text()(); // stock, crypto, gold, bond, fund
  RealColumn get totalValue => real()(); // Tổng giá trị hiện tại
  RealColumn get totalInvested => real()(); // Tổng tiền đã đầu tư
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))(); // Giá mua vào
  RealColumn get currentPrice => real()(); // Giá hiện tại
  RealColumn get quantity => real()(); // Số lượng sở hữu
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('InvestmentTransactionEntity') 
class InvestmentTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get investmentId => integer().references(Investments, #id)();
  TextColumn get type => text()(); // buy, sell
  RealColumn get quantity => real()();
  RealColumn get price => real()(); // Giá tại thời điểm giao dịch
  RealColumn get fee => real().withDefault(const Constant(0))(); // Phí giao dịch
  RealColumn get totalAmount => real()(); // Tổng tiền (bao gồm phí)
  TextColumn get notes => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PortfolioEntity')
class Portfolios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Tên danh mục
  TextColumn get description => text().nullable()();
  RealColumn get totalValue => real()(); // Tổng giá trị
  RealColumn get totalInvested => real()(); // Tổng đã đầu tư
  RealColumn get targetAllocation => real().nullable()(); // Phân bổ mục tiêu (%)
  TextColumn get riskLevel => text()(); // conservative, moderate, aggressive
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Recurring Transactions
@DataClassName('RecurringTransactionEntity')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Tên giao dịch định kỳ
  RealColumn get amount => real()();
  TextColumn get type => text()(); // income, expense
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  TextColumn get frequency => text()(); // daily, weekly, monthly, yearly
  IntColumn get interval => integer().withDefault(const Constant(1))(); // Mỗi X kỳ
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get autoExecute => boolean().withDefault(const Constant(false))();
  IntColumn get executedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('RecurringExecutionEntity')
class RecurringExecutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recurringTransactionId => integer().references(RecurringTransactions, #id)();
  IntColumn get transactionId => integer().references(Transactions, #id).nullable()();
  DateTimeColumn get scheduledDate => dateTime()();
  DateTimeColumn get executedDate => dateTime().nullable()();
  TextColumn get status => text()(); // pending, executed, skipped, failed
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Transactions,
  Categories,
  Budgets,
  Goals,
  Accounts,
  SyncLogs,
  UserProfiles,
  Notifications,
  Users,
  Investments,
  InvestmentTransactions,
  Portfolios,
  RecurringTransactions,
  RecurringExecutions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 6; // Add purchase_price to investments table
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultCategories();
        // Temporarily disable dummy data
        // await _insertDummyData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations here
        if (from < 2) {
          // Migration từ version 1 lên 2
        }
        if (from < 3) {
          // Migration từ version 2 lên 3 - thêm investment tables
          await m.createTable(investments);
          await m.createTable(investmentTransactions);
          await m.createTable(portfolios);
          await m.createTable(recurringTransactions);
          await m.createTable(recurringExecutions);
        }
        if (from < 4) {
          // Migration từ version 3 lên 4 - thêm category và priority cho goals
          await m.addColumn(goals, goals.category);
          await m.addColumn(goals, goals.priority);
        }
        if (from < 5) {
          // Migration từ version 4 lên 5 - thêm avatarUrl cho users
          await m.addColumn(users, users.avatarUrl);
        }
        if (from < 6) {
          // Migration từ version 5 lên 6 - thêm purchase_price cho investments
          try {
            await m.addColumn(investments, investments.purchasePrice);
            // Set default value for existing records
            await customStatement('UPDATE investments SET purchase_price = current_price WHERE purchase_price IS NULL');
          } catch (e) {
            // Column might already exist, ignore error
            print('Migration warning: $e');
          }
        }
      },
    );
  }
  
  Future<void> _insertDefaultCategories() async {
    final defaultCategories = [
      // Expense categories
      {'name': 'Ăn uống', 'icon': '🍔', 'color': '#FF5722', 'type': 'expense'},
      {'name': 'Di chuyển', 'icon': '🚗', 'color': '#2196F3', 'type': 'expense'},
      {'name': 'Mua sắm', 'icon': '🛍️', 'color': '#9C27B0', 'type': 'expense'},
      {'name': 'Giải trí', 'icon': '🎮', 'color': '#FF9800', 'type': 'expense'},
      {'name': 'Hóa đơn', 'icon': '📄', 'color': '#607D8B', 'type': 'expense'},
      {'name': 'Sức khỏe', 'icon': '🏥', 'color': '#F44336', 'type': 'expense'},
      {'name': 'Giáo dục', 'icon': '📚', 'color': '#3F51B5', 'type': 'expense'},
      
      // Income categories
      {'name': 'Lương', 'icon': '💰', 'color': '#4CAF50', 'type': 'income'},
      {'name': 'Thưởng', 'icon': '🎁', 'color': '#8BC34A', 'type': 'income'},
      {'name': 'Đầu tư', 'icon': '📈', 'color': '#00BCD4', 'type': 'income'},
      {'name': 'Freelance', 'icon': '💻', 'color': '#009688', 'type': 'income'},
    ];
    
    for (final category in defaultCategories) {
      await into(categories).insert(
        CategoriesCompanion(
          name: Value(category['name'] as String),
          icon: Value(category['icon'] as String),
          color: Value(category['color'] as String),
          type: Value(category['type'] as String),
        ),
      );
    }
  }

  Future<void> _insertDummyData() async {
    await _insertDummyTransactions();
    await _insertDummyBudgets();
    await _insertDummyNotifications();
    await _insertDummyAccounts();
    await _insertDummyUserProfile();
  }

  Future<void> _insertDummyTransactions() async {
    final now = DateTime.now();
    final dummyTransactions = [
      // Current month transactions
      {
        'uuid': 'tx1-${DateTime.now().millisecondsSinceEpoch}',
        'amount': 50000.0,
        'type': 'expense',
        'category': 'Ăn uống',
        'description': 'Ăn trưa tại nhà hàng',
        'date': now.subtract(const Duration(days: 1)),
      },
      {
        'uuid': 'tx2-${DateTime.now().millisecondsSinceEpoch + 1}',
        'amount': 15000000.0,
        'type': 'income',
        'category': 'Lương',
        'description': 'Lương tháng ${now.month}',
        'date': now.subtract(const Duration(days: 5)),
      },
      {
        'uuid': 'tx3-${DateTime.now().millisecondsSinceEpoch + 2}',
        'amount': 200000.0,
        'type': 'expense',
        'category': 'Di chuyển',
        'description': 'Đổ xăng xe máy',
        'date': now.subtract(const Duration(days: 3)),
      },
      {
        'uuid': 'tx4-${DateTime.now().millisecondsSinceEpoch + 3}',
        'amount': 150000.0,
        'type': 'expense',
        'category': 'Giải trí',
        'description': 'Xem phim tại rạp',
        'date': now.subtract(const Duration(days: 7)),
      },
      {
        'uuid': 'tx5-${DateTime.now().millisecondsSinceEpoch + 4}',
        'amount': 500000.0,
        'type': 'expense',
        'category': 'Mua sắm',
        'description': 'Mua quần áo',
        'date': now.subtract(const Duration(days: 2)),
      },
    ];

    for (final tx in dummyTransactions) {
      await into(transactions).insert(
        TransactionsCompanion(
          uuid: Value(tx['uuid'] as String),
          amount: Value(tx['amount'] as double),
          type: Value(tx['type'] as String),
          category: Value(tx['category'] as String),
          description: Value(tx['description'] as String?),
          date: Value(tx['date'] as DateTime),
        ),
      );
    }
  }

  Future<void> _insertDummyBudgets() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final dummyBudgets = [
      {
        'category': 'Ăn uống',
        'icon': '🍔',
        'color': 0xFFFF5722,
        'budgetAmount': 2000000.0,
        'startDate': startOfMonth,
        'endDate': endOfMonth,
      },
      {
        'category': 'Di chuyển',
        'icon': '🚗',
        'color': 0xFF2196F3,
        'budgetAmount': 1000000.0,
        'startDate': startOfMonth,
        'endDate': endOfMonth,
      },
      {
        'category': 'Giải trí',
        'icon': '🎮',
        'color': 0xFFFF9800,
        'budgetAmount': 500000.0,
        'startDate': startOfMonth,
        'endDate': endOfMonth,
      },
      {
        'category': 'Mua sắm',
        'icon': '🛍️',
        'color': 0xFF9C27B0,
        'budgetAmount': 1500000.0,
        'startDate': startOfMonth,
        'endDate': endOfMonth,
      },
    ];

    for (final budget in dummyBudgets) {
      await into(budgets).insert(
        BudgetsCompanion(
          category: Value(budget['category'] as String),
          icon: Value(budget['icon'] as String),
          color: Value(budget['color'] as int),
          budgetAmount: Value(budget['budgetAmount'] as double),
          startDate: Value(budget['startDate'] as DateTime),
          endDate: Value(budget['endDate'] as DateTime),
        ),
      );
    }
  }

  Future<void> _insertDummyNotifications() async {
    final now = DateTime.now();
    final dummyNotifications = [
      {
        'title': 'Chào mừng bạn đến với Finance Tracker!',
        'message': 'Hãy bắt đầu theo dõi tài chính cá nhân của bạn ngay hôm nay.',
        'type': 'welcome',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 1)),
      },
      {
        'title': 'Ngân sách "Ăn uống" gần hết',
        'message': 'Bạn đã sử dụng 85% ngân sách ăn uống tháng này.',
        'type': 'budget_warning',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 6)),
      },
      {
        'title': 'Nhắc nhở thanh toán hóa đơn điện',
        'message': 'Hóa đơn điện sẽ đến hạn thanh toán vào ngày mai.',
        'type': 'bill_reminder',
        'isRead': true,
        'createdAt': now.subtract(const Duration(days: 2)),
      },
    ];

    for (final notification in dummyNotifications) {
      await into(notifications).insert(
        NotificationsCompanion(
          title: Value(notification['title'] as String),
          message: Value(notification['message'] as String),
          type: Value(notification['type'] as String),
          isRead: Value(notification['isRead'] as bool),
          createdAt: Value(notification['createdAt'] as DateTime),
        ),
      );
    }
  }

  Future<void> _insertDummyAccounts() async {
    final dummyAccounts = [
      {
        'name': 'Tiền mặt',
        'type': 'cash',
        'balance': 2000000.0,
        'currency': 'VND',
        'icon': '💵',
        'color': '#4CAF50',
      },
      {
        'name': 'Vietcombank',
        'type': 'bank',
        'balance': 50000000.0,
        'currency': 'VND',
        'icon': '🏦',
        'color': '#2196F3',
      },
      {
        'name': 'MoMo',
        'type': 'digital',
        'balance': 1500000.0,
        'currency': 'VND',
        'icon': '📱',
        'color': '#E91E63',
      },
    ];

    for (final account in dummyAccounts) {
      await into(accounts).insert(
        AccountsCompanion(
          name: Value(account['name'] as String),
          type: Value(account['type'] as String),
          balance: Value(account['balance'] as double),
          currency: Value(account['currency'] as String),
          icon: Value(account['icon'] as String),
          color: Value(account['color'] as String),
        ),
      );
    }
  }

  Future<void> _insertDummyUserProfile() async {
    await into(userProfiles).insert(
      const UserProfilesCompanion(
        name: Value('Người dùng mẫu'),
        email: Value('demo@example.com'),
        phoneNumber: Value('0123456789'),
        avatarUrl: Value(null),
        currency: Value('VND'),
        language: Value('vi'),
        notificationsEnabled: Value(true),
        biometricEnabled: Value(false),
      ),
    );
  }
  
  // Transaction queries
  Future<List<TransactionEntity>> getAllTransactions() => select(transactions).get();
  
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }
  
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);
  
  Future<bool> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);
  
  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
  
  // Category queries
  Future<List<CategoryEntity>> getAllCategories() => select(categories).get();
  
  Future<List<CategoryEntity>> getCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();
  
  // Budget queries
  Future<List<BudgetEntity>> getAllBudgets() => select(budgets).get();
  
  Future<BudgetEntity?> getBudgetById(int id) =>
      (select(budgets)..where((b) => b.id.equals(id))).getSingleOrNull();
  
  // Goal queries
  Future<List<GoalEntity>> getActiveGoals() =>
      (select(goals)..where((g) => g.isCompleted.equals(false))).get();
  
  // Account queries
  Future<List<AccountEntity>> getAllAccounts() => select(accounts).get();
  
  Future<double> getTotalBalance() async {
    final allAccounts = await select(accounts).get();
    return allAccounts.fold<double>(0.0, (double sum, account) => sum + account.balance);
  }
  
  // Sync queries
  Future<List<SyncLogEntity>> getUnsyncedLogs() =>
      (select(syncLogs)..where((s) => s.isSynced.equals(false))).get();
  
  Future<void> markLogAsSynced(int id) =>
      (update(syncLogs)..where((s) => s.id.equals(id)))
          .write(const SyncLogsCompanion(isSynced: Value(true)));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    print('🔵 Opening database connection...');
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    print('🔵 Database path: ${file.path}');
    
    // Check if database exists
    if (file.existsSync()) {
      print('🔵 Using existing database at: ${file.path}');
    } else {
      print('🔵 Creating new database at: ${file.path}');
    }
    
    return NativeDatabase.createInBackground(file);
  });
}