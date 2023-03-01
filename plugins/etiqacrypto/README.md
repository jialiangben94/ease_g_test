# com_etiqa_flutter_crypto

A crypto library for eitqa flutter team to encrypt and decrypt data. This plugin will only support for local adding currently.

## Installation

1) Add `com_etiqa_flutter_crypto: path: /pathto/com_etiqa_flutter_crypto/` in pubspec.yaml dependencies section.

2) flutter pub get

3) Add the following import to dart code of your application

```dart
    import 'package:com_etiqa_flutter_crypto/etiqacrypto.dart';
```

## API

1) decryptHttpData

2) encryptStringAsBase64

## Sample Usage

```dart
    import 'package:com_etiqa_flutter_crypto/etiqacrypto.dart';

    var encrypt = {
        "value": "hello world",
        "secretkey": "123",
        "iv": "123"
      };

      var decrypt = {
          "value": await Etiqacrypto.encryptStringAsBase64(encrypt),
          "secretkey": "123",
          "iv": "123"
      };
      var data = await Etiqacrypto.decryptHttpData(decrypt);
      print(data);
```