import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../global_enum/enum_index.dart';

extension StringExtension on String? {
  // String toBaseUrl() {
  //   switch (this) {
  //     case AGENT:
  //       return AGENT_BASE_URL;
  //     case CUSTOMER:
  //       return CUSTOMER_BASE_URL;
  //     default:
  //       return CUSTOMER_BASE_URL;
  //   }
  // }
  String toDOB({String format = 'yyyy-MM-dd'}) {
    if (this == null) {
      return '';
    }
    final nric = this!;
    String year = this!.substring(0, 2);
    String month = int.parse(this!.substring(2, 4)).toString();
    String day = this!.substring(4, 6);
    String now = DateTime.now().toString();
    String decade = now.substring(0, 2);
    year = int.parse(now.substring(2, 4)) > int.parse(year) ? decade + year : "19$year";
    DateTime dob = DateTime(int.parse(year), int.parse(month), int.parse(day));
    return nric.isValidNRIC ? DateFormat(format).format(dob) : '';
  }

  bool get isValidNRIC {
    // Check if the IC number is valid
    if (this?.length != 12) {
      return false; // IC number should have exactly 12 digits
    }

    // Extract the birthdate part from the IC number
    String birthdateStr = this!.substring(0, 6); // YYMMDD

    // Extract date parts
    String dayStr = birthdateStr.substring(4, 6);
    String monthStr = birthdateStr.substring(2, 4);
    String yearStr = birthdateStr.substring(0, 2);

    // Convert YY to YYYY, considering the century
    int year = int.parse(yearStr) >= 22 ? 1900 + int.parse(yearStr) : 2000 + int.parse(yearStr);
    int month = int.parse(monthStr);
    int day = int.parse(dayStr);

    // Check for valid month and day
    if (month < 1 || month > 12) {
      return false;
    }

    // Check for valid day based on month and year
    try {
      DateTime birthdate = DateTime(year, month, day);
      // Check if the day is valid for the given month and year
      return birthdate.day == day;
    } catch (e) {
      return false;
    }
  }

  String get toGender => int.parse(this!.substring(this!.length - 1)) % 2 == 0 ? 'Female' : 'Male';

  String toBase64() => this != null ? utf8.fuse(base64).encode(this!) : '';

  String toCurrency() => this != null ? "RM ${NumberFormat("#,##0.00", "en_US").format(double.parse(this!))}" : '';

  bool isValidEmail() {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(this ?? '');
  }

  Future<Uint8List> toByte() async => (await NetworkAssetBundle(Uri.parse(this!)).load(this!)).buffer.asUint8List();

  Uri? toUri() => Uri.tryParse(this!);

  MediaType mediaType() {
    final extension = this!.toLowerCase();
    if (extension.endsWith('jpg') || extension.endsWith('png') || extension.endsWith('jpeg')) {
      return MediaType.image;
    } else if (extension.endsWith('mp4') || extension.endsWith('mov')) {
      return MediaType.video;
    } else {
      return MediaType.image;
    }
  }

  String toTitleCase() {
    if (this == null) {
      return '';
    }
    return this!.split(' ').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
  }
}
