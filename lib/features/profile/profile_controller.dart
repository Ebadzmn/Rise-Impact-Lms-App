import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_model.dart';
import '../legal/legal_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/services/storage_service.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ProfileModel?> profileData = Rx<ProfileModel?>(null);
  final Rx<BadgeResponseModel?> badgeData = Rx<BadgeResponseModel?>(null);
  final RxList<LegalModel> legalList = <LegalModel>[].obs;

  // Specific states for Legal section – LegalLoading, LegalLoaded, LegalError
  final Rx<RxStatus> legalState = RxStatus.loading().obs;

  final RxBool isUpdating = false.obs;
  final RxBool isChangingPassword = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isOldPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  void toggleOldPasswordVisibility() => isOldPasswordVisible.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    fetchData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    genderController.dispose();
    dobController.dispose();
    locationController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void _loadInitialData() {
    final storage = Get.find<StorageService>();
    final cachedUser = storage.getUser();
    if (cachedUser != null) {
      final model = ProfileModel.fromJson(cachedUser);
      profileData.value = model;
      _populateControllers(model);
    }
  }

  void _populateControllers(ProfileModel model) {
    nameController.text = model.name;
    emailController.text = model.email;
    genderController.text = model.gender;
    dobController.text = model.dateOfBirth;
    locationController.text = model.location;
    phoneController.text = model.phone;
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Concurrent fetch
      final results = await Future.wait([
        ApiClient.instance.get(ApiEndpoints.profile),
        ApiClient.instance.get(ApiEndpoints.myBadges),
        ApiClient.instance.get(ApiEndpoints.legal),
      ]);

      final profileRes = results[0];
      final badgesRes = results[1];
      final legalRes = results[2];

      // Parse Profile
      Map<String, dynamic> pMap = {};
      if (profileRes.data is String) {
        try {
          pMap = jsonDecode(profileRes.data) as Map<String, dynamic>;
        } catch (_) {}
      } else if (profileRes.data is Map) {
        pMap = Map<String, dynamic>.from(profileRes.data);
      }
      profileData.value = ProfileModel.fromJson(pMap);

      // Update text controllers with fresh data
      _populateControllers(profileData.value!);

      // Update Cache (ignoring specific data wrapper for persistence)
      final storage = Get.find<StorageService>();
      storage.saveUser(pMap['data'] ?? pMap);

      // Parse Badges
      Map<String, dynamic> bMap = {};
      if (badgesRes.data is String) {
        try {
          bMap = jsonDecode(badgesRes.data) as Map<String, dynamic>;
        } catch (_) {}
      } else if (badgesRes.data is Map) {
        bMap = Map<String, dynamic>.from(badgesRes.data);
      }
      badgeData.value = BadgeResponseModel.fromJson(bMap);

      // Parse Legal
      try {
        legalState.value = RxStatus.loading(); // LegalLoading
        Map<String, dynamic> lMap = {};
        if (legalRes.data is String) {
          try {
            lMap = jsonDecode(legalRes.data) as Map<String, dynamic>;
          } catch (_) {}
        } else if (legalRes.data is Map) {
          lMap = Map<String, dynamic>.from(legalRes.data);
        }

        final lList = (lMap['data'] as List? ?? [])
            .map((e) => LegalModel.fromJson(e))
            .toList();
        legalList.assignAll(lList);
        legalState.value = RxStatus.success(); // LegalLoaded
      } catch (e) {
        legalState.value = RxStatus.error(e.toString()); // LegalError
      }
    } catch (e, stack) {
      debugPrint('Profile/Badges Fetch Error: $e\n$stack');
      errorMessage.value = e is NetworkException
          ? e.message
          : 'Failed to load profile data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Name is required',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUpdating.value = true;

      final Map<String, dynamic> fields = {
        'name': nameController.text.trim(),
        'gender': genderController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      final Map<String, File> files = {};
      if (selectedImage.value != null) {
        files['profilePicture'] = selectedImage.value!;
      }

      final response = await ApiClient.instance.patchMultipart(
        ApiEndpoints.updateProfile,
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF576045),
          colorText: Colors.white,
        );
        selectedImage.value = null; // Clear selected image
        fetchData(); // Refresh profile info
      }
    } catch (e) {
      debugPrint('Profile Update Error: $e');
      Get.snackbar(
        'Error',
        e is NetworkException ? e.message : 'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      isChangingPassword.value = true;

      final response = await ApiClient.instance.post(
        ApiEndpoints.changePassword,
        body: {
          'currentPassword': currentPassword, 
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF576045),
          colorText: Colors.white,
        );
        // Clear fields
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
    } catch (e) {
      debugPrint('Change Password Error: $e');
      Get.snackbar(
        'Error',
        e is NetworkException ? e.message : 'Failed to change password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }
}
