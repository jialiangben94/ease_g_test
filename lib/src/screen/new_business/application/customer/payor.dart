import 'dart:convert';

import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/customer/widget.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/occupation_search/occupation_search.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';

import 'package:flutter/material.dart';

class Payor extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;
  final String? buyingFor;

  const Payor(
      {Key? key,
      required this.buyingFor,
      required this.onChanged,
      this.obj,
      this.info})
      : super(key: key);
  @override
  PayorState createState() => PayorState();
}

class PayorState extends State<Payor> {
  dynamic widList;
  dynamic inputList;
  dynamic obj = {};

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) obj = widget.obj;

    var standardObject = getGlobalInputJsonFormat();
    inputList = {
      "payordetails": {
        "title": getLocale("Payor's Details"),
        "fields": {
          "whopaying": standardObject["whopaying"],
        }
      },
      "contactdetails": {
        "title": getLocale("Contact Details"),
        "fields": {
          "sameasparent": standardObject['sameasparent'],
          "mobileno": standardObject["mobileno"],
          "mobileno2": standardObject["mobileno2"],
          "email": standardObject["email"]
        }
      },
      "occupationdetails": {
        "title": getLocale("Employment Status"),
        "fields": {
          "occupationDisplay": standardObject["occupation"],
          "parttime": standardObject["parttime"],
          "natureofbusiness": standardObject["natureofbusiness"],
          "companyname": standardObject["companyname"],
          "monthlyincome": standardObject["monthlyincome"]
        }
      }
    };
    inputList["payordetails"]["fields"]["whopaying"]["options"][3]
        ["option_fields"]["identitytype"]["clientType"] = "7";
    inputList["payordetails"]["fields"]["whopaying"]["options"][3]
            ["option_fields"]["identitytype"]["options"]
        .forEach((id) {
      id["option_fields"].remove("countryofbirth");
    });

    generateDataToObjectValue(obj, inputList);

    var occupation = getObjectByKey(inputList, "occupationDisplay");
    if (obj["occupation"] != null) {
      var occJson = json.decode(obj["occupation"]);
      occupation["value"] = occJson["OccupationName"];
      if (occJson["Remarks"] == '{"mandatory":"false"}') {
        inputList["occupationdetails"]["fields"]["companyname"]["required"] =
            false;
        inputList["occupationdetails"]["fields"]["monthlyincome"]["required"] =
            false;
      } else {
        inputList["occupationdetails"]["fields"]["companyname"]["required"] =
            true;
        inputList["occupationdetails"]["fields"]["monthlyincome"]["required"] =
            true;
      }
    }

    occupation["onTap"] = () async {
      int? age;
      var dob = getObjectByKey(inputList, "dob");
      if (dob != null && dob["value"] != null && dob["value"] != "") {
        DateTime date = DateTime.fromMicrosecondsSinceEpoch(dob["value"]);
        age = getAge(date);
      }
      final tmpOcc = await Navigator.of(context)
          .push(createRoute(ChooseOccupation(age: age)));
      if (tmpOcc != null) {
        setState(() {
          occupation["value"] = tmpOcc.occupationName;

          if (tmpOcc.remarks == '{"mandatory":"false"}') {
            inputList["occupationdetails"]["fields"]["companyname"]
                ["required"] = false;
            inputList["occupationdetails"]["fields"]["monthlyincome"]
                ["required"] = false;
          } else {
            inputList["occupationdetails"]["fields"]["companyname"]
                ["required"] = true;
            inputList["occupationdetails"]["fields"]["monthlyincome"]
                ["required"] = true;
          }

          var result = getInputedData(inputList);
          var v = inputList["payordetails"]["fields"]["whopaying"]["value"];
          if (v != "policyOwner" &&
              v != "lifeInsured" &&
              v != "poli" &&
              v != "") {
            extraParam(result, context, obj, "payor", onAmlaChanged);
          }
          obj = result;
          obj["occupation"] = json.encode(tmpOcc);
          widget.onChanged(obj);
        });
      }
    };

    var parttime = getObjectByKey(inputList, "parttime");
    if (obj["parttime"] != null && obj["parttime"] != "") {
      parttime["value"] = obj["parttime"];
    }

    parttime["onTap"] = () async {
      int? age;
      var dob = getObjectByKey(inputList, "dob");
      if (dob != null && dob["value"] != null && dob["value"] != "") {
        DateTime date = DateTime.fromMicrosecondsSinceEpoch(dob["value"]);
        age = getAge(date);
      }
      final tmpOcc = await Navigator.of(context)
          .push(createRoute(ChooseOccupation(age: age)));
      if (tmpOcc != null) {
        setState(() {
          parttime["value"] = tmpOcc.occupationName;
          var result = getInputedData(inputList);
          var v = inputList["payordetails"]["fields"]["whopaying"]["value"];
          if (v != "policyOwner" &&
              v != "lifeInsured" &&
              v != "poli" &&
              v != "") {
            extraParam(result, context, obj, "payor", onAmlaChanged);
          }
          obj = result;
          obj["parttimeOcc"] = json.encode(tmpOcc);
          widget.onChanged(obj);
        });
      }
    };

    var gender = getObjectByKey(inputList, "gender");
    var salutation = getObjectByKey(inputList, "salutation");
    if (gender != null && gender["value"] != "" && salutation != null) {
      salutation["options"] = getMasterlookup(
          type: "Salutation", remark: ["E", gender["value"][0].toUpperCase()]);
    }
  }

  void onAmlaChanged(data, [message]) {
    obj["amlaChecked"] = data["amlaChecked"];
    obj["amlaPass"] = data["amlaPass"];
    widget.onChanged(obj);
    if (obj["amlaPass"] == false && message != null) {
      showAlertDialog(context, "Oops, there seems to be an issue.", message,
          () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
      });
    }
  }

  void checkCurrent() {
    var v = inputList["payordetails"]["fields"]["whopaying"]["value"];
    if (v != "policyOwner" && v != "lifeInsured" && v != "poli" && v != "") {
      for (var key in inputList["contactdetails"]["fields"].keys) {
        inputList["contactdetails"]["fields"][key]["enabled"] = true;
      }
      for (var key in inputList["occupationdetails"]["fields"].keys) {
        inputList["occupationdetails"]["fields"][key]["enabled"] = true;
      }
    } else {
      for (var key in inputList["contactdetails"]["fields"].keys) {
        inputList["contactdetails"]["fields"][key]["enabled"] = false;
      }
      for (var key in inputList["occupationdetails"]["fields"].keys) {
        inputList["occupationdetails"]["fields"][key]["enabled"] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.info["policyOwner"] != null &&
        widget.info["policyOwner"]["sourceoffund"] != null &&
        widget.info["policyOwner"]["sourceoffund"] == "8a") {
      var v = inputList["payordetails"]["fields"]["whopaying"]["options"];

      inputList["payordetails"]["fields"]["whopaying"]["value"] ==
          "othersrelation";
      for (var i = 0; i < v.length; i++) {
        if (v[i]["value"] == "policyOwner" || v[i]["value"] == "lifeInsured") {
          v[i]["active"] = false;
        }
      }
    } else {
      var v = inputList["payordetails"]["fields"]["whopaying"]["options"];

      int option1 = 0;
      int option2 = 1;
      int option3 = 2;

      if (widget.buyingFor == 'self') {
        v[option1]["active"] = true;
        v[option2]["active"] = false;
        v[option3]["active"] = false;
      } else {
        v[option1]["active"] = false;
        v[option2]["active"] = true;
        v[option3]["active"] = true;
      }
    }

    var payorRelationList = [];
    var gender = getObjectByKey(inputList, "gender");
    var salutation = getObjectByKey(inputList, "salutation");
    if (gender != null && gender["value"] != "" && salutation != null) {
      salutation["options"] = getMasterlookup(
          type: "Salutation", remark: ["E", gender["value"][0].toUpperCase()]);
    }
    var relationshipList = getMasterlookup(type: "Relationship");
    relationshipList.forEach((option) {
      if (option["remark"] != null) {
        dynamic remark = jsonDecode(option["remark"]);
        if (remark["type"] == "payor") {
          if (gender != null && gender["value"] != "") {
            if (remark["gender"] == "E" ||
                remark["gender"] == gender["value"][0].toUpperCase()) {
              payorRelationList.add(option);
            }
          } else {
            payorRelationList.add(option);
          }
        }
      }
    });
    if (payorRelationList.indexWhere((element) =>
            element["value"] ==
            inputList["payordetails"]["fields"]["whopaying"]["options"][3]
                ["option_fields"]["relationship"]["value"]) ==
        -1) {
      inputList["payordetails"]["fields"]["whopaying"]["options"][3]
          ["option_fields"]["relationship"]["value"] = "";
    }
    inputList["payordetails"]["fields"]["whopaying"]["options"][3]
        ["option_fields"]["relationship"]["options"] = payorRelationList;
    // FullObj.obj = inputList;
    widList = generateInputField(context, inputList, (key) {
      setState(() {
        checkCurrent();
        var result = getInputedData(inputList);
        var v = inputList["payordetails"]["fields"]["whopaying"]["value"];
        if (v != "policyOwner" &&
            v != "lifeInsured" &&
            v != "poli" &&
            v != "") {
          extraParam(result, context, obj, "payor", onAmlaChanged);
        }
        obj = result;
        widget.onChanged(obj);
      });
    });

    dynamic buildextra() {
      var inWidList = [];
      var v = inputList["payordetails"]["fields"]["whopaying"]["value"];
      if (v != "policyOwner" && v != "lifeInsured" && v != "poli" && v != "") {
        inWidList.add(Text(inputList["contactdetails"]["title"],
            style: t2FontW5().copyWith(color: cyanColor)));
        inWidList
            .add(SizedBox(height: MediaQuery.of(context).size.height * 0.03));
        for (var wid in widList["contactdetails"]) {
          inWidList.add(wid["widget"]);
        }
        inWidList
            .add(SizedBox(height: MediaQuery.of(context).size.height * 0.08));

        inWidList.add(Text(inputList["occupationdetails"]["title"],
            style: t2FontW5().copyWith(color: cyanColor)));
        inWidList
            .add(SizedBox(height: MediaQuery.of(context).size.height * 0.03));
        for (var wid in widList["occupationdetails"]) {
          inWidList.add(wid["widget"]);
        }
        inWidList
            .add(SizedBox(height: MediaQuery.of(context).size.height * 0.08));
      }
      return inWidList;
    }

    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(inputList["payordetails"]["title"], style: t1FontW5()),
          SizedBox(height: screenHeight * 0.03),
          for (var wid in widList["payordetails"]) wid["widget"],
          SizedBox(height: screenHeight * 0.08),
          ...buildextra(),
          SizedBox(height: screenHeight * 0.03)
        ]));
  }
}
