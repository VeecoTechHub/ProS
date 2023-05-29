import 'dart:convert';
import 'dart:developer';

// ignore: non_constant_identifier_names
ProZPrint(dynamic json, {String name = '', bool formatted = false}) {
  if (formatted) {
    var encoder = const JsonEncoder.withIndent("     ");
    log(name: name, encoder.convert(json));
  } else {
    log(name: name, jsonEncode(json));
  }
}
