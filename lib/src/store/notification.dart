import 'package:get/get.dart';

import '../../pro_z.dart';

class NotificationRead extends GetxController {
  static NotificationRead get to => Get.find();
  final _isRead = false.obs;
  RxBool get isRead => _isRead;

  set isRead(value) => _isRead.value = value;

  Future<bool> updateNotification(bool value) async {
    isRead = value;
    await StorageService.to.setBool('${userID.toString()}_notification', value);
    return isRead.value;
  }

  bool getNewNotification() {
    isRead = StorageService.to.getBool('${userID.toString()}_notification');
    return isRead.value;
  }
}

