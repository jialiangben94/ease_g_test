import 'dart:convert';

import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/declaration/widget.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class ConsentMinor extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;

  const ConsentMinor({Key? key, this.obj, this.info, required this.onChanged})
      : super(key: key);
  @override
  ConsentMinorState createState() => ConsentMinorState();
}

class ConsentMinorState extends State<ConsentMinor> {
  dynamic inputList;
  late dynamic widList;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    var info = json.decode(json.encode(widget.info));
    obj = widget.obj;

    info ??= {};

    var mapInfo = json.decode(json.encode(info["guardian"]));
    replaceAllMapping(mapInfo);

    inputList = {
      "agreeContent": {
        "fields": {
          "readAndAgree": {
            "type": "radiocheck",
            "label": getLocale("Agree"),
            "value": false,
            "required": true
          }
        }
      },
      "consentIdentity": {
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
            "label": (mapInfo["name"] ?? ""),
            "headerLabel": "Parent/Legal Guardian - ${(mapInfo["name"] ?? "")}",
            "value": "",
            "required": true
          },
          "identityFront": {
            "type": "camera",
            "label": (mapInfo["identitytype"] ?? "") + " Front",
            "value": "",
            "required": true
          },
          "identityBack": {
            "type": "camera",
            "label": (mapInfo["identitytype"] ?? "") + " Back",
            "value": "",
            "required": true
          }
        }
      }
    };

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
      if (key != "agreeContent") {
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
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      checkInput();
      var result = getInputedData(inputList);
      if (result["readAndAgree"] != null && !result["readAndAgree"]) {
        result["empty"] = null;
      } else {
        result.remove("empty");
      }
      if (obj is Map) {
        if (result["readAndAgree"] != null && result["readAndAgree"] is bool) {
          obj.remove("empty");
        }

        obj.addAll(result);
      } else {
        obj = result;
      }
      widget.onChanged(obj);
      setState(() {});
    });

    List<Widget> agreeContent() {
      List<Widget> inWidList = [];
      var t = """
${getLocale("I hereby give my consent for a Life Insurance Policy to be issued on the life of my child/ward and that he/she is the")} ${getLocale("Policy Owner", entity: true)}. ${getLocale("I consent to the additional declaration to be given by my child/ward in any questionnaires relating to this application.")}

${getLocale("I hereby agree that by selecting the button, I am signing this Proposal Form and any other related documents (‘Document’) electronically and that my electronic signature is the legal equivalent of my manual signature on these Documents. Further, by selecting the button, I hereby consent to be legally bound by the terms and conditions of these Documents")}

${getLocale("I hereby further agree and consent that the use if a key pad, mouse other device to select an item, button, icon or similar act/action, or to otherwise provide")} ${getLocale("Etiqa Life Insurance Berhad")} ${getLocale("via this Agency EPP STP platform, or in accessing or making any transaction regrading any agreement, acknowledgement, consent terms, disclosure or conditions constitutes my signature ('E-Signature'), acceptance and agreement as if actually signed by me in writing.")}

${getLocale("I also agree that no certification authority or other third party verification is necessary to validate my E-Signature and that the lack of such certification or third party verification will not in any way affect the enforceability of my E-Signature or any resulting contract between me and")} ${getLocale("Etiqa Life Insurance Berhad")}.
""";
      inWidList.add(Text(t, style: bFontWN()));
      inWidList.add(SizedBox(height: gFontSize * 0.7));

      inWidList.add(widList["agreeContent"][0]["widget"]);
      inWidList.add(SizedBox(height: gFontSize * 0.7));

      return inWidList;
    }

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Consent For Minor"), style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          ...agreeContent(),
          SizedBox(height: gFontSize * 1.1),
          const Divider(thickness: 1),
          SizedBox(height: gFontSize * 1.5),
          Text(getLocale("Please attach your NRIC and sign below"),
              style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          ...signatureContent(widList, inputList)
        ]));
  }
}
