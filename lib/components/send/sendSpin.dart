// get fingerprint
import 'dart:async';
import 'dart:convert';

import 'package:christmas_cash/components/encode.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Http
import 'package:http/http.dart' as http;

import '../api/api_call.dart';
import '../api/constants.dart';
import 'getFingerprint.dart';

Future<void> makePostRequest(
    String requestBody, String id, Function(String) callback) async {
  String url = '$BASEURL/spin/claim';

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  var response = await http.put(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(<String, String>{
      'encrypted': requestBody,
    }),
  );

  print(response.body);

  Fluttertoast.showToast(
      msg: response.body,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);

  callback(response.statusCode.toString());
}

String createJsonObject(String fingerprint, String uid, int time) {
  Map<String, dynamic> jsonObject = {
    'fingerprint': fingerprint,
    'uid': uid,
    'time': time,
  };

  String jsonString = jsonEncode(jsonObject);
  return (jsonString);
}

Future<void> sendSpin(String id, Function(String) callback) async {
  // Get current time
  int getEpochTimeString() => (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  var req = createJsonObject(
      await getFingerprint(), getUserInfo()!, getEpochTimeString());

  makePostRequest(await encrypt(req), id, (response) {
    callback(response);
  });
}
