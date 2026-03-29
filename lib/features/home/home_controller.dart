import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'home_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<HomeData?> homeData = Rx<HomeData?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.instance.get(ApiEndpoints.studentHome);

      Map<String, dynamic> responseMap = {};
      if (response.data is String) {
        try { responseMap = jsonDecode(response.data) as Map<String, dynamic>; } catch (_) {}
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      }

      Map<String, dynamic> payload = responseMap;
      if (responseMap.containsKey('data') && responseMap['data'] is Map) {
        // Usually APIs wrap actual object inside "data"
        final dataField = responseMap['data'];
        if (dataField is Map<String, dynamic> && dataField.containsKey('streak')) {
          payload = dataField;
        } else if (responseMap.containsKey('streak')) {
          payload = responseMap;
        }
      }

      homeData.value = HomeData.fromJson(payload.isEmpty ? responseMap : payload);
    } catch (e, stack) {
      debugPrint('Home Fetch Error: $e\n$stack');
      errorMessage.value = 'Failed to load home data';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
