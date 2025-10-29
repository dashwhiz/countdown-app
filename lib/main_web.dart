import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/app_logger.dart';
import 'app/app_strings.dart';
import 'app/app_theme.dart';
import 'services/appwrite_service.dart';
import 'web/public_countdown_screen.dart';

/// Web-specific entry point for public countdown pages
///
/// Handles URL parameters to display shared countdowns
/// Example: https://yourapp.com/?id=abc123xyz
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info('[Web] Initializing web app...');

    // Initialize timezone database
    tz.initializeTimeZones();

    // Initialize Appwrite service (no storage service needed for web)
    await Get.putAsync(() => AppwriteService().init());

    AppLogger.info('[Web] Web app initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.fatal('[Web] Failed to initialize web app', e, stackTrace);
  }

  runApp(const CountdownWebApp());
}

class CountdownWebApp extends StatelessWidget {
  const CountdownWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the slug from URL query parameters
    // Example: ?id=abc123xyz
    final uri = Uri.base;
    final slug = uri.queryParameters['id'];

    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: slug != null && slug.isNotEmpty
          ? PublicCountdownScreen(slug: slug)
          : const _InvalidUrlScreen(),
    );
  }
}

/// Screen shown when no valid slug is provided
class _InvalidUrlScreen extends StatelessWidget {
  const _InvalidUrlScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.link_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.invalidLink,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.invalidLinkMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Link to download the app
                // TODO: Update with actual app store links
              },
              child: Text(AppStrings.getTheApp),
            ),
          ],
        ),
      ),
    );
  }
}
