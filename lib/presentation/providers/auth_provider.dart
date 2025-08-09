import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/auth_model.dart';
import '../providers/database_provider.dart';

// Global auth service instance to persist across hot reloads
AuthService? _authServiceInstance;

final authServiceProvider = Provider<AuthService>((ref) {
  final database = ref.watch(databaseProvider);
  
  // Keep the same auth service instance during development
  _authServiceInstance ??= AuthService(database);
  
  return _authServiceInstance!;
});

final currentUserProvider = FutureProvider.autoDispose<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

final isLoggedInProvider = FutureProvider.autoDispose<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  User? _currentUser;

  AuthNotifier(this._authService, this._ref) : super(AuthState.initial) {
    _checkAuthStatus();
  }

  User? get currentUser => _currentUser;

  Future<void> _checkAuthStatus() async {
    try {
      state = AuthState.loading;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        state = AuthState.authenticated;
      } else {
        _currentUser = null;
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      _currentUser = null;
      state = AuthState.error;
    }
  }

  Future<AuthResult> register(RegisterRequest request) async {
    try {
      state = AuthState.loading;
      final result = await _authService.register(request);
      
      if (result.success && result.user != null) {
        _currentUser = result.user;
        state = AuthState.authenticated;
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(isLoggedInProvider);
      } else {
        state = AuthState.unauthenticated;
      }
      
      return result;
    } catch (e) {
      state = AuthState.error;
      return AuthResult.failure('Lỗi đăng ký: $e');
    }
  }

  Future<AuthResult> login(LoginRequest request) async {
    try {
      state = AuthState.loading;
      final result = await _authService.login(request);
      
      if (result.success && result.user != null) {
        _currentUser = result.user;
        state = AuthState.authenticated;
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(isLoggedInProvider);
      } else {
        state = AuthState.unauthenticated;
      }
      
      return result;
    } catch (e) {
      state = AuthState.error;
      return AuthResult.failure('Lỗi đăng nhập: $e');
    }
  }

  Future<AuthResult> logout() async {
    try {
      final result = await _authService.logout();
      
      if (result.success) {
        _currentUser = null;
        state = AuthState.unauthenticated;
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(isLoggedInProvider);
      }
      
      return result;
    } catch (e) {
      return AuthResult.failure('Lỗi đăng xuất: $e');
    }
  }

  Future<AuthResult> forgotPassword(ForgotPasswordRequest request) async {
    try {
      return await _authService.forgotPassword(request);
    } catch (e) {
      return AuthResult.failure('Lỗi xử lý: $e');
    }
  }

  Future<AuthResult> resetPassword(ResetPasswordRequest request) async {
    try {
      return await _authService.resetPassword(request);
    } catch (e) {
      return AuthResult.failure('Lỗi đặt lại mật khẩu: $e');
    }
  }

  Future<AuthResult> changePassword(ChangePasswordRequest request) async {
    try {
      return await _authService.changePassword(request);
    } catch (e) {
      return AuthResult.failure('Lỗi đổi mật khẩu: $e');
    }
  }

  Future<AuthResult> updateProfile({String? fullName, String? phoneNumber, String? avatarUrl}) async {
    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      
      if (result.success) {
        // Refresh current user
        await _checkAuthStatus();
        _ref.invalidate(currentUserProvider);
      }
      
      return result;
    } catch (e) {
      return AuthResult.failure('Lỗi cập nhật: $e');
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      final result = await _authService.deleteAccount();
      
      if (result.success) {
        _currentUser = null;
        state = AuthState.unauthenticated;
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(isLoggedInProvider);
      }
      
      return result;
    } catch (e) {
      return AuthResult.failure('Lỗi xóa tài khoản: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  void refreshAuth() {
    _checkAuthStatus();
  }
}

// Global auth notifier instance to persist across hot reloads
AuthNotifier? _authNotifierInstance;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  // Keep the same auth notifier instance during development
  _authNotifierInstance ??= AuthNotifier(authService, ref);
  
  return _authNotifierInstance!;
});