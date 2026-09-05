import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!AppConfig.useMockMode) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: .env file not found or failed to load: $e');
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      
      // Enable Firestore Persistence for faster local data access
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Initialize background services WITHOUT awaiting to speed up app boot
      _initializeBackgroundServices();

    } catch (e) {
      debugPrint('CRITICAL: Firebase initialization failed: $e');
    }
  }

  await Hive.initFlutter();
  runApp(const ResumeBuilderApp());
}

/// Services that can load in the background without blocking the UI.
void _initializeBackgroundServices() {
  // App Check
  FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaEnterpriseProvider('YOUR_COPIED_SITE_KEY_ID'),
    providerAndroid: const AndroidPlayIntegrityProvider(),
    providerApple: const AppleDeviceCheckProvider(),
  ).catchError((e) {
    debugPrint('App Check Background Init Error: $e');
  });

  // Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  )).then((_) {
    return remoteConfig.setDefaults(const {
      'model_name': 'gemini-1.5-flash',
    });
  }).then((_) {
    return remoteConfig.fetchAndActivate();
  }).catchError((e) {
    debugPrint('Remote Config Background Init Error: $e');
    return false;
  });
}
