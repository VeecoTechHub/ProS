import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../entities/entities_index.dart';

class StorageService extends GetxService {
  StorageService(this.preferences);

  final StreamingSharedPreferences preferences;

  static StorageService get to => Get.find();

  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> clear() => _prefs.clear();

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> setList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  String getString(String key) {
    return _prefs.getString(key) ?? '';
  }

  int getInt(String key) {
    return _prefs.getInt(key) ?? 0;
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  List<String> getList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> setCustom<T extends Serializable>(String key, T item) async {
    return await preferences.setCustomValue<T>(
      key,
      item,
      adapter: JsonAdapter(
        serializer: (value) => value.toJson(),
        deserializer: (value) => item.fromJson(value as Map<String, dynamic>?),
      ),
    );
  }

  Preference<T> getCustom<T extends Serializable>(String key, T defaultValue) {
    return preferences.getCustomValue<T>(
      key,
      defaultValue: defaultValue,
      adapter: JsonAdapter(
        serializer: (value) => value.toJson(),
        deserializer: (value) => defaultValue.fromJson(value as Map<String, dynamic>?),
      ),
    );
  }

// Future<bool> setCustomList<T extends Serializable>(String key, List<T> item, T defaultValue) async {
//   return await preferences.setCustomValue<List<T>>(
//     key,
//     item,
//     adapter: JsonAdapter(
//       serializer: (value) => value.map((e) => e.toJson()).toList(),
//       deserializer: (value) {
//         return defaultValue.listFromJson(value as List?);
//       },
//     ),
//   );
// }
//
// Preference<List<T>> getCustomList<T extends Serializable>(String key, T item) {
//   return preferences.getCustomValue<List<T>>(
//     key,
//     defaultValue: [],
//     adapter: JsonAdapter(
//       serializer: (value) => value.map((e) => e.toJson()),
//       deserializer: (value) => item.listFromJson(value as List?),
//     ),
//   );
// }
}
