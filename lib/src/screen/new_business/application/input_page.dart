import 'dart:convert';

import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/occupation_search/occupation_search.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/row_container.dart';

import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  final dynamic inputList;
  const InputPage({Key? key, required this.inputList}) : super(key: key);
  @override
  InputPageState createState() => InputPageState();
}

class InputPageState extends State<InputPage> {
  dynamic widList;
  dynamic result;

  @override
  void initState() {
    super.initState();
    var occupation = getObjectByKey(widget.inputList, "occupationDisplay");
    if (occupation != null) {
      occupation["onTap"] = () async {
        int? age;
        var dob = getObjectByKey(widget.inputList, "dob");
        if (dob != null && dob["value"] != null && dob["value"] != "") {
          DateTime date = DateTime.fromMicrosecondsSinceEpoch(dob["value"]);
          age = getAge(date);
        }

        final tmpOcc = await Navigator.of(context)
            .push(createRoute(ChooseOccupation(age: age)));

        if (tmpOcc != null) {
          setState(() {
            occupation["value"] = tmpOcc.occupationName;
            if (occupation["required"]) {
              if (tmpOcc.remarks == '{"mandatory":"false"}') {
                widget.inputList["occupation"]["fields"]["companyname"]
                    ["required"] = false;
                widget.inputList["occupation"]["fields"]["monthlyincome"]
                    ["required"] = false;
              } else {
                widget.inputList["occupation"]["fields"]["companyname"]
                    ["required"] = true;
                widget.inputList["occupation"]["fields"]["monthlyincome"]
                    ["required"] = true;
              }
            }

            result = getInputedData(widget.inputList);
            result["occupation"] = json.encode(tmpOcc);
          });
        }
      };
    }

    var parttime = getObjectByKey(widget.inputList, "parttime");
    if (parttime != null) {
      parttime["onTap"] = () async {
        int? age;
        var dob = getObjectByKey(widget.inputList, "dob");
        if (dob != null && dob["value"] != null && dob["value"] != "") {
          DateTime date = DateTime.fromMicrosecondsSinceEpoch(dob["value"]);
          age = getAge(date);
        }

        final tmpOcc = await Navigator.of(context)
            .push(createRoute(ChooseOccupation(age: age)));

        if (tmpOcc != null) {
          setState(() {
            parttime["value"] = tmpOcc.occupationName;
            result = getInputedData(widget.inputList);
            result["occupation"] = json.encode(tmpOcc);
          });
        }
      };
    }

    var gender = getObjectByKey(widget.inputList, "gender");
    var salutation = getObjectByKey(widget.inputList, "salutation");
    if (gender != null && gender["value"] != "" && salutation != null) {
      salutation["options"] = getMasterlookup(
          type: "Salutation", remark: ["E", gender["value"][0].toUpperCase()]);
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void onAmlaChanged(data, [message]) {
    result = data;
    if (result["amlaPass"] == false) {
      showAlertDialog(
          context,
          getLocale("Oops, there seems to be an issue."),
          getLocale(
              "We are unable to proceed due to some issues with the applicant’s. Please change another applicant."));
    }
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
    if (originalData != null && originalData["amlaPass"] != null) {
      data["amlaPass"] = originalData["amlaPass"];
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
      if (data != null && data["identitytype"] == null) {
        break;
      }
      if (data != null &&
          originalData != null &&
          data[amlaParam[i]] != originalData[amlaParam[i]]) {
        data["amlaChecked"] = false;
        break;
      } else if (i == (amlaParam.length - 1) && originalData != null) {
        data["amlaChecked"] = originalData["amlaChecked"];
      }
    }
    startCheckAmla(data, checking, callback);
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, widget.inputList, (key) {
      var oriData = json.decode(json.encode(result));
      var occ = getObjectByKey(widget.inputList, "occupationDisplay");

      if (occ != null && occ["required"]) {
        if (result != null && result["occupation"] != null) {
          var occJson = json.decode(result["occupation"]);
          if (occJson["Remarks"] == '{"mandatory":"false"}') {
            widget.inputList["occupation"]["fields"]["companyname"]
                ["required"] = false;
            widget.inputList["occupation"]["fields"]["monthlyincome"]
                ["required"] = false;
          } else {
            widget.inputList["occupation"]["fields"]["companyname"]
                ["required"] = true;
            widget.inputList["occupation"]["fields"]["monthlyincome"]
                ["required"] = true;
          }
        }
      }
      var gender = getObjectByKey(widget.inputList, "gender");
      var salutation = getObjectByKey(widget.inputList, "salutation");
      if (gender != null && gender["value"] != "" && salutation != null) {
        salutation["options"] = getMasterlookup(
            type: "Salutation",
            remark: ["E", gender["value"][0].toUpperCase()]);
      }
      var tempResult = getInputedData(widget.inputList);
      extraParam(tempResult, context, oriData, "input", onAmlaChanged);
      setState(() {});
    });

    List<Widget> generateContent(widList, inputList) {
      List<Widget> inWidList = [];
      var textStyle = tFontW5();
      var count = 1;
      for (var key in inputList.keys) {
        if (inputList[key]["enabled"] != null && !inputList[key]["enabled"]) {
          continue;
        }
        if (inputList[key]["mainTitle"] != null &&
            !inputList[key]["mainTitle"]) {
          textStyle = t2FontW5().copyWith(color: cyanColor);
        }
        inWidList.add(Text(inputList[key]["title"], style: textStyle));
        analyticsSetCurrentScreen(
            inputList[key]["title"], inputList[key]["title"]);
        if (inputList[key]["subTitle"] != null) {
          Widget? label;
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

          inWidList.add(label!);
        }
        inWidList.add(SizedBox(height: gFontSize * 1.5));
        for (var wid in widList[key]) {
          inWidList.add(wid["widget"]);
        }
        inWidList.add(SizedBox(height: gFontSize * 3));

        if (widget.inputList.keys.length > count) {
          count++;
          inWidList.add(SizedBox(
              height: 10,
              child: OverflowBox(
                  maxWidth: screenWidth,
                  maxHeight: 10,
                  child: const Divider(height: 10, thickness: 5))));
          inWidList.add(SizedBox(height: gFontSize * 2));
        }
      }
      return inWidList;
    }

    Widget button() {
      var obj = [
        {
          "size": 100,
          "value": CustomButton(
              label: getLocale("Save"),
              onPressed: () {
                var oriData = json.decode(json.encode(result));

                result = getInputedData(widget.inputList);
                String? found;
                for (var key in result.keys) {
                  if (result[key] == null) {
                    found = key;
                    break;
                  }
                }
                if (found != null) {
                  String? label = "";
                  var obj = getObjectByKey(widget.inputList, found);
                  label =
                      obj != null && obj["label"] != null ? obj["label"] : "";
                  showSnackBarError(
                      "${getLocale("Please insert the required field")} ${label!}");
                  return;
                }

                extraParam(result, context, oriData, "input", onAmlaChanged);
                if (result["amlaPass"] == false) {
                  showAlertDialog(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      getLocale(
                          "We are unable to proceed due to some issues with the applicant’s. Please change another applicant."));
                } else {
                  Navigator.pop(context, result);
                }
              })
        }
      ];

      return RowContainer(
          arrayObj: obj,
          padding: const EdgeInsets.all(0),
          color: honeyColor,
          height: gFontSize * 3);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: gFontSize * 0.35,
              width: screenWidth,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [yellowColor, honeyColor]))),
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: gFontSize * 1.5, horizontal: gFontSize * 1.5),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.adaptive.arrow_back, size: gFontSize))),
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: gFontSize * 2,
                      right: gFontSize * 4,
                      left: gFontSize * 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...generateContent(widList, widget.inputList)
                      ])))
        ]),
        bottomNavigationBar: button());
  }
}
