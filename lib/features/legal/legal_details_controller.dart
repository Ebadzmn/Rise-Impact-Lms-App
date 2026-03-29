import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'legal_model.dart';
import 'dart:convert';
import '../../core/network/api_interceptor.dart';
import 'package:flutter/foundation.dart';

class LegalDetailsController extends GetxController {
  final String slug;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LegalDetailModel?> legalDetail = Rx<LegalDetailModel?>(null);
  
  // Specific states for Legal Details – LegalDetailsLoading, LegalDetailsLoaded
  final Rx<RxStatus> detailsState = RxStatus.loading().obs;

  LegalDetailsController({required this.slug});

  @override
  void onInit() {
    super.onInit();
    fetchLegalDetails();
  }

  Future<void> fetchLegalDetails() async {
    try {
      detailsState.value = RxStatus.loading(); // LegalDetailsLoading
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiClient.instance.get(ApiEndpoints.legalDetails(slug));

      Map<String, dynamic> dataMap = {};
      if (response.data is String) {
        try { dataMap = jsonDecode(response.data) as Map<String, dynamic>; } catch (_) {}
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data);
      }

      legalDetail.value = LegalDetailModel.fromJson(dataMap);
      detailsState.value = RxStatus.success(); // LegalDetailsLoaded

    } catch (e, stack) {
      debugPrint('Legal Details Fetch Error: $e\n$stack');
      errorMessage.value = e is NetworkException ? e.message : 'Failed to load legal data';
      detailsState.value = RxStatus.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
