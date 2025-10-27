import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app_strings.dart';
import 'core/app_theme.dart';
import 'services/storage_service.dart';
import 'services/appwrite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AppwriteService().init());

  runApp(const CountdownApp());
}

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Placeholder(),
    );
  }
}
