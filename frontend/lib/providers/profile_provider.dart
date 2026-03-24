import 'package:flutter/foundation.dart';

import '../services/profile_service.dart';

/// A provider for managing user profile state.
///
class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasAttemptedFetch = false;

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get username => _profileData?['username'] ?? '';
  String get email => _profileData?['email'] ?? '';
  String? get avatar => _profileData?['avatar'];

  Future<void> fetchProfile() async {
    if (_hasAttemptedFetch) return; // Don't fetch multiple times
    _hasAttemptedFetch = true;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profileData = await ProfileService.instance.getProfile();
      print('[ProfileProvider] fetched profile for user: ${_profileData?['username']}');
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      print('Error fetching profile: $e');
      _profileData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset fetch flag to allow refetching (used after login/logout)
  void resetFetchFlag() {
    _hasAttemptedFetch = false;
    print('[ProfileProvider] fetch flag reset');
  }

  /// Clear all profile data (used on logout)
  void clear() {
    _profileData = null;
    _isLoading = false;
    _errorMessage = null;
    _hasAttemptedFetch = false;
    print('[ProfileProvider] profile cleared');
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedData = await ProfileService.instance.updateProfile(
        username: username,
        email: email,
      );
      _profileData = updatedData;
      print('[ProfileProvider] profile updated successfully');
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      print('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAvatar(dynamic imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedData = await ProfileService.instance.uploadAvatar(imageFile);
      _profileData = updatedData;
      print('[ProfileProvider] avatar uploaded successfully');
    } catch (e) {
      _errorMessage = 'Failed to upload avatar: $e';
      print('Error uploading avatar: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
