import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/util/directory.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/widgets/custom_row_table.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/gestures.dart';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

const detailsLabelWidth = 40;
const detailsValueWidth = 60;
final datetimeformat = DateFormat('yyyy-MM-dd HH:mm:ss');
final dateformat = DateFormat('dd MMM yyyy');
const naText = "-";

Widget personalDetails(data, {bool? isSummary}) {
  dynamic obj = {
    "size": {"labelWidth": detailsLabelWidth, "valueWidth": detailsValueWidth},
    "naText": naText
  };
  if (data["relationship"] != null) {
    String? relationship;
    if (isNumeric(data["relationship"])) {
      var relation = lookupRelationship.keys
          .firstWhere((k) => lookupRelationship[k] == data["relationship"]);
      relationship = relation;
    }
    obj.addAll({
      "relationship": {
        "label":
            "${getLocale("Relationship with")} ${getLocale("Policy Owner", entity: true)}",
        "value": objMapping[relationship]
      }
    });
  }
  if (data["relationshipSpouse"] != null) {
    String? relationship;
    if (isNumeric(data["relationshipSpouse"])) {
      var relation = lookupRelationship.keys.firstWhere(
          (k) => lookupRelationship[k] == data["relationshipSpouse"]);
      relationship = relation;
    }
    obj.addAll({
      "relationship": {
        "label":
            "${getLocale("Relationship with")} ${getLocale("Life Insured", entity: true)}",
        "value": objMapping[relationship]
      }
    });
  }
  if (data["relationshipChild"] != null) {
    String? relationship;
    if (isNumeric(data["relationshipChild"])) {
      var relation = lookupRelationship.keys.firstWhere(
          (k) => lookupRelationship[k] == data["relationshipChild"]);
      relationship = relation;
    }
    obj.addAll({
      "relationship": {
        "label":
            "${getLocale("Relationship with")} ${getLocale("Life Insured", entity: true)}",
        "value": objMapping[relationship]
      }
    });
  }
  if (data["age"] == null && data["dob"] != null) {
    data["age"] = getAge(DateTime.fromMicrosecondsSinceEpoch(data["dob"]));
  }

  obj.addAll({
    "sal": {
      "label": getLocale("Salutation"),
      "value": getMasterlookup(
          type: "Salutation", value: data["salutation"])["label"]
    },
    "name": {"label": getLocale("Name"), "value": data["name"]},
    "cam": {"label": getLocale("Campaign"), "value": getLocale("Default")},
    "identitytype": {
      "label": objMapping[data["identitytype"]],
      "value": data[data["identitytype"]]
    },
    "dob": {
      "label": getLocale("Date of Birth"),
      "value": isSummary != null && isSummary
          ? DateFormat('dd MMM yyyy')
              .format(DateTime.fromMicrosecondsSinceEpoch(data["dob"]))
          : dateformat.format(DateTime.fromMicrosecondsSinceEpoch(data["dob"]))
    },
    "age": {"label": getLocale("ANB"), "value": data["age"] + 1},
    "gender": {
      "label": getLocale("Gender"),
      "value": getLocale(data["gender"])
    },
    "nationality": {
      "label": getLocale("Nationality"),
      "value": getMasterlookup(
          type: "Nationality", value: data["nationality"])["label"]
    },
    "countryofbirth": {
      "label": getLocale("Country of Birth"),
      "value": data["countryofbirth"] != null
          ? getMasterlookup(
              type: "Country", value: data["countryofbirth"])["label"]
          : null
    },
    "race": {
      "label": getLocale("Race"),
      "value": getMasterlookup(type: "Race", value: data["race"])["label"]
    },
    "religion": {
      "label": getLocale("Religion"),
      "value": data["muslim"] != null
          ? getMasterlookup(
              type: "Religion",
              value: data["muslim"] == true ? "I" : "O")["label"]
          : null
    },
    "maritalstatus": {
      "label": getLocale("Marital Status"),
      "value": data["maritalstatus"] != null
          ? getMasterlookup(
              type: "MaritalSt", value: data["maritalstatus"])["label"]
          : null
    },
    "preferredlanguage": {
      "label": getLocale("Preferred Language"),
      "value": getMasterlookup(
          type: "Language", value: data["preferlanguage"])["label"]
    },
    "smoker": {
      "label": getLocale("Smoker"),
      "value": data["smoking"] != null
          ? data["smoking"] == true
              ? getLocale("Yes")
              : getLocale("No")
          : null
    },
    "numberofchildren": {
      "label": getLocale("No. Of Children"),
      "value": data["numberofchildren"]
    }
  });

  dynamic obj2 = {};
  for (var key in obj.keys) {
    if (key == "size" || key == "naText") {
      obj2[key] = obj[key];
    } else if (obj[key]["value"] != null &&
        obj[key]["value"] is String &&
        obj[key]["value"].isNotEmpty) {
      obj2[key] = obj[key];
    }
  }
  return CustomColumnTable(arrayObj: [obj2], valueFontStyle: bFontW5());
}

Widget contactDetails(data) {
  var extraAddress = {
    "ismailingaddress": {
      "label": getLocale("Mailing Address (Y/N)"),
      "value": data["mailing"] != null
          ? data["mailing"] == true
              ? getLocale("Yes")
              : getLocale("No")
          : null
    }
  };
  if (data["mailing"] == false && data["mailingaddress"] != null) {
    extraAddress["mailingaddress"] = {
      "label": getLocale("Mailing Address"),
      "value": data["mailingaddress"] + (data["mailingaddress1"] ?? "")
    };
    extraAddress["mailingpostcode"] = {
      "label": getLocale("Mailing Postcode"),
      "value": data["mailingpostcode"]
    };
    extraAddress["mailingcity"] = {
      "label": getLocale("Mailing City"),
      "value": data["mailingcity"]
    };
    extraAddress["mailingstate"] = {
      "label": getLocale("Mailing State"),
      "value": data["mailingstate"]
    };
    extraAddress["mailingcountry"] = {
      "label": getLocale("Mailing Country"),
      "value": getMasterlookup(
          type: "Country", value: data["mailingcountry"])["label"]
    };
  }

  dynamic obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "a": {"label": getLocale("Address Type"), "value": getLocale("Home")},
      "address": {
        "label": getLocale("Address"),
        "value": data["address"] ?? data["address1"] ?? ""
      },
      "postcode": {"label": getLocale("Postcode"), "value": data["postcode"]},
      "city": {"label": getLocale("City"), "value": data["city"]},
      "state": {"label": getLocale("State"), "value": data["state"]},
      "country": {
        "label": getLocale("Country"),
        "value": data["country"] == "MYS"
            ? getMasterlookup(type: "Country", value: "MYS")["label"]
            : null
      },
      ...extraAddress,
      "email": {"label": getLocale("Email"), "value": data["email"]},
      "hometel": {
        "label": getLocale("Home Telephone No"),
        "value": data["hometel"]
      },
      "officetel": {
        "label": getLocale("Office Telephone No"),
        "value": data["officetel"]
      },
      "mobileno": {
        "label": getLocale("Mobile Telephone No 1"),
        "value": data["mobileno"] != null ? "+60 ${data["mobileno"]}" : null
      },
      "mobileno2": {
        "label": getLocale("Mobile Telephone No 2"),
        "value": data["mobileno2"]
      }
    }
  ];

  dynamic obj2 = [{}];
  for (var key in obj[0].keys) {
    if (key == "size" || key == "naText") {
      obj2[0][key] = obj[0][key];
    } else if (obj[0][key]["value"] != null &&
        obj[0][key]["value"] is String &&
        obj[0][key]["value"].isNotEmpty) {
      obj2[0][key] = obj[0][key];
    }
  }
  return CustomColumnTable(arrayObj: obj2, valueFontStyle: bFontW5());
}

Widget eduOccDetails(data) {
  // Education Level Occupation Name of Employer Part Time Job Nature of Business Monthly Personal Income
  dynamic obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "educationlv": {
        "label": getLocale("Education Level"),
        "value": data["educationlv"]
      },
      "occ": {
        "label": getLocale("Occupation"),
        "value": data["occupationDisplay"]
      },
      "companyname": {
        "label": getLocale("Name of Employer"),
        "value": data["companyname"]
      },
      "natureofbusiness": {
        "label": getLocale("Nature of Business"),
        "value": data["natureofbusiness"]
      },
      "monthlyincome": {
        "label": getLocale("Monthly Personal Income"),
        "value": data["monthlyincome"] != null && data["monthlyincome"] != ""
            ? toRM(data["monthlyincome"], rm: true)
            : data["monthlyincome"]
      }
    }
  ];

  dynamic obj2 = [{}];
  for (var key in obj[0].keys) {
    if (key == "size" || key == "naText") {
      obj2[0][key] = obj[0][key];
    } else if (obj[0][key]["value"] != null &&
        obj[0][key]["value"] is String &&
        obj[0][key]["value"].isNotEmpty) {
      obj2[0][key] = obj[0][key];
    }
  }
  return CustomColumnTable(arrayObj: obj2, valueFontStyle: bFontW5());
}

Widget fatcaDetails(data, {title = false}) {
  if (data["nationality"] != "8" &&
      data["nationality"] != "37" &&
      data["nationality"] != "38") {
    return const SizedBox();
  }

  String? label;
  if (data["reasonnotin"] == "reasonA") {
    label = getLocale(
        "The jurisdiction where the account holder is a resident for tax purpose does not issue TINs to its residents");
  } else if (data["reasonnotin"] == "reasonB") {
    label = data["reasonnotintext"];
  }
  var obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "a": {
        "label": getLocale(
            "Hold a United Stats Permanent Resident Card (Green Card)"),
        "value": data["holduscard"] == true ? "Yes" : "No"
      },
      "country": {
        "label": getLocale("Country"),
        "value": getMasterlookup(
            type: "Country", value: data["fatcacountry"])["label"]
      },
      "tinavailable": {
        "label": getLocale("TIN Available"),
        "value": data["tinavailable"] == true ? "Yes" : "No"
      },
      "tin": {"label": getLocale("Tin No."), "value": data["tin"]},
      "reasonnotin": {"label": getLocale("Reason"), "value": label},
    }
  ];

  if (title == true) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getLocale("FATCA Self Certification"),
          style: bFontW5().copyWith(color: greyTextColor)),
      SizedBox(height: gFontSize * 0.3),
      CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5()),
      SizedBox(height: gFontSize * 1.2),
    ]);
  }
  return CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5());
}

Widget bankDetails(data) {
  dynamic obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "a": {
        "label": getLocale("Bank Name"),
        "value": data["bankname"] != null ? getBankName(data["bankname"]) : ""
      },
      "b": {
        "label": getLocale("Account Type"),
        "value":
            data["bankaccounttype"] != null && data["bankaccounttype"] != ""
                ? getMasterlookup(
                    type: "AccountType",
                    value: data["bankaccounttype"])["label"]
                : ""
      },
      "c": {"label": getLocale("Account no."), "value": data["accountno"]},
    }
  ];

  dynamic obj2 = [{}];
  for (var key in obj[0].keys) {
    if (key == "size" || key == "naText") {
      obj2[0][key] = obj[0][key];
    } else if (obj[0][key]["value"] != null &&
        obj[0][key]["value"] is String &&
        obj[0][key]["value"].isNotEmpty) {
      obj2[0][key] = obj[0][key];
    }
  }
  if (obj[0]["c"]["value"] != null &&
      obj[0]["c"]["value"] is String &&
      obj[0]["c"]["value"].isNotEmpty) {
    return CustomColumnTable(arrayObj: obj2, valueFontStyle: bFontW5());
  } else {
    return Container();
  }
}

Widget policyOwnerDetails(data) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
        "${getLocale("Special Translation 1 for Details")} ${getLocale("Policy Owner", entity: true)} ${getLocale("Special Translation 2 for Details")}",
        style: t2FontW5().copyWith(color: cyanColor)),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Personal Details"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    personalDetails(data["policyOwner"]),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Contact Details"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    contactDetails(data["policyOwner"]),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Education & Occupation"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    eduOccDetails(data["policyOwner"]),
    SizedBox(height: gFontSize * 1.2),
    fatcaDetails(data["policyOwner"], title: true),
    Text(getLocale("Auto Credit Bank Details"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    bankDetails(data["policyOwner"]),
    Divider(height: gFontSize * 2, thickness: 2),
  ]);
}

Widget lifeInsuredDetails(data) {
  var data2 = json.decode(json.encode(data));
  if (data["buyingFor"] == BuyingFor.self.toStr) {
    return const SizedBox();
  } else {
    if (data2["lifeInsured"]["sameasparent"] == true) {
      data2["lifeInsured"]["address"] = data2["policyOwner"]["address"];
      data2["lifeInsured"]["address1"] = data2["policyOwner"]["address1"];
      data2["lifeInsured"]["address2"] = data2["policyOwner"]["address2"];
      data2["lifeInsured"]["city"] = data2["policyOwner"]["city"];
      data2["lifeInsured"]["postcode"] = data2["policyOwner"]["postcode"];
      data2["lifeInsured"]["state"] = data2["policyOwner"]["state"];
      data2["lifeInsured"]["country"] = data2["policyOwner"]["country"];
    }
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text("${getLocale("Life Insured", entity: true)} ${getLocale("Details")}",
        style: t2FontW5().copyWith(color: cyanColor)),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Personal Details"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    personalDetails(data2["lifeInsured"]),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Contact Details"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    contactDetails(data2["lifeInsured"]),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Education & Occupation"),
        style: bFontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 0.3),
    eduOccDetails(data2["lifeInsured"]),
    Divider(height: gFontSize * 2, thickness: 2)
  ]);
}

Widget payorDetails(data) {
  var data2 = json.decode(json.encode(data));
  if (data["payor"]["whopaying"] != "policyOwner" &&
      data["payor"]["whopaying"] != "lifeInsured") {
    if (data2["payor"]["sameasparent"] == true) {
      data2["payor"]["address"] = data2["policyOwner"]["address"];
      data2["payor"]["address1"] = data2["policyOwner"]["address1"];
      data2["payor"]["address2"] = data2["policyOwner"]["address2"];
      data2["payor"]["city"] = data2["policyOwner"]["city"];
      data2["payor"]["postcode"] = data2["policyOwner"]["postcode"];
      data2["payor"]["state"] = data2["policyOwner"]["state"];
      data2["payor"]["country"] = data2["policyOwner"]["country"];
    }
    var payor = data2["payor"];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getLocale("Payor Details"),
          style: t2FontW5().copyWith(color: cyanColor)),
      SizedBox(height: gFontSize * 1.2),
      Text(getLocale("Personal Details"),
          style: bFontW5().copyWith(color: greyTextColor)),
      SizedBox(height: gFontSize * 0.3),
      personalDetails(payor),
      SizedBox(height: gFontSize * 1.2),
      Text(getLocale("Contact Details"),
          style: bFontW5().copyWith(color: greyTextColor)),
      SizedBox(height: gFontSize * 0.3),
      contactDetails(payor),
      SizedBox(height: gFontSize * 1.2),
      Text(getLocale("Education & Occupation"),
          style: bFontW5().copyWith(color: greyTextColor)),
      SizedBox(height: gFontSize * 0.3),
      eduOccDetails(payor),
      Divider(height: gFontSize * 2, thickness: 2)
    ]);
  } else {
    return const SizedBox();
  }
}

Widget customerDetails(data, String? type) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
        "${getLocale("Special Translation 1 for Details")} $type ${getLocale("Special Translation 2 for Details")}",
        style: t2FontW5().copyWith(color: greyTextColor)),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Personal Details"),
        style: bFontW5().copyWith(color: tealGreenColor)),
    SizedBox(height: gFontSize * 0.3),
    personalDetails(data, isSummary: true),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Contact Details"),
        style: bFontW5().copyWith(color: tealGreenColor)),
    SizedBox(height: gFontSize * 0.3),
    contactDetails(data),
    SizedBox(height: gFontSize * 1.2),
    Text(getLocale("Education & Occupation"),
        style: bFontW5().copyWith(color: tealGreenColor)),
    SizedBox(height: gFontSize * 0.3),
    eduOccDetails(data),
    SizedBox(height: gFontSize * 1.2),
    fatcaDetails(data, title: true),
    Text(getLocale("Auto Credit Bank Details"),
        style: bFontW5().copyWith(color: tealGreenColor)),
    SizedBox(height: gFontSize * 0.3),
    bankDetails(data)
  ]);
}

Widget protentialArea(data, {bool? isSummary}) {
  var value = [];

  for (var i in data["priority"].keys) {
    value.add({
      "type": objMapping["priority$i"],
      "planned": data["priority"][i]["planned"] == true
          ? getLocale("Yes")
          : getLocale("No"),
      "toDiscuss": data["disclosure"]["discussion"] != null &&
              data["disclosure"]["discussion"][i] != null
          ? getLocale("Yes")
          : getLocale("No"),
      "priority": data["priority"][i]["priority"]
    });
  }

  var obj = {
    "header": {
      "naText": "-",
      "type": {"value": getLocale("Protection Type"), "size": 5},
      "planned": {"value": getLocale("Already Planned"), "size": 2},
      "toDiscuss": {"value": getLocale("To Discuss/Review"), "size": 2},
      "priority": {"value": getLocale("Priority"), "size": 2},
    },
    "value": value
  };

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Potential Area of Discussion"),
        style: t2FontW5()
            .copyWith(color: isSummary != null ? Colors.black : cyanColor)),
    SizedBox(height: gFontSize),
    CustomRowTable(
        arrayObj: obj,
        headerBorder: Border.all(width: 0, color: Colors.transparent),
        headerFontStyle: bFontW5(),
        rowFontStyle: bFontWN(),
        rowPadding: EdgeInsets.only(
            top: gFontSize,
            bottom: gFontSize,
            left: gFontSize,
            right: gFontSize)),
    Divider(height: gFontSize * 2, thickness: isSummary != null ? 5 : 2)
  ]);
}

Widget investmentPref(data, {bool? isSummary}) {
  var obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "a": {
        "label": getLocale("Risk Appetite"),
        "value":
            "${objMapping["investmentPref${data["investmentPreference"]["investmentpreference"].toString()}"]!} / ${data["investmentPreference"]["investmentpreference"].toString()}"
      }
    }
  ];
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Investment Preference"),
        style: t2FontW5()
            .copyWith(color: isSummary != null ? Colors.black : cyanColor)),
    SizedBox(height: gFontSize),
    CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5()),
    Visibility(
        visible: isSummary == null,
        child: Divider(height: gFontSize * 2, thickness: 2))
  ]);
}

Widget clientChoice(data, {bool? isSummary}) {
  int detailsLabelWidth = 3;
  int detailsValueWidth = 2;
  var obj = [
    {
      "size": {
        "labelWidth": detailsLabelWidth,
        "valueWidth": detailsValueWidth
      },
      "naText": naText,
      "a": {
        "label": getLocale("Disclose Option"),
        "value": data["disclosure"]["currentOption"]
      }
    }
  ];

  List<Widget> wid = [];
  List<Widget> wid2 = [];
  if (data["disclosure"] != null) {
    var standardObject = getGlobalInputJsonFormat();
    var options = [
      "saving",
      "retirement",
      "childreneducation",
      "protection",
      "medical"
    ];
    if (data["disclosure"]["discussion"] != null) {
      wid2.add(SizedBox(height: gFontSize * 1.2));
      wid2.add(Text("Future Plan", style: t2FontW5()));
      wid2.add(SizedBox(height: gFontSize));
    }

    for (var i = 0; i < options.length; i++) {
      List<Widget> inwid = [];
      List<Widget> inwid2 = [];
      var coverage = data["disclosure"]["coverage"];
      var discussion = data["disclosure"]["discussion"];

      if (coverage != null &&
          coverage[options[i]] != null &&
          coverage[options[i]].length > 0) {
        inwid.add(Row(children: [
          Text(objMapping["existing${options[i]}"]!,
              style: bFontW5().copyWith(color: darkCyanColorSeven)),
          SizedBox(width: gFontSize * 0.5),
          Container(
              padding: EdgeInsets.all(gFontSize * 0.2),
              color: Colors.black,
              child: Text(coverage[options[i]].length.toString(),
                  style: bFontW5().copyWith(color: Colors.white)))
        ]));
        for (var e = 0; e < coverage[options[i]].length; e++) {
          var obj2 = [
            {
              "size": {
                "labelWidth": detailsLabelWidth,
                "valueWidth": detailsValueWidth
              },
              "naText": naText
            }
          ];
          for (var key in coverage[options[i]][e].keys) {
            var value = coverage[options[i]][e][key];
            if (standardObject[key]["type"] == "date") {
              value =
                  dateformat.format(DateTime.fromMicrosecondsSinceEpoch(value));
            } else if (standardObject[key]["prefix"] != null) {
              value = standardObject[key]["prefix"] + value;
            } else if (standardObject[key]["type"].indexOf("option") > -1 &&
                value != null) {
              var index = standardObject[key]["options"]
                  .indexWhere((option) => option["value"] == value);
              if (index > -1) {
                value = standardObject[key]["options"][index]["label"];
              }
            }
            obj2[0]
                [key] = {"label": standardObject[key]["label"], "value": value};
          }
          inwid.add(
              CustomColumnTable(arrayObj: obj2, valueFontStyle: bFontW5()));
          inwid.add(Divider(height: gFontSize * 2, thickness: 1));
        }
      }
      if (discussion != null && discussion[options[i]] != null) {
        inwid2.add(Text(objMapping["discussion${options[i]}"]!,
            style: bFontW5().copyWith(color: darkCyanColorSeven)));
        var obj3 = [
          {
            "size": {
              "labelWidth": detailsLabelWidth,
              "valueWidth": detailsValueWidth
            },
            "naText": naText
          }
        ];
        for (var key in discussion[options[i]].keys) {
          obj3[0][key] = {
            "label": objMapping["discussion$key"],
            "value": key == "amount"
                ? toRM(discussion[options[i]][key], rm: true)
                : discussion[options[i]][key]
          };
        }
        inwid2
            .add(CustomColumnTable(arrayObj: obj3, valueFontStyle: bFontW5()));
        inwid2.add(SizedBox(height: gFontSize));

        if (isSummary == null) {
          inwid2.add(Divider(height: gFontSize * 2, thickness: 1));
        }
      }
      wid = wid + inwid;
      wid2 = wid2 + inwid2;
    }
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Client Choice Financial Advice"),
        style: t2FontW5()
            .copyWith(color: isSummary != null ? Colors.black : cyanColor)),
    SizedBox(height: gFontSize),
    CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5()),
    ...wid,
    ...wid2,
    Visibility(
        visible: isSummary == null,
        child: Divider(height: gFontSize * 2, thickness: 2))
  ]);
}

Widget generateNeeds(data) {
  var priority = {
    "protection": getLocale("Family Protection"),
    "retirement": getLocale("Retirement Plan"),
    "education": getLocale("Children's Education"),
    "saving": getLocale("Savings & Invesment"),
    "investment": getLocale("Lump Sum Investment"),
    "medical": getLocale("Medical")
  };
  String? firstPriorKey, secondPrioKey;
  int? riskPref;
  var coverage = "";

  if (data["priority"] != null && !data["priority"].isEmpty) {
    firstPriorKey = data["priority"]
        .keys
        .firstWhere((k) => data["priority"][k]["priority"] == 1);
    secondPrioKey = data["priority"]
        .keys
        .firstWhere((k) => data["priority"][k]["priority"] == 2);
  }

  if (data["investmentPreference"] != null &&
      data["investmentPreference"]["investmentpreference"] != null) {
    riskPref = data["investmentPreference"]["investmentpreference"];
  }

  if (data["disclosure"] != null && data["disclosure"]["coverage"] != null) {
    for (var key in priority.keys) {
      if (data["disclosure"]["coverage"][key] != null &&
          !data["disclosure"]["coverage"][key].isEmpty) {
        coverage = "$coverage- ${priority[key]!}\n";
      }
    }
    coverage = coverage.trim();
  }

  var obj = [
    {
      "size": {"labelWidth": 35, "valueWidth": 65},
      "priority1": {
        "label": getLocale("Top Priority"),
        "value": priority[firstPriorKey]
      },
      "priority2": {
        "label": getLocale("Second Priority"),
        "value": priority[secondPrioKey]
      },
      "riskPref": {
        "label": getLocale("Investment Risk Preference"),
        "value": riskPref.toString()
      },
      "existingCoverage": {
        "label": getLocale("Existing Plan/Coverage"),
        "value": coverage
      }
    }
  ];

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Recommended Products"), style: t2FontW5()),
    CustomColumnTable(arrayObj: obj)
  ]);
}

Widget generateSIMI(data) {
  var p = data["listOfQuotation"][0];
  var version = Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(gFontSize * 0.2),
                  color: lightCyanColorFive),
              padding: EdgeInsets.all(gFontSize * 0.4),
              child: Text("${getLocale("Version")} ${(p["version"] ?? "1")}",
                  style: bFontWN().copyWith(color: Colors.white)))));
  var lob = p["productPlanLOB"];
  var lobstr =
      lookupProductLOB.keys.firstWhereOrNull((k) => lookupProductLOB[k] == lob);

  var obj = [
    {
      "size": {"labelWidth": 35, "valueWidth": 65},
      "quotation": {"label": getLocale("Quotation"), "value": version},
      "planType": {
        "label": getLocale("Plan Type"),
        "value": lookupProductType(p["productPlanCode"])
      },
      "productLOB": {"label": getLocale("Product LOB"), "value": lobstr},
      "steppedPremium": {
        "label": getLocale("Stepped Premium"),
        "value": p["isSteppedPremium"] != null && p["isSteppedPremium"]
            ? getLocale("Yes")
            : getLocale("No")
      },
      "paymentMode": {
        "label": getLocale("Payment Mode"),
        "value": getLocale(convertPaymentMode(p["paymentMode"]))
      },
      "maturityAge": {
        "label": getLocale("Maturity Age"),
        "value": p["maturityAge"]
      }
    }
  ];

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: gFontSize),
    Text(getLocale("SI/MI Details"), style: t2FontW5()),
    CustomColumnTable(arrayObj: obj)
  ]);
}

Widget recommendedProduct(data, {onChange}) {
  var p = data["listOfQuotation"][0];

  dynamic basicPlan = {
    "header": {
      "plan": {"value": "(A) Basic Plan", "size": 5},
      "sum": {
        "value": p["productPlanLOB"] == "ProductPlanType.traditional"
            ? getLocale("Initial Sum Insured")
            : getLocale("Sum Insured"),
        "size": 5
      },
      "premiumterm": {
        "value": getLocale("Payment Term", entity: true),
        "size": 3
      },
      "policyterm": {
        "value": p["productPlanLOB"] == "ProductPlanType.traditional"
            ? getLocale("Term of Coverage")
            : getLocale("Policy Term", entity: true),
        "size": 3
      },
      "premium": {
        "value":
            getLocale("${convertPaymentModeInt(p['paymentMode'])} Premium"),
        "size": 4
      }
    },
    "value": [
      {
        "plan": p["productPlanName"],
        "sum": toRM(p["sumInsuredAmt"], rm: true),
        "policyterm": p["basicPlanPolicyTerm"],
        "premiumterm": p["basicPlanPaymentTerm"],
        "premium": toRM(p["basicPlanPremiumAmount"], rm: true)
      }
    ]
  };
  if (p["enricherPremiumAmount"] != null) {
    basicPlan["value"].add({
      "plan": "Enricher",
      "sum": "N/A",
      "premiumterm": p["enricherPaymentTerm"],
      "policyterm": p["enricherPolicyTerm"],
      "premium": p["enricherPremiumAmount"] != null
          ? toRM(p["enricherPremiumAmount"], rm: true)
          : null
    });
  }

  var riders = p["riderOutputDataList"];
  var productPlanLOB = p["productPlanLOB"];

  if (riders == null || riders.isEmpty) {
    riders = [{}];
  } else {
    riders.forEach((rider) {
      if (rider["isUnitBasedProd"] != null && rider["isUnitBasedProd"]) {
        rider["riderSA"] = rider["riderSA"];
      } else if (isNumeric(rider["riderSA"])) {
        rider["riderSA"] = toRM(rider["riderSA"]);
        rider["riderType"] = rider["riderMonthlyPremium"] != null &&
                rider["riderMonthlyPremium"] != "N/A"
            ? toRM(rider["riderMonthlyPremium"], rm: true)
            : rider["riderType"];
      }
      if (rider["riderCode"] == "PCHI03") {
        var ratescale = p["guaranteedCashPayment"] == "1"
            ? "Guaranteed Cash Payment(GCP) + Maturity Benefit"
            : "Lump Sum Payment At Maturity";
        rider["riderName"] = "IL Savings Growth\n- $ratescale";
        rider["riderSA"] = "N/A";
        rider["riderPaymentTerm"] = p["gcpPremTerm"];
        rider["riderOutputTerm"] = p["gcpTerm"];
        rider["riderType"] = toRM(p["gcpPremAmt"], rm: true);
      }
      if (rider["riderCode"] == "PTHI01") {
        var ratescale = p["guaranteedCashPayment"] == "1"
            ? "To Receive GCP"
            : "Maturity Payments";
        rider["riderName"] = "Takafulink Saving Flexi\n- $ratescale";
        rider["riderSA"] = "N/A";
        rider["riderPaymentTerm"] = p["gcpPremTerm"];
        rider["riderOutputTerm"] = p["gcpTerm"];
        rider["riderType"] = toRM(p["gcpPremAmt"], rm: true);
      }
    });
  }
  var rider = {
    "header": {
      "emptyText": getLocale("- No Rider Selected -"),
      "naText": "-",
      "riderName": {"value": "(B) Riders", "size": 5},
      "riderSA": {
        "value": p["productPlanLOB"] == "ProductPlanType.traditional"
            ? getLocale("Initial Sum Insured")
            : getLocale("Sum Insured"),
        "size": 5
      },
      "riderPaymentTerm": {
        "value": getLocale("Payment Term", entity: true),
        "size": 3
      },
      "riderOutputTerm": {
        "value": p["productPlanLOB"] == "ProductPlanType.traditional"
            ? getLocale("Term of Coverage")
            : getLocale("Riders Term"),
        "size": 3
      },
      "riderType": {
        "value": getLocale("${convertPaymentMode(p['paymentMode'])} Premium"),
        "size": 4
      }
    },
    "value": riders
  };

  var rtu = {
    "header": {
      "naText": "-",
      "name": {"value": "(C) Regular Top Up", "size": 10},
      "rtuPaymentTerm": {
        "value": getLocale("Payment Term", entity: true),
        "size": 3
      },
      "rtuPolicyTerm": {"value": "RTU Term", "size": 3},
      "rtuPremiumAmount": {
        "value": getLocale("${convertPaymentMode(p['paymentMode'])} Premium"),
        "size": 4
      }
    },
    "value": [
      {
        "name": "Regular Top Up",
        "rtuPolicyTerm": p["rtuPolicyTerm"],
        "rtuPaymentTerm": p["rtuPaymentTerm"],
        "rtuPremiumAmount": toRM(p["rtuPremiumAmount"], rm: true)
      }
    ]
  };

  var fund = {
    "header": {
      "fundName": {"value": getLocale("Fund Name"), "size": 70},
      "fundAlloc": {
        "value": getLocale("Investment Allocation"),
        "size": 30,
        "append": "%"
      }
    },
    "value": p["fundOutputDataList"]
  };

  String abc = "";
  String totalpremtext = "";
  if (p["eligibleRiders"] != null && p["eligibleRiders"]!.isNotEmpty) {
    abc = " (A + B)";
    if (p["productPlanLOB"] != "ProductPlanType.traditional") {
      abc = " (A + B + C)";
    }
  }
  if (p["paymentMode"] != null) {
    if (isNumeric(p["paymentMode"])) {
      totalpremtext =
          "${getLocale("Total")} ${getLocale(convertPaymentMode(p["paymentMode"]))} ${getLocale("Premium")} $abc";
    } else {
      totalpremtext =
          "${getLocale("Total")} ${getLocale(p["paymentMode"]!)} ${getLocale("Premium")} $abc";
    }
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    generateNeeds(data),
    generateSIMI(data),
    SizedBox(height: gFontSize),
    CustomRowTable(
        arrayObj: basicPlan,
        headerBorder:
            Border(bottom: BorderSide(color: greyBorderTFColor, width: 3)),
        headerFontStyle: sFontW5(),
        rowFontStyle: sFontWN(),
        rowPadding: EdgeInsets.only(
            top: gFontSize * 0.5,
            bottom: gFontSize * 0.5,
            left: gFontSize,
            right: gFontSize)),
    CustomRowTable(
        arrayObj: rider,
        headerBorder:
            Border(bottom: BorderSide(color: greyBorderTFColor, width: 3)),
        headerFontStyle: sFontW5(),
        rowFontStyle: sFontWN(),
        rowPadding: EdgeInsets.only(
            top: gFontSize * 0.5,
            bottom: gFontSize * 0.5,
            left: gFontSize,
            right: gFontSize)),
    Visibility(
        visible: p["productPlanLOB"] != "ProductPlanType.traditional",
        child: CustomRowTable(
            arrayObj: rtu,
            headerBorder:
                Border(bottom: BorderSide(color: greyBorderTFColor, width: 3)),
            headerFontStyle: sFontW5(),
            rowFontStyle: sFontWN(),
            rowPadding: EdgeInsets.only(
                top: gFontSize * 0.5,
                bottom: gFontSize * 0.5,
                left: gFontSize,
                right: gFontSize))),
    Container(
        margin: EdgeInsets.symmetric(vertical: gFontSize),
        padding: EdgeInsets.symmetric(
            vertical: gFontSize, horizontal: gFontSize * 1.7),
        color: lightCyanColor,
        child: Row(children: [
          Expanded(flex: 80, child: Text(totalpremtext, style: sFontWN())),
          Expanded(
              flex: 20,
              child: Text(toRM(p["totalPremium"], rm: true), style: bFontW5()))
        ])),
    const Divider(),
    productPlanLOB == "ProductPlanType.traditional"
        ? Container()
        : Column(
            children: [
              Text(getLocale("Funds"), style: t2FontW5()),
              CustomRowTable(
                  arrayObj: fund,
                  headerBorder: Border(
                      bottom: BorderSide(color: greyBorderTFColor, width: 3)),
                  headerFontStyle: sFontW5(),
                  rowFontStyle: sFontWN(),
                  rowPadding: EdgeInsets.only(
                      top: gFontSize,
                      bottom: gFontSize,
                      left: gFontSize,
                      right: gFontSize)),
              Container(
                  padding: EdgeInsets.symmetric(
                      vertical: gFontSize, horizontal: gFontSize * 1.7),
                  color: lightCyanColor,
                  child: Row(children: [
                    Expanded(
                        flex: 70,
                        child: Text(getLocale("Total"), style: sFontWN())),
                    Expanded(
                        flex: 30,
                        child:
                            Text(p["totalFundAlloc"] + "%", style: bFontW5()))
                  ])),
            ],
          ),
    Padding(
      padding: EdgeInsets.symmetric(vertical: gFontSize * 2),
      child: RichText(
        text: TextSpan(
          text:
              '* ${getLocale("If you want to view the Illustration of Premium Benefits, please refer at SI/MI section or click")} ',
          style: bFontW5(),
          children: <TextSpan>[
            TextSpan(
                text: getLocale('here'),
                style: bFontWB().copyWith(color: cyanColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onChange();
                  })
          ],
        ),
      ),
    ),
  ]);
}

Widget nomination(data) {
  List<Widget> wid = [];
  List<Widget> wid2 = [];
  List<Widget> wid3 = [];
  if (data["nomination"] != null &&
      data["nomination"]["nominee"] is List &&
      data["nomination"]["nominee"].length > 0) {
    wid.add(Row(children: [
      Text(getLocale("Nominee Details"),
          style: bFontW5().copyWith(color: darkCyanColorSeven)),
      SizedBox(width: gFontSize * 0.5),
      Container(
          padding: EdgeInsets.all(gFontSize * 0.2),
          color: Colors.black,
          child: Text(data["nomination"]["nominee"].length.toString(),
              style: bFontW5().copyWith(color: Colors.white)))
    ]));
    for (var i = 0; i < data["nomination"]["nominee"].length; i++) {
      wid.add(personalDetails(data["nomination"]["nominee"][i]));
      wid.add(contactDetails(data["nomination"]["nominee"][i]));
      wid.add(eduOccDetails(data["nomination"]["nominee"][i]));
      wid.add(fatcaDetails(data["nomination"]["nominee"][i]));
      wid.add(bankDetails(data["nomination"]["nominee"][i]));
      wid.add(Divider(height: gFontSize * 2, thickness: 1));
    }
  } else {
    wid.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(getLocale("No Nomination"), style: bFontWN())]));
  }
  if (data["benefitOwner"] != null &&
      data["benefitOwner"]["person"] is List &&
      data["benefitOwner"]["person"].length > 0) {
    wid2.add(Row(children: [
      Text(getLocale("Beneficial Owner Details"),
          style: bFontW5().copyWith(color: darkCyanColorSeven)),
      SizedBox(width: gFontSize * 0.5),
      Container(
          padding: EdgeInsets.all(gFontSize * 0.2),
          color: Colors.black,
          child: Text(data["benefitOwner"]["person"].length.toString(),
              style: bFontW5().copyWith(color: Colors.white)))
    ]));
    for (var i = 0; i < data["benefitOwner"]["person"].length; i++) {
      wid2.add(personalDetails(data["benefitOwner"]["person"][i]));
      wid2.add(contactDetails(data["benefitOwner"]["person"][i]));
      wid2.add(eduOccDetails(data["benefitOwner"]["person"][i]));
      wid2.add(fatcaDetails(data["benefitOwner"]["person"][i]));
      wid2.add(bankDetails(data["benefitOwner"]["person"][i]));
      wid2.add(Divider(height: gFontSize * 2, thickness: 1));
    }
  }
  if (data["nomination"] != null &&
      data["nomination"]["trustee"] is List &&
      data["nomination"]["trustee"].length > 0) {
    wid3.add(Row(children: [
      Text("Trustee Details",
          style: bFontW5().copyWith(color: darkCyanColorSeven)),
      SizedBox(width: gFontSize * 0.5),
      Container(
          padding: EdgeInsets.all(gFontSize * 0.2),
          color: Colors.black,
          child: Text(data["nomination"]["trustee"].length.toString(),
              style: bFontW5().copyWith(color: Colors.white)))
    ]));
    data["nomination"]["trustee"].forEach((trustee) {
      wid3.add(personalDetails(trustee));
      wid3.add(contactDetails(trustee));
      wid3.add(eduOccDetails(trustee));
      wid3.add(fatcaDetails(trustee));
      wid3.add(bankDetails(trustee));
      wid3.add(Divider(height: gFontSize * 2, thickness: 1));
    });
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Nominations"),
        style: t2FontW5().copyWith(color: cyanColor)),
    SizedBox(height: gFontSize),
    // CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5()),
    ...wid,
    ...wid2,
    ...wid3,
    Divider(height: gFontSize * 2, thickness: 2)
  ]);
}

Widget healthQuestion(data) {
  String getSection(question) {
    var replace = ["1333", "1334", "1335"];
    var coverage = ["1040", "1042"];
    var life = ["1288", "1034", "1036", "1038"];
    var hw = ["1078h", "1078w", "1032"];
    if (life.contains(question)) {
      return "life";
    } else if (coverage.contains(question)) {
      return "coverage";
    } else if (replace.contains(question)) {
      return "replace";
    } else if (hw.contains(question)) {
      return "hw";
    } else {
      return "health";
    }
  }

  List<Widget> widhealth = [
    Text(getLocale("Medical & Health"),
        style: bFontW5().copyWith(color: darkCyanColorSeven)),
    SizedBox(height: gFontSize)
  ];
  List<Widget> widlife = [
    Text(getLocale("Lifestyle"),
        style: bFontW5().copyWith(color: darkCyanColorSeven)),
    SizedBox(height: gFontSize)
  ];
  List<Widget> widcoverage = [
    Text(getLocale("Existing Coverage"),
        style: bFontW5().copyWith(color: darkCyanColorSeven)),
    SizedBox(height: gFontSize)
  ];
  List<Widget> widreplace = [
    Text(getLocale("Policy or Certificate Replacement"),
        style: bFontW5().copyWith(color: darkCyanColorSeven)),
    SizedBox(height: gFontSize)
  ];
  List<Widget> widhw = [
    Text(getLocale("Height & Weight"),
        style: bFontW5().copyWith(color: darkCyanColorSeven)),
    SizedBox(height: gFontSize)
  ];

  var healthIndex = 1;
  var lifeIndex = 1;
  var coverageIndex = 1;
  var replaceIndex = 1;
  for (var i in data.keys) {
    List<Widget> array = [];
    dynamic json;
    if (i != "readAndAgree" && i != "empty") {
      if (data[i]["AnswerXML"] != null) {
        json = xml2json(data[i]["AnswerXML"]);
      }

      var question = getQuestions(i);

      if (getSection(i) == "health") {
        array = widhealth;
        array.add(Text("${healthIndex.toString()}. ${question["plaintext"]}",
            style: bFontWN().copyWith(color: greyTextColor)));
        healthIndex++;
      }
      if (getSection(i) == "replace") {
        if (data[i]['QuesNo'] == '1335' && data[i]['AnswerValue'] == false) {
        } else {
          array = widreplace;
          array.add(Text("${replaceIndex.toString()}. ${question["plaintext"]}",
              style: bFontWN().copyWith(color: greyTextColor)));
          replaceIndex++;
        }
      }
      if (getSection(i) == "coverage") {
        array = widcoverage;
        array.add(Text("${coverageIndex.toString()}. ${question["plaintext"]}",
            style: bFontWN().copyWith(color: greyTextColor)));
        coverageIndex++;
      }
      if (getSection(i) == "life") {
        array = widlife;
        array.add(Text("${lifeIndex.toString()}. ${question["plaintext"]}",
            style: bFontWN().copyWith(color: greyTextColor)));
        lifeIndex++;
      }
      if (getSection(i) == "hw") {
        array = widhw;

        array.add(Text(question["plaintext"],
            style: bFontWN().copyWith(color: greyTextColor)));
        var value = data[i]["AnswerValue"];
        if (data[i]["AnswerValue"] is bool) {
          value = data[i]["AnswerValue"] == true
              ? getLocale("Yes")
              : getLocale("No");
        }

        if (question["suffix"] != null) {
          value = "${value.toString()} ${question["suffix"]}";
        }

        array.add(Text(value, style: bFontWB()));
        array.add(SizedBox(height: gFontSize));
        if (json != null &&
            json["Answer"] != null &&
            json["Answer"].length > 0) {
          for (var e = 0; e < json["Answer"].length; e++) {
            for (var key2 in json["Answer"][e].keys) {
              var index = question["options"].indexWhere(
                  (option) => option["value"] == data[i]["AnswerValue"]);
              if (index > -1) {
                if (question["options"][index]["option_fields"] != null &&
                    question["options"][index]["option_fields"][key2] != null) {
                  array.add(Text(
                      question["options"][index]["option_fields"][key2]
                          ["label"],
                      style: bFontWN().copyWith(color: greyTextColor)));

                  array.add(Text(json["Answer"][e][key2], style: bFontWB()));
                }
              }
            }
          }
        }
        continue;
      }

      array.add(Text(
          data[i]["AnswerValue"] == true ? getLocale("Yes") : getLocale("No"),
          style: bFontWB()));
      array.add(SizedBox(height: gFontSize));
      if (json != null && json["Answer"] != null && json["Answer"].length > 0) {
        for (var e = 0; e < json["Answer"].length; e++) {
          var obj = [
            {
              "size": {"labelWidth": 50, "valueWidth": 50},
              "naText": naText
            }
          ];
          for (var key2 in json["Answer"][e].keys) {
            var index = question["options"].indexWhere(
                (option) => option["value"] == data[i]["AnswerValue"]);
            if (index > -1) {
              if (question["options"][index]["option_fields"] != null &&
                  question["options"][index]["option_fields"][key2] != null) {
                obj[0][key2] = {
                  "label": question["options"][index]["option_fields"][key2]
                      ["label"],
                  "value": json["Answer"][e][key2]
                };
              }
            }
          }
          array.add(Container(
              padding: EdgeInsets.symmetric(
                  vertical: gFontSize * 0.2, horizontal: gFontSize * 2),
              child:
                  CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5())));
        }
      }
    }
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: gFontSize * 2),
    ...widhw,
    Divider(height: gFontSize * 2, thickness: 1),
    ...widhealth,
    Divider(height: gFontSize * 2, thickness: 1),
    ...widlife,
    Divider(height: gFontSize * 2, thickness: 1),
    ...widcoverage,
    Divider(height: gFontSize * 2, thickness: 1),
    ...widreplace
  ]);
}

Widget policyOwnerHealthQuestion(data) {
  if (data["poquestion"] == null) {
    return const SizedBox();
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
        "${getLocale("Questions for Application for")} ${getLocale("Policy Owner", entity: true)}",
        style: t2FontW5().copyWith(color: cyanColor)),
    healthQuestion(data["poquestion"]),
    Divider(height: gFontSize * 2, thickness: 2)
  ]);
}

Widget lifeInsuredHealthQuestion(data) {
  if (data["liquestions"] == null) {
    return const SizedBox();
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
        "${getLocale("Questions for Application for")} ${getLocale("Life Insured", entity: true)}",
        style: t2FontW5().copyWith(color: cyanColor)),
    healthQuestion(data["liquestions"])
  ]);
}

Widget tableContainer(String? title,
    {bool? isHeader,
    bool? isFooter,
    bool? isLast,
    bool? isLeft,
    String? prod,
    String? enricher}) {
  return Container(
      height: isFooter != null ? gFontSize * 3 : null,
      width: dScreenWidth,
      padding: EdgeInsets.symmetric(
          vertical: 8, horizontal: isLeft != null && isLeft ? 12 : 8),
      decoration: BoxDecoration(
          color: isHeader != null
              ? creamColor
              : isFooter != null
                  ? lightCyanColor
                  : Colors.white,
          border: Border(
              bottom: BorderSide(
                  width: isHeader != null && isHeader ? 3 : 1,
                  color: isHeader != null && isHeader
                      ? greyBorderTFColor
                      : isFooter != null || (isLast != null && isLast)
                          ? Colors.transparent
                          : greyBorderColor))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prod != null
                ? RichText(
                    text: TextSpan(
                        text: prod,
                        style: sFontWB(),
                        children: <TextSpan>[
                        TextSpan(
                            text: enricher != null ? "\n$enricher" : "",
                            style: bFontW5().copyWith(fontSize: 15))
                      ]))
                : Text(title ?? "-",
                    style: sFontW5().copyWith(
                        color: isHeader != null ? greyTextColor : Colors.black))
          ]));
}

Widget tableHeader(obj) {
  List<Widget> widList = [];
  int i = 0;
  obj.forEach((element) {
    bool isLeft = i == 0;
    if (element["span"] != null) {
      List<Widget> widSpanList = [];
      element["span"].forEach((element) {
        widSpanList.add(Expanded(
            flex: element["size"],
            child: tableContainer(element["label"], isHeader: true)));
      });
      widList.add(Expanded(
          flex: element["size"],
          child: Column(children: [
            tableContainer(element["label"], isHeader: false, isLast: true),
            Row(children: widSpanList)
          ])));
    } else {
      widList.add(Expanded(
          flex: element["size"],
          child: tableContainer(element["label"],
              isHeader: true, isLeft: isLeft)));
    }
    i++;
  });
  return IntrinsicHeight(child: Row(children: widList));
}

Widget tableContent(obj) {
  List<Widget> widList = [];
  int i = 0;
  obj.forEach((element) {
    bool isLast = i == obj.length - 1;
    List<Widget> rowWidList = [];
    rowWidList.add(Expanded(
        flex: 5,
        child: tableContainer("",
            prod: element["prod"],
            enricher: element["enr"],
            isLast: isLast,
            isLeft: true)));
    rowWidList.add(Expanded(
        flex: 5, child: tableContainer(element["prodSA"], isLast: isLast)));
    rowWidList.add(Expanded(
        flex: 3,
        child: tableContainer(
            element["enrstd"] != null
                ? element["premium"] + "\n" + element["enrstd"]
                : element["premium"],
            isLast: isLast)));
    rowWidList.add(Expanded(
        flex: 3,
        child: tableContainer(
            element["enrsubstd"] != null
                ? element["substd"] + "\n" + element["enrsubstd"]
                : element["substd"],
            isLast: isLast)));

    widList.add(IntrinsicHeight(child: Row(children: rowWidList)));
    i++;
  });
  return Column(children: widList);
}

Widget decisionSummary(data) {
  final df = DateFormat('dd-MM-yyyy HH:mm:ss');
  var p = data["listOfQuotation"][0];
  var productPlanLOB = p["productPlanLOB"];
  var plans = [];

  if (productPlanLOB != "ProductPlanType.traditional") {
    String stepprem = p["isSteppedPremium"] != null && p["isSteppedPremium"]
        ? getLocale("Yes")
        : getLocale("No");

    plans.add({
      "prod": p["productPlanName"],
      "prodSA": toRM(p["sumInsuredAmt"], rm: true),
      "premium": toRM(p["basicPlanPremiumAmount"], rm: true),
      "substd": "-",
      "enr": "Enricher (Stepped Premium = $stepprem)",
      "enrstd": isNumeric(p["enricherPremiumAmount"])
          ? toRM(p["enricherPremiumAmount"])
          : p["enricherPremiumAmount"],
      "enrsubstd": "-"
    });

    if (p["rtuPremiumAmount"] != null &&
        p["rtuPremiumAmount"] != 0 &&
        p["rtuPremiumAmount"] != "0") {
      plans.add({
        "prod": "Regular Top Up",
        "prodSA": p["rtuSumInsured"],
        "premium": isNumeric(p["rtuPremiumAmount"])
            ? toRM(p["rtuPremiumAmount"])
            : p["rtuPremiumAmount"],
        "substd": "-"
      });
    }
  }

  var riders = p["riderOutputDataList"];
  if (riders == null || riders.isEmpty) {
    riders = [{}];
  } else {
    riders.forEach((rider) {
      String riderSA;
      if (isNumeric(rider["riderSA"])) {
        riderSA = toRM(rider["riderSA"], rm: true);
      } else {
        riderSA = rider["riderSA"];
      }
      if (rider["riderCode"] == "PCHI03") {
        var ratescale = p["guaranteedCashPayment"] == "1"
            ? "Guaranteed Cash Payment(GCP) + Maturity Benefit"
            : "Lump Sum Payment At Maturity";
        plans.add({
          "prod": "IL Savings Growth\n- $ratescale",
          "prodSA": "N/A",
          "premium": toRM(p["gcpPremAmt"]),
          "substd": "-"
        });
      } else if (rider["riderCode"] == "PTHI01") {
        var ratescale = p["guaranteedCashPayment"] == "1"
            ? "To Receive GCP"
            : "Maturity Payments";
        plans.add({
          "prod": "Takafulink Saving Flexi\n- $ratescale",
          "prodSA": "N/A",
          "premium": toRM(p["gcpPremAmt"]),
          "substd": "-"
        });
      } else {
        plans.add({
          "prod": rider["riderName"],
          "prodSA": riderSA,
          "premium": rider["riderType"] ?? "N/A",
          "substd": "-"
        });
      }
    });
  }

  var fund = {
    "header": {
      "fundName": {"value": getLocale("Fund Name"), "size": 70},
      "fundAlloc": {
        "value": getLocale("Investment Allocation"),
        "size": 30,
        "append": "%"
      }
    },
    "value": p["fundOutputDataList"]
  };

  var header = [
    {"label": getLocale("Basic and Supplementary Benefit"), "size": 5},
    {"label": getLocale("Sum Covered/Benefit (RM)"), "size": 5},
    {
      "label": getLocale("Premium/Contribution (RM)"),
      "size": 6,
      "span": [
        {"label": "Standard", "size": 5},
        {"label": "-", "size": 5}
      ]
    }
  ];
  // TODO check rm
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Decision"), style: t2FontW5()),
    SizedBox(height: gFontSize),
    productPlanLOB == "ProductPlanType.traditional" ||
            p["productPlanCode"] == "PTJI01" ||
            p["productPlanCode"] == "PTHI01" ||
            p["productPlanCode"] == "PTHI02"
        ? Container()
        : Text(getLocale(data["caseindicator"]),
            style: bFontW5().copyWith(color: tealGreenColor)),
    SizedBox(height: gFontSize),
    Row(children: [
      Expanded(
          child: Text(getLocale("Maturity Age"),
              style: bFontW5().copyWith(color: greyTextColor))),
      Expanded(
          flex: 2,
          child:
              Text(data["listOfQuotation"][0]["maturityAge"], style: bFontW5()))
    ]),
    SizedBox(height: gFontSize),
    tableHeader(header),
    tableContent(plans),
    Container(
        padding: EdgeInsets.symmetric(
            vertical: gFontSize, horizontal: gFontSize * 0.6),
        color: lightCyanColor,
        child: Row(children: [
          Expanded(
              flex: 10,
              child: Text(getLocale("Total Payable"), style: bFontW5())),
          Expanded(
              flex: 6,
              child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(toRM(p["totalPremium"], rm: true),
                      style: bFontW5())))
        ])),
    SizedBox(height: gFontSize * 2),
    productPlanLOB == "ProductPlanType.traditional"
        ? Container()
        : Column(
            children: [
              CustomRowTable(
                  arrayObj: fund,
                  headerBorder: Border(
                      bottom: BorderSide(color: greyBorderTFColor, width: 3)),
                  headerFontStyle: sFontW5(),
                  rowFontStyle: sFontWN(),
                  rowPadding: EdgeInsets.only(
                      top: gFontSize,
                      bottom: gFontSize,
                      left: gFontSize,
                      right: gFontSize)),
              Container(
                  padding: EdgeInsets.symmetric(
                      vertical: gFontSize, horizontal: gFontSize * 1.7),
                  color: lightCyanColor,
                  child: Row(children: [
                    Expanded(
                        flex: 70,
                        child: Text(getLocale("Total"), style: bFontW5())),
                    Expanded(
                        flex: 30,
                        child:
                            Text(p["totalFundAlloc"] + "%", style: bFontW5()))
                  ])),
            ],
          ),
    Padding(
        padding: EdgeInsets.symmetric(vertical: gFontSize * 2),
        child: Text(
            "${getLocale("Last assessment date & time")}: ${df.format(data["applicationDate"] != null ? DateTime.fromMicrosecondsSinceEpoch(data["applicationDate"]) : DateTime.now())}",
            style: bFontWN().copyWith(color: greyTextColor)))
  ]);
}

Widget idSignColumn(
    Uint8List? frontByte, Uint8List? backByte, Uint8List? signatureByte) {
  return Column(children: [
    Visibility(
        visible: frontByte != null && backByte != null,
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(getLocale("NRIC Front"), style: sFontWN()),
                Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: greyBorderTFColor, width: 2),
                        borderRadius: BorderRadius.circular(gFontSize * 0.4)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(gFontSize * 0.4),
                            child: frontByte != null
                                ? Image.memory(frontByte)
                                : Container())))
              ])),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(getLocale("NRIC Back"), style: sFontWN()),
                Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: greyBorderTFColor, width: 2),
                        borderRadius: BorderRadius.circular(gFontSize * 0.4)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(gFontSize * 0.4),
                            child: backByte != null
                                ? Image.memory(backByte)
                                : Container())))
              ]))
        ])),
    SizedBox(height: frontByte != null && backByte != null ? gFontSize : 0),
    Row(children: [
      Expanded(
          flex: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Signature"), style: sFontWN()),
            Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: lightCyanColor, width: gFontSize * 0.3),
                    borderRadius: BorderRadius.circular(gFontSize * 0.5)),
                child: signatureByte != null
                    ? Image.memory(signatureByte)
                    : Container())
          ])),
      Expanded(child: Container())
    ])
  ]);
}

Widget idSignature(client) {
  List<String?> imgByte = [];
  Uint8List? frontByte;
  Uint8List? backByte;
  Uint8List? signatureByte;
  if (client["isRemote"]) {
    frontByte = base64.decode(client["identityFront"]);
    backByte = base64.decode(client["identityBack"]);
    signatureByte = base64.decode(client["signature"]);
  } else {
    if (client["identityFront"] != "") {
      imgByte.add(client["identityFront"]);
    }
    if (client["identityBack"] != "") {
      imgByte.add(client["identityBack"]);
    }
    if (client["signature"] != "") {
      imgByte.add(client["signature"]);
    }
  }

  return Padding(
      padding: EdgeInsets.symmetric(vertical: gFontSize),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize),
            child: Text(client["role"] + " - " + client["name"],
                style: bFontW5())),
        client["isRemote"]
            ? idSignColumn(frontByte, backByte, signatureByte)
            : FutureBuilder<dynamic>(
                future: getImageByte(imgByte),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    var imgData = snapshot.data;
                    if (imgData.length > 2) {
                      frontByte = imgData[0];
                      backByte = imgData[1];
                      signatureByte = imgData[2];

                      return idSignColumn(frontByte, backByte, signatureByte);
                    } else if (imgData.length > 0) {
                      signatureByte = imgData[0];

                      return idSignColumn(frontByte, backByte, signatureByte);
                    } else {
                      return Container();
                    }
                  } else {
                    return buildLoading();
                  }
                })
      ]));
}

Widget identitySignatureSummary(data) {
  List<Widget> idSignWidList = [];
  var listOfRecipient = [];

  if (data["consentMinor"] != null &&
      data["consentMinor"] &&
      data["guardian"] != null) {
    bool isRemote = data["guardian"]["isSignRemote"] != null &&
        data["guardian"]["isSignRemote"];
    var parentGuardian = {
      "role": "Parent/Guardian (Consent For Minor)",
      "name": data["guardian"]["name"],
      "identitytype": data["guardian"]["identitytype"],
      "nric": data["guardian"]["nric"],
      "isRemote": isRemote,
      "signature": !isRemote ? data["guardian"]["signature"] : "",
      "identityFront": !isRemote ? data["guardian"]["identityFront"] : "",
      "identityBack": !isRemote ? data["guardian"]["identityBack"] : ""
    };
    listOfRecipient.add(parentGuardian);
  }

  if (data["nomination"] != null && data["nomination"]["trustee"] != null) {
    bool isRemote = data["trusteesign"] != null &&
        data["trusteesign"]["isSignRemote"] != null &&
        data["trusteesign"]["isSignRemote"];

    int i = 0;
    if (data["nomination"]["trustee"] is Map) {
      data["nomination"]["trustee"].forEach((element) {
        String key = "${i}Identity";
        var trustee = {
          "role": "Trustee",
          "name": element["name"],
          "identitytype": element["identitytype"],
          "nric": element["nric"],
          "isRemote": isRemote,
          "signature": !isRemote
              ? data["trusteesign"] != null &&
                      data["trusteesign"][key]["signature"] != null
                  ? data["trusteesign"][key]["signature"]
                  : null
              : null,
          "identityFront": !isRemote
              ? data["trusteesign"] != null &&
                      data["trusteesign"][key]["identityFront"] != null
                  ? data["trusteesign"][key]["identityFront"]
                  : null
              : null,
          "identityBack": !isRemote
              ? data["trusteesign"] != null &&
                      data["trusteesign"][key]["identityBack"] != null
                  ? data["trusteesign"][key]["identityBack"]
                  : null
              : null
        };
        listOfRecipient.add(trustee);
        i++;
      });
    }
  }

  if (data["declaration"] != null) {
    bool isRemote = data["declaration"]["isSignRemote"] != null &&
        data["declaration"]["isSignRemote"];
    if (data["buyingFor"] == BuyingFor.self.toStr) {
      var policyOwner = {
        "role":
            "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
        "name": data["policyOwner"]["name"],
        "identitytype": data["policyOwner"]["identitytype"],
        "nric": data["policyOwner"]["nric"],
        "isRemote": isRemote,
        "signature":
            !isRemote ? data["declaration"]["ownerIdentity"]["signature"] : "",
        "identityFront": !isRemote
            ? data["declaration"]["ownerIdentity"]["identityFront"]
            : "",
        "identityBack": !isRemote
            ? data["declaration"]["ownerIdentity"]["identityBack"]
            : ""
      };
      listOfRecipient.add(policyOwner);
    } else {
      if (data["policyOwner"] != null && data["lifeInsured"] != null) {
        if (data["policyOwner"]["nric"] != data["lifeInsured"]["nric"]) {
          var policyOwner = {
            "role": getLocale("Policy Owner", entity: true),
            "name": data["policyOwner"]["name"],
            "identitytype": data["policyOwner"]["identitytype"],
            "nric": data["policyOwner"]["nric"],
            "isRemote": isRemote,
            "signature": !isRemote
                ? data["declaration"]["ownerIdentity"]["signature"]
                : "",
            "identityFront": !isRemote
                ? data["declaration"]["ownerIdentity"]["identityFront"]
                : "",
            "identityBack": !isRemote
                ? data["declaration"]["ownerIdentity"]["identityBack"]
                : ""
          };
          var lifeInsured = {
            "role": getLocale("Life Insured", entity: true),
            "name": data["lifeInsured"]["name"],
            "identitytype": data["lifeInsured"]["identitytype"],
            "nric": data["lifeInsured"]["nric"],
            "isRemote": isRemote,
            "signature": !isRemote
                ? data["declaration"]["insuredIdentity"]["signature"]
                : "",
            "identityFront": !isRemote
                ? data["declaration"]["insuredIdentity"]["identityFront"]
                : "",
            "identityBack": !isRemote
                ? data["declaration"]["insuredIdentity"]["identityBack"]
                : ""
          };
          listOfRecipient.add(policyOwner);
          listOfRecipient.add(lifeInsured);
        } else {
          var policyOwner = {
            "role":
                "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
            "name": data["policyOwner"]["name"],
            "identitytype": data["policyOwner"]["identitytype"],
            "nric": data["policyOwner"]["nric"],
            "isRemote": isRemote,
            "signature": !isRemote
                ? data["declaration"]["ownerIdentity"]["signature"]
                : "",
            "identityFront": !isRemote
                ? data["declaration"]["ownerIdentity"]["identityFront"]
                : "",
            "identityBack": !isRemote
                ? data["declaration"]["ownerIdentity"]["identityBack"]
                : ""
          };
          listOfRecipient.add(policyOwner);
        }
      }
    }
    // Add Payor
    if (data["payor"] != null &&
        data["payor"]["whopaying"] == "othersrelation" &&
        data["payor"]["name"] != null &&
        data["payor"]["nric"] != null) {
      var payor = {
        "role": "Payor",
        "name": data["payor"]["name"],
        "identitytype": data["payor"]["identitytype"],
        "nric": data["payor"]["nric"],
        "isRemote": isRemote,
        "signature":
            !isRemote ? data["declaration"]["payorIdentity"]["signature"] : "",
        "identityFront": !isRemote
            ? data["declaration"]["payorIdentity"]["identityFront"]
            : "",
        "identityBack": !isRemote
            ? data["declaration"]["payorIdentity"]["identityBack"]
            : ""
      };
      listOfRecipient.add(payor);
    }
  }
  // Add Witness
  if (data["witness"] != null && data["witness"]["witness"] != "agent") {
    bool isRemote = data["witness"]["isSignRemote"] != null &&
        data["witness"]["isSignRemote"];
    var witness = {
      "role": "Witness",
      "name": data["witness"]["name"],
      "identitytype": data["witness"]["identitytype"],
      "nric": data["witness"]["nric"],
      "isRemote": isRemote,
      "signature": !isRemote ? data["witness"]["signature"] ?? "" : "",
      "identityFront": !isRemote ? data["witness"]["identityFront"] ?? "" : "",
      "identityBack": !isRemote ? data["witness"]["identityBack"] ?? "" : ""
    };
    listOfRecipient.add(witness);
  }

  if (data["remote"] != null) {
    var res = data["remote"]["remoteStatus"];
    if (res != null && res["ClientRemoteList"].length > 0) {
      for (var element in listOfRecipient) {
        var recipient = res["ClientRemoteList"].firstWhere(
            (remote) => (remote["IDNum"] == element["nric"] &&
                remote["ClientName"] == element["name"]),
            orElse: () => null);
        if (recipient != null) {
          element["isRemote"] = true;
          element["signature"] = recipient["signature"];
          element["identityFront"] = recipient["Front"];
          element["identityBack"] = recipient["Back"];
        }
      }
    }
  }

  for (var element in listOfRecipient) {
    if (element["signature"] != null &&
        element["identityFront"] != null &&
        element["identityBack"] != null) {
      idSignWidList.add(idSignature(element));
    }
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Captured Identity & Signature"), style: t2FontW5()),
    Column(children: idSignWidList),
    SizedBox(height: gFontSize * 2)
  ]);
}

Widget paymentSummary(data) {
  var q = data["listOfQuotation"][0];
  dynamic payor;
  if (data["payor"]["whopaying"] == "policyOwner") {
    payor = data["policyOwner"];
  } else if (data["payor"]["whopaying"] == "lifeInsured") {
    payor = data["lifeInsured"];
  } else if (data["payor"]["whopaying"] == "othersrelation") {
    payor = data["payor"];
  }
  var obj = [
    {
      "size": {"labelWidth": 35, "valueWidth": 65},
      "payorName": {"label": getLocale("Payor Name"), "value": payor["name"]},
      "payorNric": {
        "label": getLocale("Payor NRIC"),
        "value": payor["identitytype"] == "nric" ? payor["nric"] : ""
      },
      "otherId": {
        "label": getLocale("Other ID"),
        "value": payor["identitytype"] != "nric" ? payor["nric"] : ""
      },
      "proposalNo": {
        "label": getLocale("Proposal No"),
        "value": data["application"] != null
            ? data["application"]["ProposalNo"]
            : "-"
      },
      "planName": {
        "label": getLocale("Plan Name"),
        "value": q["productPlanName"]
      },
      "payMode": {
        "label": getLocale("Payment Mode"),
        "value": isNumeric(q["paymentMode"])
            ? getLocale(convertPaymentMode(q["paymentMode"]))
            : q["paymentMode"]
      },
      "payMethod": {
        "label": getLocale("Payment Method"),
        "value": data["payment"] != null && data["payment"]["payment"] != null
            ? objMapping[data["payment"]["payment"]]
            : "-"
      },
      "premium": {
        "label": getLocale("Premium Amount"),
        "value": toRM(q["basicPlanPremiumAmount"], rm: true)
      }
    }
  ];

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Payment"), style: t2FontW5()),
    CustomColumnTable(arrayObj: obj)
  ]);
}

Widget summaryAllDetails(data) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Summary of Application Submission"),
        style: t1FontW5().copyWith(color: Colors.black)),
    Text(
        getLocale(
            "Please cross-check the application details before proceed to declaration"),
        style: bFontWN().copyWith(color: greyTextColor)),
    Divider(height: gFontSize * 2, thickness: 3),
    policyOwnerDetails(data),
    lifeInsuredDetails(data),
    payorDetails(data),
    protentialArea(data),
    investmentPref(data),
    clientChoice(data),
    nomination(data),
    policyOwnerHealthQuestion(data),
    lifeInsuredHealthQuestion(data)
  ]);
}
