// import 'package:get/get.dart';
// import 'api_endpoints.dart';
// import 'api_interceptor.dart';

// class ApiClient extends GetConnect {
//   @override
//   void onInit() {
//     httpClient.baseUrl = ApiEndpoints.baseUrl;
//     httpClient.defaultContentType = 'application/json';
//     httpClient.timeout = const Duration(seconds: 30);

//     // Add request interceptor
//     httpClient.addRequestModifier<dynamic>(ApiInterceptor.requestInterceptor);

//     // Add response interceptor
//     httpClient.addResponseModifier(ApiInterceptor.responseInterceptor);

//     super.onInit();
//   }

//   // GET request
//   Future<Response> getRequest(
//     String url, {
//     Map<String, String>? headers,
//   }) async {
//     return await get(url, headers: headers);
//   }

//   // POST request
//   Future<Response> postRequest(
//     String url,
//     dynamic body, {
//     Map<String, String>? headers,
//   }) async {
//     return await post(url, body, headers: headers);
//   }

//   // PUT request
//   Future<Response> putRequest(
//     String url,
//     dynamic body, {
//     Map<String, String>? headers,
//   }) async {
//     return await put(url, body, headers: headers);
//   }

//   // DELETE request
//   Future<Response> deleteRequest(
//     String url, {
//     Map<String, String>? headers,
//   }) async {
//     return await delete(url, headers: headers);
//   }
// }
