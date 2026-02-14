// import 'package:get/get.dart';
// import '../services/storage_service.dart';

// class ApiInterceptor {
//   // Request interceptor - adds auth token to headers
//   static Future<Request<T>> requestInterceptor<T>(Request<T> request) async {
//     final storageService = Get.find<StorageService>();
//     final token = storageService.getToken();

//     if (token != null && token.isNotEmpty) {
//       request.headers['Authorization'] = 'Bearer $token';
//     }

//     return request;
//   }

//   // Response interceptor - handles common response cases
//   static Future<dynamic> responseInterceptor(
//     Request request,
//     Response response,
//   ) async {
//     if (response.statusCode == 401) {
//       // Handle unauthorized - e.g., redirect to login
//       Get.find<StorageService>().clearAll();
//       // Get.offAllNamed(AppRoutes.login);
//     }
//     return response;
//   }
// }
