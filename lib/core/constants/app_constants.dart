class AppConstants {
  static const String appName = 'Finance Tracker';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String dbName = 'finance_tracker.db';
  static const int dbVersion = 1;
  
  // Cache
  static const Duration cacheDefaultTTL = Duration(minutes: 15);
  static const String cacheBoxName = 'cache';
  
  // Sync
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  
  // Security
  static const String secureStorageKey = 'secure_storage';
  static const int sessionTimeout = 30; // minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}