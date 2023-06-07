import 'package:get/get.dart';

import '../services/services.dart';

class HttpSetting extends GetxController {
  static HttpSetting get to => Get.find();
  final RxString _token = ''.obs;
  set token(value) => _token.value = value;
  String get token => _token.value;
  final RxString _baseUrl = ''.obs;
  set baseUrl(value) => _baseUrl.value = value;
  String get baseUrl => _baseUrl.value;
  /// 保存 token
  Future<void> setToken(String value) async {
    _token.value = value;
    _token.refresh();
    await StorageService.to.setString('STORAGE_USER_TOKEN_KEY', value);
  }
  Future<void> setBaseUrl(String value) async {
    _baseUrl.value = value;
    _baseUrl.refresh();
    await StorageService.to.setString('HTTP_SETTING_BASE_URL', value);
  }
}
