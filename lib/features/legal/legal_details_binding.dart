import 'package:get/get.dart';
import 'legal_details_controller.dart';

class LegalDetailsBinding extends Bindings {
  final String slug;
  LegalDetailsBinding({required this.slug});

  @override
  void dependencies() {
    Get.delete<LegalDetailsController>();
    Get.lazyPut<LegalDetailsController>(
      () => LegalDetailsController(slug: slug),
    );
  }
}
