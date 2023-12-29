import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

getUniqueDeviceIdentifier() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String uniqueId = androidInfo.androidId;
    return uniqueId;
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    String uniqueId = iosInfo.identifierForVendor;
    return uniqueId;
  }
}
