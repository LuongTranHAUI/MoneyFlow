import 'package:drift/drift.dart';

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

class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.isEmailVerified,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success({User? user, String? token, String? message}) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
      message: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}