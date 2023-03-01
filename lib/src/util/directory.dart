import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/function.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:flutter/services.dart' show rootBundle;

const String applicationFolder = "application";
const String imageFolder = "images";
const String filesFolder = "files";

Future<dynamic> getGlobalImageSavePath() async {
  try {
    var d = Directory(join(await (getSaveFilePath()), imageFolder));
    await createIfNotExist(d);
    return {"status": true, "path": d.path};
  } catch (e) {
    throw handleThrowError(e);
  }
}

Future<dynamic> getImageByte(List<String?> img) async {
  try {
    List<Uint8List?> imgByte = [];
    await getGlobalImageSavePath().then((status) async {
      if (status != null && status["path"] != null) {
        var path = status["path"];
        if (img.isNotEmpty) {
          for (var element in img) {
            await checkImage(element, path).then((status) {
              if (status != null && status["data"] != null) {
                imgByte.add(status["data"]);
              }
            }).catchError((err) {
              throw (err);
            });
          }
        }
      }
    });
    return imgByte;
  } catch (e) {
    throw handleThrowError(e);
  }
}

Future<dynamic> getCommonFilePath() async {
  try {
    var d = Directory(join(await (getSaveFilePath()), filesFolder));
    await createIfNotExist(d);
    return {"status": true, "path": d.path};
  } catch (e) {
    throw handleThrowError(e);
  }
}

Future<dynamic> createIfNotExist(directory) async {
  try {
    if (!directory.existsSync()) {
      directory = await directory.create(recursive: true);
    }
    return {"status": true};
  } catch (e) {
    throw handleThrowError(e);
  }
}

Future<dynamic> getSaveFilePath() async {
  try {
    if (Platform.isAndroid) {
      return (await getApplicationSupportDirectory()).path;
    } else if (Platform.isIOS) {
      return (await getLibraryDirectory()).path;
    } else {
      throw throwErrorFormat(false, AppErrorCode.osNotSupport);
    }
  } catch (e) {
    throw handleThrowError(e);
  }
}

//FOR TEMP DEBUG use mainly for android
dynamic copyDB() async {
  ByteData data = await rootBundle.load("assets/files/application.db");
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String path = join(appDocDir.path, "application.db");
  final fileSecureLink = File(path);
  if (!fileSecureLink.existsSync()) {
    await File(path).writeAsBytes(bytes);
  }
}
