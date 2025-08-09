import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';

// Global database instance to persist across hot reloads
AppDatabase? _databaseInstance;

final databaseProvider = Provider<AppDatabase>((ref) {
  // Keep the same database instance during development
  _databaseInstance ??= AppDatabase();
  
  // Dispose the old database when the provider is disposed
  ref.onDispose(() {
    // Don't close the database on hot reload in debug mode
    // _databaseInstance?.close();
  });
  
  return _databaseInstance!;
});