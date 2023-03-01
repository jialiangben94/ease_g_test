import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';

class Intermediary extends StatefulWidget {
  final VoidCallback callback;

  const Intermediary({Key? key, required this.callback}) : super(key: key);

  @override
  IntermediaryState createState() => IntermediaryState();
}

class IntermediaryState extends State<Intermediary> {
  late dynamic widList;
  dynamic obj;
  Map<String, dynamic> inputList = {
    "paragraph": {
      "type": "paragraph",
      "style": bFontWN(),
      "text":
          "${getLocale("I am an insurance intermediary who represent")} ${getLocale("ETIQA LIFE INSURANCE BERHAD (ELIB)", entity: true)} ${getLocale("and can advise you on:")}"
    }
  };

  @override
  void initState() {
    super.initState();
    obj = ApplicationFormData.data["intermediary"];

    List<dynamic> disclosure = getMasterlookup(type: "LIADisclosure");
    for (var option in disclosure) {
      if (option["value"] == "99") {
        inputList.putIfAbsent(
            option["value"],
            () => {
                  "type": "radiocheck",
                  "bgColor": Colors.white,
                  "label": option["label"],
                  "value": false,
                  "required": true,
                  "option_fields": {
                    "othersdesc": {
                      "type": "text",
                      "label": "",
                      "value": "",
                      "placeholder": "Please specify",
                      "required": true,
                      "size": {
                        "textWidth": 0,
                        "fieldWidth": 80,
                        "emptyWidth": 10
                      }
                    }
                  }
                });
      } else {
        inputList.putIfAbsent(
            option["value"],
            () => {
                  "type": "radiocheck",
                  "bgColor": Colors.white,
                  "label": option["label"],
                  "value": false,
                  "required": true
                });
      }
    }
    inputList.putIfAbsent(
        "paragraph2",
        () => {
              "type": "paragraph",
              "style": bFontWN(),
              "text":
                  "${getLocale("I received renumeration from")} (${getLocale("ELIB", entity: true)}) ${getLocale("for providing advice upon selling of the insurance products")}"
            });

    generateDataToObjectValue(obj, inputList);
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      setState(() {
        var result = getInputedData(inputList);
        if (!result["99"]) result.remove("othersdesc");
        bool allFalse = !result["1"] &&
            !result["2"] &&
            !result["3"] &&
            !result["4"] &&
            !result["99"];

        if (allFalse) {
          result.putIfAbsent("empty", () => null);
        }

        obj = result;
        ApplicationFormData.data["intermediary"] = obj;
        widget.callback();
      });
    });

    return Container(
        height: screenHeight * 0.91,
        padding: EdgeInsets.symmetric(horizontal: gFontSize * 3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: gFontSize * 2),
          Text(getLocale("Disclosure of Intermediary's Status"),
              style: t1FontW5()),
          SizedBox(height: gFontSize),
          for (var wid in widList) wid["widget"]
        ]));
  }
}
