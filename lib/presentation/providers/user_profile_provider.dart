import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/user_profile_service.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/database_provider.dart';

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final database = ref.watch(databaseProvider);
  return UserProfileService(database);
});

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return service.getUserProfile();
});

final isFirstTimeUserProvider = FutureProvider.autoDispose<bool>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return service.isFirstTimeUser();
});

class UserProfileController extends StateNotifier<AsyncValue<void>> {
  final UserProfileService _service;
  final Ref _ref;

  UserProfileController(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> createUserProfile({
    required String name,
    required String email,
    String? phoneNumber,
    String? avatarUrl,
    String currency = 'VND',
    String language = 'vi',
    bool notificationsEnabled = true,
    bool biometricEnabled = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createUserProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        currency: currency,
        language: language,
        notificationsEnabled: notificationsEnabled,
        biometricEnabled: biometricEnabled,
      );
      
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(isFirstTimeUserProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? currency,
    String? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateUserProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        currency: currency,
        language: language,
        notificationsEnabled: notificationsEnabled,
        biometricEnabled: biometricEnabled,
      );
      
      _ref.invalidate(userProfileProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateNotificationSettings(enabled);
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateBiometricSettings(bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateBiometricSettings(enabled);
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateLanguage(String language) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateLanguage(language);
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateCurrency(String currency) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateCurrency(currency);
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateAvatar(avatarUrl);
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateContactInfo({
    String? phoneNumber,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateContactInfo(
        phoneNumber: phoneNumber,
        email: email,
      );
      _ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteUserProfile() async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteUserProfile();
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(isFirstTimeUserProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> getOrCreateDefaultProfile() async {
    state = const AsyncValue.loading();
    
    try {
      await _service.getOrCreateDefaultProfile();
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(isFirstTimeUserProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, AsyncValue<void>>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileController(service, ref);
});