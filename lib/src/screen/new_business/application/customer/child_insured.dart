import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/occupation_search/occupation_search.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/customer/widget.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';

import 'package:flutter/material.dart';
import 'dart:convert';

class ChildInsured extends StatefulWidget {
  final String? buyingFor;
  final dynamic obj;
  final Function(dynamic obj) onChanged;
  const ChildInsured(
      {Key? key, required this.onChanged, this.obj, this.buyingFor})
      : super(key: key);
  @override
  ChildInsuredState createState() => ChildInsuredState();
}

class ChildInsuredState extends State<ChildInsured> {
  dynamic obj = {};
  dynamic widList;
  dynamic inputList;

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) obj = widget.obj;
    var standardObject = getGlobalInputJsonFormat();

    inputList = {
      "lifeInsured": {
        "title": getLocale("Life Insured's Details", entity: true),
        "subTitle": getLocale(
            "Go through the questions with your client and fill them accordingly."),
        "fields": {
          "salutation": standardObject["salutation"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "gender": standardObject["gender"],
          "dob": standardObject["dob"],
          "race": standardObject["race"],
          "muslim": standardObject["muslim"],
          "maritalstatus": standardObject["maritalstatus"],
          "preferlanguage": standardObject["preferlanguage"],
          "smoking": standardObject["smoking"],
          "studying": standardObject["studying"]
        }
      },
      "contactdetails": {
        "title": getLocale("Contact Details"),
        "fields": {
          "sameasparent": standardObject["sameasparent"],
          "hometel": standardObject["hometel"],
          "officetel": standardObject["officetel"],
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
    inputList["lifeInsured"]["fields"]["identitytype"]["clientType"] = "2";

    generateDataToObjectValue(obj, inputList);
    var occupation = getObjectByKey(inputList, "occupationDisplay");

    // Checking remarks
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
          extraParam(result, context, obj, "po", onAmlaChanged);
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
          extraParam(result, context, obj, "po", onAmlaChanged);
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
      showAlertDialog(
          context, getLocale("Oops, there seems to be an issue."), message, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buyingFor == "spouse") {
      inputList["lifeInsured"]["fields"]["studying"]["enabled"] = false;
      inputList["lifeInsured"]["fields"]["identitytype"]["options"]
          .forEach((options) {
        if (options["value"] == "birthcert") {
          options["active"] = false;
        }
      });
    } else if (widget.buyingFor == "children") {
      inputList["lifeInsured"]["fields"]["studying"]["enabled"] = true;
      inputList["lifeInsured"]["fields"]["identitytype"]["options"]
          .forEach((options) {
        if (options["value"] == "birthcert") {
          options["active"] = true;
        }
      });
    }

    widList = generateInputField(context, inputList, (key) async {
      setState(() {
        var gender = getObjectByKey(inputList, "gender");
        var salutation = getObjectByKey(inputList, "salutation");
        if (gender != null && gender["value"] != "" && salutation != null) {
          salutation["options"] = getMasterlookup(
              type: "Salutation",
              remark: ["E", gender["value"][0].toUpperCase()]);
        }

        var occupation = getObjectByKey(inputList, "occupationDisplay");
        if (obj["occupation"] != null) {
          var occJson = json.decode(obj["occupation"]);
          occupation["value"] = occJson["OccupationName"];
          if (occJson["Remarks"] == '{"mandatory":"false"}') {
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
        }
      });

      var result = getInputedData(inputList);
      extraParam(result, context, obj, "li", onAmlaChanged);

      bool isBlock = result['nationality'] != null
          ? await checkIfCountryBlock(result['nationality'])
          : false;
      setState(() {
        if (isBlock) {
          // if block, then we show dialog
          // remove the data and set default.
          showAlertDialog(
              context,
              getLocale('Sorry'),
              getLocale(
                  'The nationality selected are not allowed to buy from this plan'));

          var identitytype = getObjectByKey(inputList, 'identitytype');
          var options = identitytype["options"].firstWhere(
              (element) => element["value"] == identitytype["value"]);
          options["option_fields"]["nationality"]["value"] = "458";
          result["nationality"] = "458";
        }

        obj = result;
        widget.onChanged(obj);
      });
    });

    dynamic buildextra() {
      var inWidList = [];
      for (var wid in widList["occupationdetails"]) {
        inWidList.add(wid["widget"]);
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
          Text(inputList["lifeInsured"]["title"], style: t1FontW5()),
          Text(inputList["lifeInsured"]["subTitle"],
              style: sFontWN().copyWith(color: greyTextColor)),
          SizedBox(height: gFontSize * 1.5),
          for (var wid in widList["lifeInsured"]) wid["widget"],
          SizedBox(height: gFontSize * 3),
          Text(inputList["contactdetails"]["title"],
              style: t2FontW5().copyWith(color: cyanColor)),
          SizedBox(height: gFontSize * 1.5),
          for (var wid in widList["contactdetails"]) wid["widget"],
          SizedBox(height: gFontSize * 3),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(inputList["occupationdetails"]["title"],
                style: t2FontW5().copyWith(color: cyanColor))
          ]),
          SizedBox(height: gFontSize * 1.5),
          ...buildextra(),
          SizedBox(height: gFontSize * 1.5)
        ]));
  }
}
