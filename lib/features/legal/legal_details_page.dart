import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'legal_details_controller.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class LegalDetailsPage extends GetView<LegalDetailsController> {
  const LegalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Legal Details',
          showBackButton: true,
          onBackCallback: () => context.pop(),
        ),
      ),
      body: Obx(() {
        if (controller.detailsState.value.isLoading) {
          return _buildLoadingShimmer();
        }

        if (controller.detailsState.value.isError) {
          return _buildErrorState();
        }

        final detail = controller.legalDetail.value;
        if (detail == null) {
          return _buildErrorState(error: 'Document not found');
        }

        String formattedDate = '';
        try {
          final dt = DateTime.parse(detail.updatedAt);
          formattedDate = DateFormat('dd MMM yyyy').format(dt);
        } catch (_) {}

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Last Updated: $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              HtmlWidget(
                detail.content,
                textStyle: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 32, width: 200, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 16, width: 150, color: Colors.white),
            const SizedBox(height: 32),
            Container(height: 200, width: double.infinity, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 150, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({String? error}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              error ?? controller.errorMessage.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.fetchLegalDetails(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A7554),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
