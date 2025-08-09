import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_persistence.dart';

class AuthDebug {
  static Future<void> logAuthState() async {
    if (!kDebugMode) return;
    
    print('🔍 ===== AUTH DEBUG STATE =====');
    
    try {
      // Check SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      final isLoggedIn = prefs.getBool('is_logged_in');
      final authToken = prefs.getString('auth_token');
      
      print('📱 SharedPreferences:');
      print('   - User ID: $userId');
      print('   - Is Logged In: $isLoggedIn');
      print('   - Auth Token: ${authToken != null ? "Present" : "None"}');
      
      // Check memory cache
      final cachedUserId = await AuthPersistence.getCurrentUserId();
      final cachedIsLoggedIn = await AuthPersistence.isLoggedIn();
      
      print('🧠 Memory Cache:');
      print('   - Cached User ID: $cachedUserId');
      print('   - Cached Is Logged In: $cachedIsLoggedIn');
      
      // Check consistency
      if (userId == cachedUserId && isLoggedIn == cachedIsLoggedIn) {
        print('✅ Auth state is consistent');
      } else {
        print('❌ Auth state mismatch detected!');
      }
      
    } catch (e) {
      print('❌ Error checking auth state: $e');
    }
    
    print('🔍 ===== END AUTH DEBUG =====');
  }
  
  static Future<void> clearAllAuthData() async {
    if (!kDebugMode) return;
    
    print('🧹 Clearing all auth data for debug...');
    
    try {
      await AuthPersistence.clearUserSession();
      print('✅ Auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }
  
  static void logHotReloadEvent() {
    if (!kDebugMode) return;
    
    print('🔥 HOT RELOAD DETECTED - Auth persistence should maintain state');
    logAuthState();
  }
}