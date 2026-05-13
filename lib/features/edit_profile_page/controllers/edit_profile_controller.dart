import 'package:flutter/material.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:mobile_project/features/edit_profile_page/models/user_profile.dart';

class EditProfileController extends ChangeNotifier {
  UserProfile? userProfile;
  bool isLoading = true;
  String? errorMessage;

  final String phone;

  EditProfileController({required this.phone}) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/$phone');
      if (response.statusCode == 200 && response.data != null) {
        userProfile = UserProfile.fromJson(response.data);
      } else {
        errorMessage = "Profile not found";
      }
    } catch (e) {
      errorMessage = "Failed to load profile: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String birthday,
    required String gender,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedData = {
        'first_name': firstName,
        'last_name': lastName,
        'birthday': birthday,
        'gender': gender,
      };

      final response = await ApiService.put('/users/$phone', data: updatedData);

      if (response.statusCode == 200) {
        userProfile = UserProfile.fromJson(response.data);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to update profile";
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Failed to update profile: $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
