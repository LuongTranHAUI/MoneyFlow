import 'package:drift/drift.dart';

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

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String currency;
  final String language;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.currency = 'VND',
    this.language = 'vi',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    required this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? currency,
    String? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}