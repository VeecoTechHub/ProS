import 'package:get/get.dart';
import 'package:pro_z/src/services/services.dart';
import 'package:pro_z/src/store/store_index.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class ProZ {
  static Future init() async {
    Get.put<HttpSetting>(HttpSetting());
    StreamingSharedPreferences sharedPreferences =
        await StreamingSharedPreferences.instance;
    Get.put<StorageService>(StorageService(sharedPreferences));
  }
}
