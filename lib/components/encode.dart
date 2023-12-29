// Encryption
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

encrypt(String s) async {
  String filePath = 'assets/images/public.pem';

  final publicPem = await rootBundle.loadString(filePath);

  final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

  final encrypter =
      Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));

  final encrypted = encrypter.encrypt(s);

  return (encrypted.base64);
}
