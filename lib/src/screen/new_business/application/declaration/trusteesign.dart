import 'dart:convert';

import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/declaration/widget.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

import '../../../../util/function.dart';

class TrusteeSign extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;

  const TrusteeSign({Key? key, this.obj, this.info, required this.onChanged})
      : super(key: key);
  @override
  TrusteeSignState createState() => TrusteeSignState();
}

class TrusteeSignState extends State<TrusteeSign> {
  dynamic inputList;
  late dynamic widList;
  late dynamic declaration;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    obj = widget.obj;

    declaration = """
${getLocale("Please read carefully before signing this application.")}

${getLocale("I/We the undersigned hereby accept the appointment as Trustee(s) and undertake to carry out all my/our duties as Trustee(s) in accordance with the trust deed if any, or according to the provision of the Trustee Act 1949 in relation to the said Policy.")}
    """;

    var info = widget.info;

    info ??= {};
    if (info["trusteesign"] == null) {
      info["trusteesign"] = {};
    }
    if (info["nomination"].isEmpty && info["nomination"]["trustee"] == null) {
      info["nomination"]["trustee"] = [];
    }

    var mapInfo = json.decode(json.encode(info));
    replaceAllMapping(mapInfo);

    inputList = {};

    for (var i = 0; i < info["nomination"]["trustee"].length; i++) {
      inputList[
          "Identity-${info["nomination"]["trustee"][i][info["nomination"]["trustee"][i]["identitytype"]]}"] = {
        "titleAsKey": true,
        "fields": {
          "remote": {
            "type": "switchRemote",
            "label": getLocale("Prefer to capture his/her signature remotely"),
            "value": false,
            "enabled": true,
            "required": true
          },
          "signature": {
            "type": "signature",
            "label": (mapInfo["nomination"]["trustee"][i]["name"] ?? ""),
            "headerLabel":
                "${getLocale("Trustee")} ${(i + 1).toString()} - ${(mapInfo["nomination"]["trustee"][i]["name"] ?? "")}",
            "value": "",
            "required": true
          },
          "identityFront": {
            "type": "camera",
            "label":
                (mapInfo["nomination"]["trustee"][i]["identitytype"] ?? "") +
                    " ${getLocale("Front")}",
            "value": "",
            "required": true
          },
          "identityBack": {
            "type": "camera",
            "label":
                (mapInfo["nomination"]["trustee"][i]["identitytype"] ?? "") +
                    " ${getLocale("Back")}",
            "value": "",
            "required": true
          }
        }
      };
    }

    generateDataToObjectValue(obj, inputList);

    if (obj != null && !obj.isEmpty) {
      for (var key in obj.keys) {
        if (inputList[key] != null &&
            inputList[key]["fields"] != null &&
            obj[key] is Map) {
          for (var key2 in obj[key].keys) {
            inputList[key]["fields"][key2]["value"] = obj[key][key2];
          }
        }
      }
    }
  }

  void checkInput() {
    for (var key in inputList.keys) {
      var remote = inputList[key]["fields"]["remote"];
      if (remote["value"]) {
        inputList[key]["fields"]["signature"]["required"] = false;
        inputList[key]["fields"]["identityFront"]["required"] = false;
        inputList[key]["fields"]["identityBack"]["required"] = false;
      } else {
        inputList[key]["fields"]["signature"]["required"] = true;
        inputList[key]["fields"]["identityFront"]["required"] = true;
        inputList[key]["fields"]["identityBack"]["required"] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      checkInput();
      var result = getInputedData(inputList);
      obj = result;
      widget.onChanged(obj);
      setState(() {});
    });

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Declaration for Trustee"), style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          Text(declaration, style: bFontWN()),
          SizedBox(height: gFontSize * 1.5),
          ...signatureContent(widList, inputList)
        ]));
  }
}
