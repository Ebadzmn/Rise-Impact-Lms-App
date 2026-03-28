import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Global Services
  await Get.putAsync(() => StorageService().init());
  
  runApp(const App());
}
