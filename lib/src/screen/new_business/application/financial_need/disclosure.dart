import 'dart:convert';

import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/input_page.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/choice_check.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/currency_textfield.dart';
import 'package:ease/src/widgets/custom_cupertino_switch.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:ease/src/util/function.dart';

import 'package:flutter/material.dart';

class Disclosure extends StatefulWidget {
  final VoidCallback? callback;

  const Disclosure({Key? key, this.callback}) : super(key: key);

  @override
  DisclosureState createState() => DisclosureState();
}

class DisclosureState extends State<Disclosure> {
  late dynamic widList;
  dynamic inputList;
  dynamic inputList2;

  dynamic optionFields(String type, String type2) {
    return {
      "year": {
        "type": "number",
        "label":
            "${getLocale("In how many years from now would you want the plan to mature in order to receive your")} $type?",
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "maxLength": 2,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1
      },
      "amount": {
        "type": "currency",
        "label":
            "${getLocale("How much money do you target to allocate every month for your")} $type2?",
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "prefix": "RM "
      },
      "remarks": {
        "type": "text",
        "label": objMapping["discussionremarks"],
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "sentence": true
      }
    };
  }

  @override
  void initState() {
    var standardObject = getGlobalInputJsonFormat();

    if (ApplicationFormData.data != null &&
        ApplicationFormData.data["lifeInsured"] != null &&
        ApplicationFormData.data["lifeInsured"]["age"] != null) {
      standardObject["agenextbirthdate"]["value"] = (int.parse(
                  ApplicationFormData.data["lifeInsured"]["age"].toString()) +
              1)
          .toString();
    }

    super.initState();

    var protectionOptionField = {
      "year": {
        "type": "option2",
        "options": [
          {
            "label": "<= 30 ${getLocale("years")}",
            "active": true,
            "value": "<= 30 years"
          },
          {
            "label": "> 30 ${getLocale("years")}",
            "active": true,
            "value": "> 30 years"
          }
        ],
        "label":
            getLocale("For how many years would you want the protection for?"),
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1
      },
      "amount": {
        "type": "currency",
        "label": getLocale(
            "How much money do you target to allocate every month for your protection plan?"),
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "prefix": "RM "
      },
      "needAdditionalCoverage": {
        "type": "text",
        "label": objMapping["discussioncoverage"],
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "sentence": true
      },
      "remarks": {
        "type": "text",
        "label": objMapping["discussionremarks"],
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "sentence": true
      }
    };

    var medOptionField = {
      "charge": {
        "type": "text",
        "label": objMapping["discussioncharge"],
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "sentence": true
      },
      "remarks": {
        "type": "text",
        "label": objMapping["discussionremarks"],
        "labelColor": greyTextColor.value.toRadixString(16),
        "value": "",
        "required": true,
        "column": true,
        "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0},
        "columnHeight": 1,
        "sentence": true
      }
    };

    inputList = {
      "coverage": {
        "titleAsKey": true,
        "fields": {
          "saving": {
            "label": getLocale("Savings and Investment Plans"),
            "enabled": false,
            "value": [],
            "required": true,
            "inputList": {
              "coverage": {
                "title": objMapping["existingsaving"],
                "fields": {
                  "planpolicyowner": standardObject["planpolicyowner"],
                  "plancompany": standardObject["plancompany"],
                  "planname": standardObject["planname"],
                  "plantype": standardObject["plantype"],
                  "planpremiumamount": standardObject["planpremiumamount"],
                  "planpaymentmode": standardObject["planpaymentmode"],
                  "planstartdate": standardObject["planstartdate"],
                  "planmaturitydate": standardObject["planmaturitydate"],
                  "planamountmaturity": standardObject["planamountmaturity"],
                  "additionalbenefit": standardObject["additionalbenefit"]
                }
              }
            }
          },
          "retirement": {
            "label": getLocale("Retirement Plans"),
            "enabled": false,
            "value": [],
            "required": true,
            "inputList": {
              "coverage": {
                "title": objMapping["existingretirement"],
                "fields": {
                  "plancompany": standardObject["plancompany"],
                  "planname": standardObject["planname"],
                  "plantype": standardObject["plantype"],
                  "planpremiumamount": standardObject["planpremiumamount"],
                  "planpaymentmode": standardObject["planpaymentmode"],
                  "planstartdate": standardObject["planstartdate"],
                  "planmaturitydate": standardObject["planmaturitydate"],
                  "planlumpsummaturity": standardObject["planlumpsummaturity"],
                  "planincomematurity": standardObject["planincomematurity"],
                  "additionalbenefit": standardObject["additionalbenefit"]
                }
              }
            }
          },
          "childreneducation": {
            "label": getLocale("Children's Education Plans"),
            "enabled": false,
            "value": [],
            "required": true,
            "inputList": {
              "coverage": {
                "title": objMapping["existingchildreneducation"],
                "fields": {
                  "planpolicyowner": standardObject["planpolicyowner"],
                  "plancompany": standardObject["plancompany"],
                  "planname": standardObject["planname"],
                  "plantype": standardObject["plantype"],
                  "planpremiumamount": standardObject["planpremiumamount"],
                  "planpaymentmode": standardObject["planpaymentmode"],
                  "planstartdate": standardObject["planstartdate"],
                  "planmaturitydate": standardObject["planmaturitydate"],
                  "planfeematurity": standardObject["planfeematurity"],
                  "additionalbenefit": standardObject["additionalbenefit"]
                }
              }
            }
          },
          "protection": {
            "label": getLocale("Protection Plans (Personal/Spouse/Children)"),
            "enabled": false,
            "value": [],
            "required": true,
            "inputList": {
              "coverage": {
                "title": objMapping["existingprotection"],
                "fields": {
                  "planpolicyowner": standardObject["planpolicyowner"],
                  "planlifeinsured": standardObject["planlifeinsured"],
                  "plancompany": standardObject["plancompany"],
                  "planname": standardObject["planname"],
                  "plantype": standardObject["plantype"],
                  "planpremiumcontribution":
                      standardObject["planpremiumcontribution"],
                  "planpaymentmode": standardObject["planpaymentmode"],
                  "planmaturitydate": standardObject["planmaturitydate"],
                  "plandeathbenefit": standardObject["plandeathbenefit"],
                  "plandisabilitybenefit":
                      standardObject["plandisabilitybenefit"],
                  "plancibenefit": standardObject["plancibenefit"],
                  "additionalbenefit": standardObject["additionalbenefit"]
                }
              }
            }
          },
          "medical": {
            "label": getLocale("Medical Plans"),
            "enabled": false,
            "value": [],
            "inputList": {
              "coverage": {
                "title": objMapping["existingmedical"],
                "fields": {
                  "planpolicyowner": standardObject["planpolicyowner"],
                  "planlifeinsured": standardObject["planlifeinsured"],
                  "plancompany": standardObject["plancompany"],
                  "planname": standardObject["planname"],
                  "plantype": standardObject["plantype"],
                  "planstartdate": standardObject["planstartdate"],
                  "planmaturitydate": standardObject["planmaturitydate"],
                  "planroomboard": standardObject["planroomboard"],
                  "planannuallimit": standardObject["planannuallimit"],
                  "planlifelimit": standardObject["planlifelimit"],
                  "plancoinsurance": standardObject["plancoinsurance"],
                  "additionalbenefit": standardObject["additionalbenefit"]
                }
              }
            }
          }
        }
      },
      "discussion": {
        "titleAsKey": true,
        "fields": {
          "saving": {
            "label": getLocale("Savings and Investment Plan"),
            "enabled": false,
            "value": {},
            "option_fields":
                optionFields("saving/investment", "saving and investment plan"),
            "required": true
          },
          "retirement": {
            "label": getLocale("Retirement Plan"),
            "enabled": false,
            "value": {},
            "option_fields": optionFields("retirement fund", "retirement plan"),
            "required": true
          },
          "childreneducation": {
            "label": getLocale("Children's Education Plan"),
            "enabled": false,
            "value": {},
            "option_fields":
                optionFields("education fund", "child's education plan"),
            "required": true
          },
          "protection": {
            "label": getLocale("Protection Plan (Personal/Spouse/Children)"),
            "enabled": false,
            "value": {},
            "option_fields": json.decode(json.encode(protectionOptionField)),
            "required": true
          },
          "medical": {
            "label": getLocale("Medical Plan"),
            "enabled": false,
            "value": {},
            "option_fields": json.decode(json.encode(medOptionField)),
            "required": true
          }
        }
      },
      "currentOption": {
        "label":
            getLocale("It looks like there are some undisclosed information"),
        "value": "Option 3"
      },
      "notDisclose": {
        "fields": {
          "reasonNotDisclose": {
            "maxLines": 5,
            "type": "text",
            "label": getLocale("Is there a reason why? State it below."),
            "labelColor": Colors.red.value.toRadixString(16),
            "enabled": true,
            "value": "",
            "required": true,
            "column": true,
            "sentence": true,
            "size": {"textWidth": 20, "fieldWidth": 80, "emptyWidth": 0}
          }
        }
      }
    };

    inputList["coverage"]["fields"]["retirement"]["inputList"]["coverage"]
        ["fields"]["additionalbenefit"]["required"] = true;

    inputList["coverage"]["fields"]["childreneducation"]["inputList"]
        ["coverage"]["fields"]["plantype"]["required"] = false;

    inputList["coverage"]["fields"]["protection"]["inputList"]["coverage"]
        ["fields"]["plantype"]["required"] = false;
    inputList["coverage"]["fields"]["protection"]["inputList"]["coverage"]
        ["fields"]["plandeathbenefit"]["required"] = false;
    inputList["coverage"]["fields"]["protection"]["inputList"]["coverage"]
        ["fields"]["plandisabilitybenefit"]["required"] = false;
    inputList["coverage"]["fields"]["protection"]["inputList"]["coverage"]
        ["fields"]["plancibenefit"]["required"] = false;
    inputList["coverage"]["fields"]["protection"]["inputList"]["coverage"]
        ["fields"]["additionalbenefit"]["required"] = false;

    inputList["coverage"]["fields"]["medical"]["inputList"]["coverage"]
        ["fields"]["plantype"]["required"] = false;

    generateDataToObjectValue(
        ApplicationFormData.data["disclosure"], inputList);
    checkCurrentOption();
    generateSwitchField();
  }

  void checkOptionLabel() {
    if (inputList["currentOption"]["value"] == "Option 1") {
      inputList["currentOption"]["label"] = getLocale(
          "Based on the information above, you have disclosed all of the information");
    } else if (inputList["currentOption"]["value"] == "Option 2") {
      inputList["currentOption"]["label"] = getLocale(
          "Based on the information above, you have partially disclosed your information");
    } else {
      inputList["currentOption"]["label"] = getLocale(
          "Oops! It looks like you did not disclose any of your information.");
    }
  }

  void checkCurrentOption() {
    var obj = ApplicationFormData.data["disclosure"];
    if (obj != null) {
      if ((obj["coverage"] != null && obj["coverage"].keys.length > 0) ||
          (obj["discussion"] != null && obj["discussion"].keys.length > 0)) {
        inputList["currentOption"]["value"] = "Option 2";
        inputList["notDisclose"]["fields"]["reasonNotDisclose"]["enabled"] =
            false;
      }
      if (obj["discussion"] != null && obj["discussion"].keys.length > 1) {
        inputList["currentOption"]["value"] = "Option 1";
        inputList["notDisclose"]["fields"]["reasonNotDisclose"]["enabled"] =
            false;
      }
    }
    checkOptionLabel();
  }

  void checkCurrentOptionBySwitch() {
    var obj = inputList["coverage"]["fields"];
    var count = 0;
    for (var key in obj.keys) {
      if (obj[key]["enabled"]) {
        count++;
      }
    }
    var obj2 = inputList["discussion"]["fields"];

    var count2 = 0;
    for (var key in obj2.keys) {
      if (obj2[key]["enabled"]) {
        count2++;
      }
    }
    if (count2 > 1) {
      inputList["currentOption"]["value"] = "Option 1";
      inputList["notDisclose"]["fields"]["reasonNotDisclose"]["enabled"] =
          false;
    } else if (count > 0 || count2 > 0) {
      inputList["currentOption"]["value"] = "Option 2";
      inputList["notDisclose"]["fields"]["reasonNotDisclose"]["enabled"] =
          false;
    } else {
      inputList["currentOption"]["value"] = "Option 3";
      inputList["notDisclose"]["fields"]["reasonNotDisclose"]["enabled"] = true;
    }
    checkOptionLabel();
  }

  Widget rowCoverage(String title, desc) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 3,
              child:
                  Text(title, style: sFontWN().copyWith(color: greyTextColor))),
          Expanded(
              flex: 2,
              child:
                  Text(desc, style: sFontWB(), overflow: TextOverflow.ellipsis))
        ]));
  }

  Widget generateHtml(obj) {
    List<Widget> planDetails = [];
    var string = "";
    var standardObject = getGlobalInputJsonFormat();

    for (var key in obj.keys) {
      if (key == "planname" ||
          key == "plancompany" ||
          key == "agenextbirthdate" ||
          key == "additionalbenefit" ||
          key == "plancoinsurance") continue;
      var filtered = standardObject[key]["label"];

      String? value = "";
      if (standardObject[key]["prefix"] != null) {
        value = standardObject[key]["prefix"] + obj[key];
      } else if (key == "planstartdate" || key == "planmaturitydate") {
        value = getStandardDateFormat(timestamp: obj[key]);
      } else if (standardObject[key]["type"].indexOf("option") > -1) {
        int? index = standardObject[key]["options"]
            .indexWhere((option) => option["value"] == obj[key]);
        value = standardObject[key]["options"][index]["label"];
      } else {
        value = obj[key];
      }
      string =
          "$string<tr><td>$filtered</td><td><div>${value!}</div></td></tr>";

      planDetails.add(rowCoverage(filtered, value));
    }

    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(obj['plancompany'],
                style: sFontWN().copyWith(color: greyTextColor)),
            Text(obj['planname'], style: t1FontWB()),
            Column(children: planDetails)
          ])),
    );
  }

  dynamic onEditTap(obj, key2) async {
    for (var key in obj.keys) {
      inputList["coverage"]["fields"][key2]["inputList"]["coverage"]["fields"]
          [key]["value"] = obj[key];
    }
    var results = await Navigator.of(context).push(createRoute(InputPage(
        inputList: inputList["coverage"]["fields"][key2]["inputList"])));
    return results;
  }

  void onDeleteTap(obj, index, key) async {
    var result = await showConfirmDialog(context, "Delete",
        "${getLocale("Are you sure you want to delete")} ${obj["value"][index]["planname"]}?");

    if (result != null && result) {
      setState(() {
        obj["value"].removeAt(index);
        ApplicationFormData.data["disclosure"]["coverage"][key] = obj["value"];
        generateSwitchField();
        widget.callback!();
      });
      saveData();
    }
  }

  dynamic generateDelete(obj, index, key) {
    return InkWell(
        onTap: () {
          onDeleteTap(obj, index, key);
        },
        child: Icon(Icons.close, size: gFontSize * 1.4));
  }

  dynamic generateList(obj, key) {
    if (obj["value"] != null && obj["value"] != "" && obj["value"].length > 0) {
      var list = [];

      for (var i = 0; i < obj["value"].length; i++) {
        list.add(Padding(
            padding: EdgeInsets.only(left: gFontSize * 0.6),
            child: InkWell(
                onTap: () async {
                  var editedResult = await onEditTap(obj["value"][i], key);
                  if (editedResult != null) {
                    setState(() {
                      obj["value"][i] = editedResult;

                      var result = getInputedData(inputList);
                      ApplicationFormData.data["disclosure"] = result;
                      generateSwitchField();
                    });
                    saveData();
                  }
                },
                child: Container(
                    width: gFontSize * 22,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(gFontSize * 0.2)),
                        border: Border.all(color: Colors.grey[400]!)),
                    child: Container(
                        padding: EdgeInsets.all(gFontSize * 0.6),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: Alignment.topRight,
                                  child: generateDelete(obj, i, key)),
                              Flexible(child: generateHtml(obj["value"][i]))
                            ]))))));
      }
      return list.reversed.toList();
    } else {
      return [Container(width: 0)];
    }
  }

  dynamic generateSwitchField() {
    widList = {};
    for (var key in inputList.keys) {
      if (key == "currentOption") continue;
      if (key != "notDisclose") {
        widList[key] = generateEachSwitchField(inputList[key]["fields"], key);
      }
    }
  }

  void onAddTap(obj, key) async {
    if (ApplicationFormData.data != null &&
        ApplicationFormData.data["lifeInsured"] != null &&
        ApplicationFormData.data["lifeInsured"]["age"] != null) {
      if (obj["inputList"]["coverage"]["fields"]["agenextbirthdate"] != null) {
        obj["inputList"]["coverage"]["fields"]["agenextbirthdate"]
            ["value"] = (int.parse(
                    ApplicationFormData.data["lifeInsured"]["age"].toString()) +
                1)
            .toString();
      }
    }
    for (var key in obj["inputList"]["coverage"]["fields"].keys) {
      if (key == "agenextbirthdate") continue;
      if (obj["inputList"]["coverage"]["fields"][key]["type"] != null &&
          obj["inputList"]["coverage"]["fields"][key]["type"]
                  .indexOf("option") >
              -1) continue;
      obj["inputList"]["coverage"]["fields"][key]["value"] = "";
    }

    var results = await Navigator.of(context)
        .push(createRoute(InputPage(inputList: obj["inputList"])));

    if (results != null) {
      obj["value"].add(results);

      setState(() {
        var result = getInputedData(inputList);
        ApplicationFormData.data["disclosure"] = result;
        generateSwitchField();
        widget.callback!();
      });
      saveData();
    }
  }

  dynamic generateCoverage(obj, key) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () async {
                    onAddTap(obj, key);
                  },
                  child: Container(
                      constraints: BoxConstraints(
                          minHeight: gFontSize * 2.5,
                          maxHeight: double.infinity),
                      padding: EdgeInsets.all(gFontSize),
                      alignment: Alignment.center,
                      color: const Color.fromRGBO(227, 244, 242, 1),
                      child: Text("+ ${getLocale("Add coverage")}",
                          style: bFontW5().copyWith(color: cyanColor)))),
              ...generateList(obj, key)
            ],
          ),
        ),
      ),
    );
  }

  dynamic generateText(obj, key2) {
    List<Widget> inWidList = [];
    for (var key in obj["option_fields"].keys) {
      if (obj["option_fields"][key]["type"] == "text" ||
          obj["option_fields"][key]["type"] == "number") {
        inWidList.add(EaseAppTextField(
            obj: obj["option_fields"][key],
            onChanged: (value) {
              obj["option_fields"][key]["value"] = value;
            },
            callback: (_) {
              setState(() {
                var result = getInputedData(inputList);
                ApplicationFormData.data["disclosure"] = result;
                widget.callback!();
              });
              saveData();
            }));
      } else if (obj["option_fields"][key]["type"] == "currency") {
        inWidList.add(CurrencyTextField(
            obj: obj["option_fields"][key],
            onChanged: (val) {
              obj["option_fields"][key]["value"] = val;
              setState(() {
                var result = getInputedData(inputList);
                ApplicationFormData.data["disclosure"] = result;
                widget.callback!();
              });
              saveData();
            }));
      } else if (obj["option_fields"][key]["type"] == "option2") {
        inWidList.add(ChoiceCheckContainer(
            obj: obj["option_fields"][key],
            textColorChange: true,
            fontWeight: FontWeight.w500,
            fontSize: gFontSize * 0.85,
            optionPadding: EdgeInsets.all(gFontSize * 0.1),
            onChanged: (value) {
              obj["option_fields"][key]["value"] = value;
              setState(() {
                var result = getInputedData(inputList);
                ApplicationFormData.data["disclosure"] = result;
                widget.callback!();
              });
              saveData();
            }));
      }
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [...inWidList]);
  }

  dynamic generateEachSwitchField(obj, key2) {
    var inWidList = [];
    for (var key in obj.keys) {
      var height = 0.0;
      if (key2 == "coverage") {
        height = screenHeight * 0.45;
        if (key == "protection") height = screenHeight * 0.48;
        if (key == "medical") height = screenHeight * 0.45;
        if (obj[key]["value"] != null && !obj[key]["value"].isEmpty) {
          obj[key]["enabled"] = true;
        } else if (ApplicationFormData.data["disclosure"] != null &&
            ApplicationFormData.data["disclosure"]["coverage"] != null &&
            ApplicationFormData.data["disclosure"]["coverage"][key] != null) {
          obj[key]["enabled"] = true;
        }
      } else {
        height = screenHeight * 0.46;
        if (key2 == "discussion") {
          if (key == "protection") {
            height = screenHeight * 0.76;
          } else if (key == "medical") {
            height = screenHeight * 0.40;
          } else {
            height = screenHeight * 0.62;
          }
        }
        if (ApplicationFormData.data["disclosure"] != null &&
            ApplicationFormData.data["disclosure"][key2] != null &&
            ApplicationFormData.data["disclosure"][key2][key] != null) {
          obj[key]["enabled"] = true;
        }
      }
      inWidList.add(Container(
          padding: EdgeInsets.only(
              top: gFontSize * 0.75,
              bottom: gFontSize * 0.75,
              right: gFontSize * 0.5),
          width: double.infinity,
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1)))),
          child: Column(children: [
            Row(children: [
              Expanded(
                  flex: 82, child: Text(obj[key]["label"], style: bFontWN())),
              Expanded(
                  flex: 15,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                                obj[key]["enabled"]
                                    ? getLocale("Yes")
                                    : getLocale("No"),
                                style: bFontWN())),
                        CustomCupertinoSwitch(
                            value: obj[key]["enabled"],
                            activeColor: cyanColor,
                            bgColor: lightGreyColor2,
                            bgActiveColor: lightCyanColor,
                            onChanged: (bool value) {
                              setState(() {
                                obj[key]["enabled"] = value;
                                if (value == false && key2 == "coverage") {
                                  obj[key]["value"] = [];
                                } else if (value == false &&
                                    obj[key]["option_fields"] != null) {
                                  for (var i
                                      in obj[key]["option_fields"].keys) {
                                    obj[key]["option_fields"][i]["value"] = "";
                                  }
                                }

                                checkCurrentOptionBySwitch();
                                var result = getInputedData(inputList);
                                ApplicationFormData.data["disclosure"] = result;
                                generateSwitchField();
                                widget.callback!();
                              });
                              saveData();
                            })
                      ]))
            ]),
            Container(
                padding: const EdgeInsets.only(top: 10),
                constraints: BoxConstraints(
                    maxHeight: !obj[key]["enabled"]
                        ? 0.0
                        : (key2 == "coverage" ? height : double.infinity)),
                child: key2 == "coverage"
                    ? generateCoverage(obj[key], key)
                    : generateText(obj[key], key))
          ])));
    }
    return inWidList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(
              top: gFontSize * 2,
              left: gFontSize * 3,
              right: gFontSize * 3,
              bottom: gFontSize * 2.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Existing Coverage"), style: t1FontW5()),
            Text(
                getLocale(
                    "Does your client have any of the coverage below? Tap and fill in the details if they do."),
                style: sFontWN().copyWith(color: greyTextColor)),
            SizedBox(height: gFontSize * 1.5),
            for (var wid in widList["coverage"]) wid,
            const Divider(thickness: 1),
            SizedBox(height: screenHeight * 0.025)
          ])),
      const Divider(thickness: 5),
      Container(
          padding: EdgeInsets.only(
              top: gFontSize * 2,
              left: gFontSize * 3,
              right: gFontSize * 2.5,
              bottom: gFontSize * 2.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Let's talk about your future plans"),
                style: t1FontW5()),
            Text(
                getLocale(
                    "Does your client have any of the future plan below? Tap and fill in the details if they do."),
                style: sFontWN().copyWith(color: greyTextColor)),
            SizedBox(height: gFontSize * 1.5),
            for (var wid in widList["discussion"]) wid,
            const Divider(thickness: 1),
            SizedBox(height: screenHeight * 0.05),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(gFontSize * 1),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(gFontSize * 0.5),
                    color: inputList["currentOption"]["value"] == "Option 3"
                        ? const Color.fromRGBO(224, 100, 54, 1)
                        : const Color.fromRGBO(50, 117, 130, 1)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inputList["currentOption"]["label"],
                          style: t2FontWN().copyWith(color: Colors.white)),
                      Text(inputList["currentOption"]["value"],
                          style: t1FontWB().copyWith(color: Colors.white))
                    ])),
            SizedBox(height: screenHeight * 0.025),
            EaseAppTextField(
                obj: inputList["notDisclose"]["fields"]["reasonNotDisclose"],
                onChanged: (value) {
                  setState(() {
                    inputList["notDisclose"]["fields"]["reasonNotDisclose"]
                        ["value"] = value;
                    if (value.isEmpty || value.length < 50) {
                      inputList["notDisclose"]["fields"]["reasonNotDisclose"]
                              ["error"] =
                          getLocale("Please enter at least 50 characters");
                    } else {
                      inputList["notDisclose"]["fields"]["reasonNotDisclose"]
                          .remove("error");
                    }
                    var result = getInputedData(inputList);
                    ApplicationFormData.data["disclosure"] = result;
                    widget.callback!();
                  });
                  saveData();
                })
          ]))
    ]);
  }
}
