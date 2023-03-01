import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:flutter/material.dart';

List<Widget> generateContent(widList, inputList) {
  List<Widget> inWidList = [];
  var textStyle = t1FontW5();
  for (var key in inputList.keys) {
    if (inputList[key]["enabled"] != null && !inputList[key]["enabled"]) {
      continue;
    }
    if (inputList[key]["mainTitle"] != null && !inputList[key]["mainTitle"]) {
      textStyle = t2FontW5().copyWith(color: cyanColor);
    }
    inWidList.add(Text(inputList[key]["title"], style: textStyle));
    if (inputList[key]["subTitle"] != null) {
      late Widget label;
      if (inputList[key]["subTitle"] is String) {
        label = Padding(
            padding: EdgeInsets.only(right: gFontSize * 3),
            child: Text(inputList[key]["subTitle"],
                style: sFontWN().copyWith(color: greyTextColor)));
      } else if (inputList[key]["subTitle"] is Widget) {
        label = inputList[key]["subTitle"];
      } else if (inputList[key]["subTitle"] is Map) {
        label = Padding(
            padding: EdgeInsets.only(right: gFontSize * 3),
            child: Text(inputList[key]["subTitle"]["label"],
                style: sFontWN()
                    .copyWith(color: inputList[key]["subTitle"]["color"])));
      }

      inWidList.add(label);
    }
    inWidList.add(SizedBox(height: gFontSize * 1.5));
    for (var wid in widList[key]) {
      inWidList.add(wid["widget"]);
    }
    inWidList.add(SizedBox(height: gFontSize * 3));
  }
  return inWidList;
}

void extraParam(data, context, originalData, checking, callback) {
  if (data["dob"] != null) {
    var age = getAge(DateTime.fromMicrosecondsSinceEpoch(data["dob"]));
    data["age"] = age;
    data["isJuvenile"] = age < 16;
  }
  if (originalData != null && originalData["occupation"] != null) {
    data["occupation"] = originalData["occupation"];
  }
  if (originalData != null && originalData["parttimeOcc"] != null) {
    data["parttimeOcc"] = originalData["parttimeOcc"];
  }
  var amlaParam = [
    "nationality",
    "countryofbirth",
    "name",
    "identitytype",
    "nric",
    "oldic",
    "passport",
    "birthcert",
    "mypr",
    "policeic",
    "armyic",
    "otheridentity"
  ];
  for (var i = 0; i < amlaParam.length; i++) {
    if (data[amlaParam[i]] != originalData[amlaParam[i]]) {
      data["amlaChecked"] = false;
      break;
    } else if (i == (amlaParam.length - 1)) {
      data["amlaChecked"] = originalData["amlaChecked"];
    }
  }
  startCheckAmla(data, checking, callback);
}
