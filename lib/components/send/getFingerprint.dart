import 'package:package_info_plus/package_info_plus.dart';

Future<String> getFingerprint() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String sha1 = packageInfo.buildSignature;
  //return sha1;
  return "068F8A165A98267CB396E7C3254CD29509D38194";
}
