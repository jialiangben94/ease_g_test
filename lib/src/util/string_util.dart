import 'dart:convert';

import 'package:com_etiqa_flutter_crypto/etiqacrypto.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

// Production Key
// const key = 'agent_on_the_go_epp_secret_key00';
// const keyNB = 'oy7y6t5t8u8jx89ka6c7h3nc7ys7xha7';
// const ivNB = 'i9j7c6j83n7c9ix7';
// const respSecretKey = '5aj7nj3n8cj8cq9k';

// UAT Key
const key = 'i051Z2h1zC0xrnYBzxBwDAAZESSHWwAT';
const iv = 'abcdabcdabcdabcd';
const secretKey = 'v8t3187y1h19022u';

Future<String> encryptAES(String value) async {
  final nkey = Key.fromUtf8(key);
  final niv = IV.fromUtf8(iv);
  final aesEncypter = Encrypter(AES(nkey, mode: AESMode.cbc));
  final encrypted = aesEncypter.encrypt(value, iv: niv);

  return encrypted.base64;
}

bool checkres(String value) {
  if (value.contains("html")) {
    return false;
  } else {
    return true;
  }
}

Future<String> decryptAES(String? value) async {
//  final _key = Key.fromUtf8(key);
//  final _iv = IV.fromUtf8(iv);
//  final aesEncypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: "PKCS7"));
//
//  Encrypted stringToDecrypt = Encrypted.fromBase64(value);
//  final decrypted = aesEncypter.decrypt(stringToDecrypt, iv: _iv);
//
//  return decrypted;
  var decrypt = {"value": value, "secretkey": key, "iv": iv};
  var decryptedData = await Etiqacrypto.decryptHttpData(decrypt);
  return decryptedData;
}

String encryptHash256(String data) {
  var bytes = utf8.encode(data);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
