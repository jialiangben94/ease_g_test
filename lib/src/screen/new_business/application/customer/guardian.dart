import 'dart:convert';

import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/customer/widget.dart';

import 'package:flutter/material.dart';

class Guardian extends StatefulWidget {
  final dynamic obj;
  final Function(dynamic obj) onChanged;

  const Guardian({Key? key, required this.onChanged, this.obj})
      : super(key: key);

  @override
  GuardianState createState() => GuardianState();
}

class GuardianState extends State<Guardian> {
  dynamic widList = [];
  dynamic inputList;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    var standardObject = getGlobalInputJsonFormat();
    inputList = {
      "guardian": {
        "title": getLocale("Parent/Legal Guardian Details"),
        "subTitle": {
          "label":
              "${getLocale("I hereby give my consent for a Life Insurance Policy to be issued on the life of my child/ward and that he/she is the")} ${getLocale("Policy Owner", entity: true)}. ${getLocale("I consent to the additional declaration to be given by my child/ward in any questionnaires relating to this application.")}",
          "color": Colors.red
        },
        "mainTitle": true,
        "fields": {
          "relationship": standardObject["relationshipChild"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "dob": standardObject["dob"],
          "gender": standardObject["gender"]
        }
      }
    };
    inputList["guardian"]["fields"]["identitytype"]["clientType"] = "11";

    inputList["guardian"]["fields"]["name"]["label"] =
        "Name of Parent/\nLegal Guardian";

    obj = widget.obj;

    generateDataToObjectValue(obj, inputList);
  }

  @override
  Widget build(BuildContext context) {
    var childRelationList = [];

    var gender = getObjectByKey(inputList, "gender");
    var relationshipList = getMasterlookup(type: "Relationship");
    relationshipList.forEach((option) {
      if (option["remark"] != null) {
        dynamic remark = jsonDecode(option["remark"]);
        if (remark["BuyFor"] == "Children") {
          if (gender != null && gender["value"] != "") {
            if (remark["gender"] == "E" ||
                remark["gender"] == gender["value"][0].toUpperCase()) {
              childRelationList.add(option);
            }
          } else {
            childRelationList.add(option);
          }
        }
      }
    });

    if (childRelationList.indexWhere((element) =>
            element["value"] ==
            inputList["guardian"]["fields"]["relationship"]["value"]) ==
        -1) {
      inputList["guardian"]["fields"]["relationship"]["value"] = "";
    }
    inputList["guardian"]["fields"]["relationship"]["options"] =
        childRelationList;

    widList = generateInputField(context, inputList, (key) {
      setState(() {
        var result = getInputedData(inputList);
        obj = result;
        widget.onChanged(obj);
      });
    });

    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2, left: gFontSize * 3, right: gFontSize),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: generateContent(widList, inputList)));
  }
}
