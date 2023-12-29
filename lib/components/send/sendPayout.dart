import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Http
import 'package:http/http.dart' as http;

import '../api/api_call.dart';
import '../api/constants.dart';
import '../encode.dart';
import 'getFingerprint.dart';

Future<void> makePostRequest(
    String requestBody, Function(String) callback) async {
  String url = '$BASEURL/payout';

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(<String, String>{
      'encrypted': requestBody,
    }),
  );

  callback(response.statusCode.toString());

  Fluttertoast.showToast(
      msg: response.body,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

String createJsonObject(String fingerprint, String uid, int time, String method,
    String amount, String country, String email, int points) {
  Map<String, dynamic> jsonObject = {
    'fingerprint': fingerprint,
    'uid': uid,
    'time': time,
    'method': method,
    'amount': amount,
    'email': email,
    'country': country,
    'points': points
  };

  String jsonString = jsonEncode(jsonObject);
  return (jsonString);
}

final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;

Future<void> sendPayout(String amount, String method, String email, int points,
    Function(String) callback) async {
  // Get current time
  int getEpochTimeString() => (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  var req = createJsonObject(
      await getFingerprint(),
      getUserInfo()!,
      getEpochTimeString(),
      method,
      amount,
      systemLocales.first.countryCode!,
      email,
      points);

  makePostRequest(await encrypt(req), (response) {
    callback(response);
  });
}
