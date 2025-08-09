import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../datasources/local/database.dart';
import '../models/auth_model.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/auth_persistence.dart';

class AuthService {
  final AppDatabase _database;

  AuthService(this._database);

  // Generate salt for password hashing
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Hash password with salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate reset token
  String _generateResetToken() {
    final random = Random.secure();
    final tokenBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(tokenBytes);
  }

  // Register new user
  Future<AuthResult> register(RegisterRequest request) async {
    try {
      print('🔵 Starting registration for email: ${request.email}');
      print('🔵 Database instance: ${_database.runtimeType}');
      
      // Force database initialization
      print('🔵 Testing database connection...');
      await _database.customSelect('SELECT 1').get();
      print('🔵 Database connection OK');
      // Check if email already exists
      print('🔵 Checking if email exists...');
      final existingUser = await (_database.select(_database.users)
            ..where((u) => u.email.equals(request.email)))
          .getSingleOrNull();
      
      print('🔵 Existing user found: ${existingUser != null}');

      if (existingUser != null) {
        return AuthResult.failure('Email đã được sử dụng');
      }

      // Validate input
      if (request.email.isEmpty || request.password.isEmpty || request.fullName.isEmpty) {
        return AuthResult.failure('Vui lòng điền đầy đủ thông tin');
      }

      if (!_isValidEmail(request.email)) {
        return AuthResult.failure('Email không hợp lệ');
      }

      if (request.password.length < 6) {
        return AuthResult.failure('Mật khẩu phải có ít nhất 6 ký tự');
      }

      // Create user
      print('🔵 Creating user...');
      final salt = _generateSalt();
      final passwordHash = _hashPassword(request.password, salt);

      print('🔵 Inserting user into database...');
      final userEntity = await _database.into(_database.users).insertReturning(
            UsersCompanion(
              email: Value(request.email),
              passwordHash: Value(passwordHash),
              salt: Value(salt),
              fullName: Value(request.fullName),
              phoneNumber: Value(request.phoneNumber),
            ),
          );
      
      print('🔵 User created with ID: ${userEntity.id}');

      final user = User(
        id: userEntity.id,
        email: userEntity.email,
        fullName: userEntity.fullName,
        phoneNumber: userEntity.phoneNumber,
        avatarUrl: userEntity.avatarUrl,
        isEmailVerified: userEntity.isEmailVerified,
        isActive: userEntity.isActive,
        lastLoginAt: userEntity.lastLoginAt,
        createdAt: userEntity.createdAt,
        updatedAt: userEntity.updatedAt,
      );

      // Save session
      await AuthPersistence.saveUserSession(user.id);

      return AuthResult.success(
        user: user,
        message: 'Đăng ký thành công',
      );
    } on DatabaseException catch (e) {
      print('🔴 Database Exception: $e');
      return AuthResult.failure('Lỗi cơ sở dữ liệu: ${e.message}');
    } catch (e) {
      print('🔴 General Exception: $e');
      print('🔴 Exception type: ${e.runtimeType}');
      return AuthResult.failure('Lỗi đăng ký: $e');
    }
  }

  // Login user
  Future<AuthResult> login(LoginRequest request) async {
    try {
      if (request.email.isEmpty || request.password.isEmpty) {
        return AuthResult.failure('Vui lòng nhập email và mật khẩu');
      }

      // Find user by email
      final userEntity = await (_database.select(_database.users)
            ..where((u) => u.email.equals(request.email) & u.isActive.equals(true)))
          .getSingleOrNull();

      if (userEntity == null) {
        return AuthResult.failure('Email hoặc mật khẩu không đúng');
      }

      // Verify password
      final passwordHash = _hashPassword(request.password, userEntity.salt);
      if (passwordHash != userEntity.passwordHash) {
        return AuthResult.failure('Email hoặc mật khẩu không đúng');
      }

      // Update last login
      await (_database.update(_database.users)..where((u) => u.id.equals(userEntity.id)))
          .write(UsersCompanion(
        lastLoginAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));

      final user = User(
        id: userEntity.id,
        email: userEntity.email,
        fullName: userEntity.fullName,
        phoneNumber: userEntity.phoneNumber,
        avatarUrl: userEntity.avatarUrl,
        isEmailVerified: userEntity.isEmailVerified,
        isActive: userEntity.isActive,
        lastLoginAt: DateTime.now(),
        createdAt: userEntity.createdAt,
        updatedAt: DateTime.now(),
      );

      // Save session
      await AuthPersistence.saveUserSession(user.id);

      return AuthResult.success(
        user: user,
        message: 'Đăng nhập thành công',
      );
    } on DatabaseException catch (e) {
      return AuthResult.failure('Lỗi cơ sở dữ liệu: ${e.message}');
    } catch (e) {
      return AuthResult.failure('Lỗi đăng nhập: $e');
    }
  }

  // Logout user
  Future<AuthResult> logout() async {
    try {
      await AuthPersistence.clearUserSession();
      return AuthResult.success(message: 'Đăng xuất thành công');
    } catch (e) {
      return AuthResult.failure('Lỗi đăng xuất: $e');
    }
  }

  // Forgot password
  Future<AuthResult> forgotPassword(ForgotPasswordRequest request) async {
    try {
      if (request.email.isEmpty) {
        return AuthResult.failure('Vui lòng nhập email');
      }

      // Find user by email
      final userEntity = await (_database.select(_database.users)
            ..where((u) => u.email.equals(request.email) & u.isActive.equals(true)))
          .getSingleOrNull();

      if (userEntity == null) {
        return AuthResult.failure('Không tìm thấy tài khoản với email này');
      }

      // Generate reset token
      final resetToken = _generateResetToken();
      final expiry = DateTime.now().add(const Duration(hours: 1)); // Token expires in 1 hour

      await (_database.update(_database.users)..where((u) => u.id.equals(userEntity.id)))
          .write(UsersCompanion(
        resetPasswordToken: Value(resetToken),
        resetPasswordExpiry: Value(expiry),
        updatedAt: Value(DateTime.now()),
      ));

      // In real app, send email with reset token
      // For demo, we just return success with the token
      return AuthResult.success(
        token: resetToken,
        message: 'Link đặt lại mật khẩu đã được gửi đến email của bạn',
      );
    } catch (e) {
      return AuthResult.failure('Lỗi xử lý: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(ResetPasswordRequest request) async {
    try {
      if (request.token.isEmpty || request.newPassword.isEmpty) {
        return AuthResult.failure('Thông tin không hợp lệ');
      }

      if (request.newPassword.length < 6) {
        return AuthResult.failure('Mật khẩu phải có ít nhất 6 ký tự');
      }

      // Find user by reset token
      final userEntity = await (_database.select(_database.users)
            ..where((u) => u.resetPasswordToken.equals(request.token) &
                          u.resetPasswordExpiry.isBiggerThanValue(DateTime.now())))
          .getSingleOrNull();

      if (userEntity == null) {
        return AuthResult.failure('Token không hợp lệ hoặc đã hết hạn');
      }

      // Update password
      final newPasswordHash = _hashPassword(request.newPassword, userEntity.salt);

      await (_database.update(_database.users)..where((u) => u.id.equals(userEntity.id)))
          .write(UsersCompanion(
        passwordHash: Value(newPasswordHash),
        resetPasswordToken: const Value(null),
        resetPasswordExpiry: const Value(null),
        updatedAt: Value(DateTime.now()),
      ));

      return AuthResult.success(message: 'Đặt lại mật khẩu thành công');
    } catch (e) {
      return AuthResult.failure('Lỗi đặt lại mật khẩu: $e');
    }
  }

  // Change password
  Future<AuthResult> changePassword(ChangePasswordRequest request) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return AuthResult.failure('Vui lòng đăng nhập');
      }

      if (request.currentPassword.isEmpty || request.newPassword.isEmpty) {
        return AuthResult.failure('Vui lòng nhập đầy đủ thông tin');
      }

      if (request.newPassword.length < 6) {
        return AuthResult.failure('Mật khẩu mới phải có ít nhất 6 ký tự');
      }

      // Get user entity to verify current password
      final userEntity = await (_database.select(_database.users)
            ..where((u) => u.id.equals(currentUser.id)))
          .getSingle();

      // Verify current password
      final currentPasswordHash = _hashPassword(request.currentPassword, userEntity.salt);
      if (currentPasswordHash != userEntity.passwordHash) {
        return AuthResult.failure('Mật khẩu hiện tại không đúng');
      }

      // Update password
      final newPasswordHash = _hashPassword(request.newPassword, userEntity.salt);

      await (_database.update(_database.users)..where((u) => u.id.equals(currentUser.id)))
          .write(UsersCompanion(
        passwordHash: Value(newPasswordHash),
        updatedAt: Value(DateTime.now()),
      ));

      return AuthResult.success(message: 'Đổi mật khẩu thành công');
    } catch (e) {
      return AuthResult.failure('Lỗi đổi mật khẩu: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userId = await AuthPersistence.getCurrentUserId();
      final isLoggedIn = await AuthPersistence.isLoggedIn();

      if (userId == null || !isLoggedIn) {
        if (kDebugMode) {
          print('🔴 No valid session found');
        }
        return null;
      }

      final userEntity = await (_database.select(_database.users)
            ..where((u) => u.id.equals(userId) & u.isActive.equals(true)))
          .getSingleOrNull();

      if (userEntity == null) {
        if (kDebugMode) {
          print('🔴 User not found in database, clearing session');
        }
        await AuthPersistence.clearUserSession();
        return null;
      }

      if (kDebugMode) {
        print('🟢 Current user found: ${userEntity.email}');
      }

      return User(
        id: userEntity.id,
        email: userEntity.email,
        fullName: userEntity.fullName,
        phoneNumber: userEntity.phoneNumber,
        avatarUrl: userEntity.avatarUrl,
        isEmailVerified: userEntity.isEmailVerified,
        isActive: userEntity.isActive,
        lastLoginAt: userEntity.lastLoginAt,
        createdAt: userEntity.createdAt,
        updatedAt: userEntity.updatedAt,
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error getting current user: $e');
      }
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      return await AuthPersistence.isLoggedIn();
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error checking login status: $e');
      }
      return false;
    }
  }


  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return AuthResult.failure('Vui lòng đăng nhập');
      }

      await (_database.update(_database.users)..where((u) => u.id.equals(currentUser.id)))
          .write(UsersCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        phoneNumber: phoneNumber != null ? Value(phoneNumber) : const Value.absent(),
        avatarUrl: avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));

      return AuthResult.success(message: 'Cập nhật thông tin thành công');
    } catch (e) {
      return AuthResult.failure('Lỗi cập nhật: $e');
    }
  }

  // Delete user account and all related data
  Future<AuthResult> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return AuthResult.failure('Vui lòng đăng nhập');
      }

      // Delete all related data first
      await _database.transaction(() async {
        // Delete transactions (if any foreign key relationships exist)
        // await (_database.delete(_database.transactions)..where((t) => t.accountId.equals(currentUser.id.toString()))).go();
        
        // Delete all user data
        await (_database.delete(_database.transactions)).go();
        await (_database.delete(_database.budgets)).go();
        await (_database.delete(_database.goals)).go();
        await (_database.delete(_database.notifications)).go();
        await (_database.delete(_database.userProfiles)).go();
        await (_database.delete(_database.syncLogs)).go();
        await (_database.delete(_database.accounts)).go();
        
        // Finally delete the user account
        await (_database.delete(_database.users)..where((u) => u.id.equals(currentUser.id))).go();
      });

      // Clear session
      await AuthPersistence.clearUserSession();

      return AuthResult.success(message: 'Tài khoản đã được xóa thành công');
    } catch (e) {
      return AuthResult.failure('Lỗi xóa tài khoản: $e');
    }
  }
}