import 'package:ease/src/setting/servicing_config.dart';

Future<List> setVPMSData({String? vpmsField, String? value}) async {
  final List data =
      await vpmsPlatform.invokeMethod('setInput', {vpmsField: value});
  return data;
}

Future<List> getAnyway({String? vpmsField}) async {
  final List data = await vpmsPlatform.invokeMethod('setAnyway', vpmsField);
  return data;
}

Future<String?> getVPMSVersion({String? fileName}) async {
  String? data = await vpmsPlatform
      .invokeMethod('getVPMSVersion', {"vpmsFileName": fileName});

  return data;
}
