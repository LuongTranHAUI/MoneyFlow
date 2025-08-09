import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPersistence {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _authTokenKey = 'auth_token';
  
  // In-memory cache for development hot reloads
  static int? _cachedUserId;
  static bool? _cachedIsLoggedIn;
  
  static Future<void> saveUserSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserIdKey, userId);
    await prefs.setBool(_isLoggedInKey, true);
    
    // Cache in memory for hot reload persistence
    _cachedUserId = userId;
    _cachedIsLoggedIn = true;
    
    if (kDebugMode) {
      print('🟢 Auth session saved - UserId: $userId');
    }
  }
  
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_authTokenKey);
    
    // Clear memory cache
    _cachedUserId = null;
    _cachedIsLoggedIn = null;
    
    if (kDebugMode) {
      print('🔴 Auth session cleared');
    }
  }
  
  static Future<int?> getCurrentUserId() async {
    // In debug mode, first check memory cache for hot reload persistence
    if (kDebugMode && _cachedUserId != null) {
      print('🟡 Using cached user ID: $_cachedUserId');
      return _cachedUserId;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_currentUserIdKey);
      
      // Cache for next time
      _cachedUserId = userId;
      
      if (kDebugMode) {
        print('🔵 Retrieved user ID from prefs: $userId');
      }
      
      return userId;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error getting user ID: $e');
      }
      return null;
    }
  }
  
  static Future<bool> isLoggedIn() async {
    // In debug mode, first check memory cache for hot reload persistence
    if (kDebugMode && _cachedIsLoggedIn != null) {
      print('🟡 Using cached login status: $_cachedIsLoggedIn');
      return _cachedIsLoggedIn!;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final userId = prefs.getInt(_currentUserIdKey);
      
      // Only consider logged in if both flags are set
      final result = isLoggedIn && userId != null;
      
      // Cache for next time
      _cachedIsLoggedIn = result;
      _cachedUserId = userId;
      
      if (kDebugMode) {
        print('🔵 Retrieved login status from prefs: $result (userId: $userId)');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error checking login status: $e');
      }
      return false;
    }
  }
  
  static void clearMemoryCache() {
    _cachedUserId = null;
    _cachedIsLoggedIn = null;
    
    if (kDebugMode) {
      print('🟡 Memory cache cleared');
    }
  }
}