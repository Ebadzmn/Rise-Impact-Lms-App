// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class StorageService extends GetxService {
//   late final GetStorage _box;

//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//   static const String _onboardingKey = 'is_first_time';

//   Future<StorageService> init() async {
//     _box = GetStorage();
//     await GetStorage.init();
//     return this;
//   }

//   // Token management
//   void saveToken(String token) => _box.write(_tokenKey, token);
//   String? getToken() => _box.read(_tokenKey);
//   void removeToken() => _box.remove(_tokenKey);

//   // User data
//   void saveUser(Map<String, dynamic> user) => _box.write(_userKey, user);
//   Map<String, dynamic>? getUser() => _box.read<Map<String, dynamic>>(_userKey);
//   void removeUser() => _box.remove(_userKey);

//   // Onboarding
//   bool get isFirstTime => _box.read(_onboardingKey) ?? true;
//   void setOnboardingCompleted() => _box.write(_onboardingKey, false);

//   // Clear all stored data
//   void clearAll() => _box.erase();
// }
