import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/presentation/providers/database_provider.dart';

// Provider for all categories
final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final database = ref.watch(databaseProvider);
  return database.getAllCategories();
});

// Provider for categories by type
final categoriesByTypeProvider = FutureProvider.family<List<CategoryEntity>, String>((ref, type) async {
  final database = ref.watch(databaseProvider);
  return database.getCategoriesByType(type);
});

// Simple category model for use in UI
class CategoryModel {
  final String name;
  final String icon;
  final String color;
  final String type;
  
  const CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
  
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      type: entity.type,
    );
  }
  
  // Default categories for fallback
  static const List<CategoryModel> defaultCategories = [
    // Expense categories
    CategoryModel(name: 'Ăn uống', icon: '🍔', color: '#FF5722', type: 'expense'),
    CategoryModel(name: 'Di chuyển', icon: '🚗', color: '#2196F3', type: 'expense'),
    CategoryModel(name: 'Mua sắm', icon: '🛍️', color: '#9C27B0', type: 'expense'),
    CategoryModel(name: 'Giải trí', icon: '🎮', color: '#FF9800', type: 'expense'),
    CategoryModel(name: 'Hóa đơn', icon: '📄', color: '#607D8B', type: 'expense'),
    CategoryModel(name: 'Sức khỏe', icon: '🏥', color: '#F44336', type: 'expense'),
    CategoryModel(name: 'Giáo dục', icon: '📚', color: '#3F51B5', type: 'expense'),
    
    // Income categories
    CategoryModel(name: 'Lương', icon: '💰', color: '#4CAF50', type: 'income'),
    CategoryModel(name: 'Thưởng', icon: '🎁', color: '#8BC34A', type: 'income'),
    CategoryModel(name: 'Đầu tư', icon: '📈', color: '#00BCD4', type: 'income'),
    CategoryModel(name: 'Freelance', icon: '💻', color: '#009688', type: 'income'),
  ];
}

// Provider for UI use - returns default categories if database fails
final categoryProvider = Provider<List<CategoryModel>>((ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  
  return categoriesAsync.when(
    data: (categories) => categories.map((e) => CategoryModel.fromEntity(e)).toList(),
    loading: () => CategoryModel.defaultCategories,
    error: (_, __) => CategoryModel.defaultCategories,
  );
});

// Category state notifier for managing categories
class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryEntity>>> {
  final AppDatabase _database;
  
  CategoryNotifier(this._database) : super(const AsyncValue.loading()) {
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _database.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    try {
      await _database.into(_database.categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: icon,
          color: color,
          type: type,
        ),
      );
      await loadCategories();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
  
  Future<void> updateCategory({
    required int id,
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    try {
      await (_database.update(_database.categories)
            ..where((tbl) => tbl.id.equals(id)))
          .write(
        CategoriesCompanion(
          name: Value(name),
          icon: Value(icon),
          color: Value(color),
          type: Value(type),
        ),
      );
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteCategory(int id) async {
    try {
      await (_database.delete(_database.categories)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}

// State notifier provider
final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryEntity>>>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryNotifier(database);
});