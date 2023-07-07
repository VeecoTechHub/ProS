import 'package:get/get.dart';
import 'package:pro_z/src/store/store_index.dart';

class ProZ {
  static Future init() async {
    Get.put<HttpSetting>(HttpSetting());
    Get.put<NotificationRead>(NotificationRead());
  }
}
