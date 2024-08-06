import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pro_z/src/services/services.dart';
import 'package:pro_z/src/store/store_index.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class ProZ {
  static Future init() async {
    Get.put<HttpSetting>(HttpSetting());
    final preference = await StreamingSharedPreferences.instance;
    await Get.putAsync<StorageService>(() => StorageService(preference).init());
    await Firebase.initializeApp();

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
      );
      return true;
    };
  }
}
