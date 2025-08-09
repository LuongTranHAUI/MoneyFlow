import 'package:drift/drift.dart';
import '../datasources/local/database.dart';
import '../models/user_profile_model.dart';
import '../../core/errors/app_exception.dart';

class UserProfileService {
  final AppDatabase _database;

  UserProfileService(this._database);

  Future<UserProfile?> getUserProfile() async {
    try {
      final profileEntry = await (_database.select(_database.userProfiles)
            ..limit(1))
          .getSingleOrNull();

      if (profileEntry == null) return null;

      return UserProfile(
        id: profileEntry.id,
        name: profileEntry.name,
        email: profileEntry.email,
        phoneNumber: profileEntry.phoneNumber,
        avatarUrl: profileEntry.avatarUrl,
        currency: profileEntry.currency,
        language: profileEntry.language,
        notificationsEnabled: profileEntry.notificationsEnabled,
        biometricEnabled: profileEntry.biometricEnabled,
        createdAt: profileEntry.createdAt,
        updatedAt: profileEntry.updatedAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tải thông tin hồ sơ: $e');
    }
  }

  Future<UserProfile> createUserProfile({
    required String name,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String currency = 'VND',
    String language = 'vi',
    bool notificationsEnabled = true,
    bool biometricEnabled = false,
  }) async {
    try {
      final existing = await getUserProfile();
      if (existing != null) {
        throw const AppException(message: 'Hồ sơ người dùng đã tồn tại');
      }

      final profileEntry = await _database.into(_database.userProfiles).insertReturning(
            UserProfilesCompanion(
              name: Value(name),
              email: Value(email),
              phoneNumber: Value(phoneNumber),
              avatarUrl: Value(avatarUrl),
              currency: Value(currency),
              language: Value(language),
              notificationsEnabled: Value(notificationsEnabled),
              biometricEnabled: Value(biometricEnabled),
            ),
          );

      return UserProfile(
        id: profileEntry.id,
        name: profileEntry.name,
        email: profileEntry.email,
        phoneNumber: profileEntry.phoneNumber,
        avatarUrl: profileEntry.avatarUrl,
        currency: profileEntry.currency,
        language: profileEntry.language,
        notificationsEnabled: profileEntry.notificationsEnabled,
        biometricEnabled: profileEntry.biometricEnabled,
        createdAt: profileEntry.createdAt,
        updatedAt: profileEntry.updatedAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tạo hồ sơ người dùng: $e');
    }
  }

  Future<UserProfile> updateUserProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? currency,
    String? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    try {
      final existing = await getUserProfile();
      if (existing == null) {
        throw const AppException(message: 'Không tìm thấy hồ sơ người dùng');
      }

      await (_database.update(_database.userProfiles)
            ..where((p) => p.id.equals(existing.id)))
          .write(
        UserProfilesCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          email: email != null ? Value(email) : const Value.absent(),
          phoneNumber: phoneNumber != null ? Value(phoneNumber) : const Value.absent(),
          avatarUrl: avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
          currency: currency != null ? Value(currency) : const Value.absent(),
          language: language != null ? Value(language) : const Value.absent(),
          notificationsEnabled: notificationsEnabled != null 
              ? Value(notificationsEnabled) 
              : const Value.absent(),
          biometricEnabled: biometricEnabled != null 
              ? Value(biometricEnabled) 
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updatedProfile = await getUserProfile();
      if (updatedProfile == null) {
        throw const AppException(message: 'Không thể tải hồ sơ sau khi cập nhật');
      }

      return updatedProfile;
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật hồ sơ: $e');
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      await _database.delete(_database.userProfiles).go();
    } catch (e) {
      throw AppException(message: 'Không thể xóa hồ sơ người dùng: $e');
    }
  }

  Future<bool> isFirstTimeUser() async {
    try {
      final profile = await getUserProfile();
      return profile == null;
    } catch (e) {
      return true;
    }
  }

  Future<UserProfile> getOrCreateDefaultProfile() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        return profile;
      }

      return createUserProfile(
        name: 'Người dùng mới',
        email: '',
      );
    } catch (e) {
      throw AppException(message: 'Không thể tạo hồ sơ mặc định: $e');
    }
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      await updateUserProfile(notificationsEnabled: enabled);
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật cài đặt thông báo: $e');
    }
  }

  Future<void> updateBiometricSettings(bool enabled) async {
    try {
      await updateUserProfile(biometricEnabled: enabled);
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật cài đặt sinh trắc học: $e');
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      await updateUserProfile(language: language);
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật ngôn ngữ: $e');
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      await updateUserProfile(currency: currency);
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật đơn vị tiền tệ: $e');
    }
  }

  Future<UserProfile> updateAvatar(String avatarUrl) async {
    try {
      return await updateUserProfile(avatarUrl: avatarUrl);
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật ảnh đại diện: $e');
    }
  }

  Future<UserProfile> updateContactInfo({
    String? phoneNumber,
    String? email,
  }) async {
    try {
      return await updateUserProfile(
        phoneNumber: phoneNumber,
        email: email,
      );
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật thông tin liên hệ: $e');
    }
  }
}