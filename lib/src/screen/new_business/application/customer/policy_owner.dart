import 'dart:convert';

import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/occupation_search/occupation_search.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/customer/widget.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:flutter/material.dart';

class PolicyOwner extends StatefulWidget {
  final String? buyingFor;
  final dynamic obj;
  final Function(dynamic obj) onChanged;

  const PolicyOwner(
      {Key? key, required this.buyingFor, required this.onChanged, this.obj})
      : super(key: key);

  @override
  PolicyOwnerState createState() => PolicyOwnerState();
}

class PolicyOwnerState extends State<PolicyOwner> {
  var obj = {};
  dynamic widList;
  dynamic inputList;

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) obj = widget.obj;
    var standardObject = getGlobalInputJsonFormat();
    inputList = {
      "policyowner": {
        "title": getLocale("Policy Owner's Details", entity: true),
        "subTitle": getLocale(
            "Go through the questions with your client and fill them accordingly."),
        "mainTitle": true,
        "fields": {
          "relationshipSpouse": standardObject["relationshipSpouse"],
          "relationshipChild": standardObject["relationshipChild"],
          "salutation": standardObject["salutation"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "gender": standardObject["gender"],
          "dob": standardObject["dob"],
          "race": standardObject["race"],
          "muslim": standardObject["muslim"],
          "maritalstatus": standardObject["maritalstatus"],
          "preferlanguage": standardObject["preferlanguage"],
          "smoking": standardObject["smoking"]
        }
      },
      "fatca": standardObject["fatca"],
      "crs": standardObject["crs"],
      "contactdetails": {
        "title": getLocale("Contact Details"),
        "mainTitle": false,
        "fields": {
          "address": standardObject["address"],
          "address1": standardObject["address1"],
          "postcode": standardObject["postcode"],
          "city": standardObject["city"],
          "state": standardObject["state"],
          "country": standardObject["country"],
          "mailing": standardObject["mailing"],
          "hometel": standardObject["hometel"],
          "officetel": standardObject["officetel"],
          "mobileno": standardObject["mobileno"],
          "mobileno2": standardObject["mobileno2"],
          "email": standardObject["email"]
        }
      },
      "occupationdetails": {
        "title": getLocale("Employment Status"),
        "mainTitle": false,
        "fields": {
          "occupationDisplay": standardObject["occupation"],
          "parttime": standardObject["parttime"],
          "natureofbusiness": standardObject["natureofbusiness"],
          "companyname": standardObject["companyname"],
          "monthlyincome": standardObject["monthlyincome"]
        }
      },
      "sourceoffunds": {
        "title": getLocale("Source of Fund/Wealth"),
        "mainTitle": false,
        "fields": {"sourceoffund": standardObject["sourceoffund"]}
      },
      "creditbank": {
        "title": getLocale("Auto Credit Bank Details"),
        "mainTitle": false,
        "fields": {
          "bankname": standardObject["bankname"],
          "bankaccounttype": standardObject["bankaccounttype"],
          "accountno": standardObject["accountno"],
          "creditterminfo": standardObject["creditterminfo"]
        }
      }
    };
    inputList["policyowner"]["fields"]["identitytype"]["clientType"] = "1";

    inputList["contactdetails"]["fields"]["country"]["enabled"] = false;

    setAllField(inputList["fatca"]["fields"], "required", false);
    setAllField(inputList["crs"]["fields"], "required", false);
    if (widget.obj != null &&
        (widget.obj["countryofbirth"] != null ||
            widget.obj["nationality"] != null)) {
      if (widget.obj["countryofbirth"] == "USA" ||
          widget.obj["nationality"] == "8") {
        inputList["fatca"]["enabled"] = true;
        setAllField(inputList["fatca"]["fields"], "required", true);
      }
      if (!inputList["fatca"]["enabled"] &&
          ((widget.obj["countryofbirth"] != "USA" &&
                  widget.obj["countryofbirth"] != "MYS") ||
              (widget.obj["nationality"] != "8" &&
                  widget.obj["nationality"] != "458"))) {
        inputList["crs"]["enabled"] = true;
        setAllField(inputList["crs"]["fields"], "required", true);
      }
    }

    if (obj["nric"] != null &&
        obj["nric"].isNotEmpty &&
        obj["identitytype"] == null) {
      obj["identitytype"] = "nric";
    }

    if (obj["MaritalStatus"] != null && obj["MaritalStatus"].isNotEmpty) {
      obj["maritalstatus"] = obj["MaritalStatus"];
    }

    if (obj["Contact"] != null && obj["Contact"].isNotEmpty) {
      var addressJson = json.decode(obj["Contact"]);
      obj["address"] = addressJson["Adr1"];
      obj["address1"] = addressJson["Adr2"];
      obj["postcode"] = addressJson["PinCode"];
      obj["city"] = addressJson["City"];
      obj["state"] = addressJson["State"];
    }

    if (obj["MobileNum"] != null && obj["MobileNum"].isNotEmpty) {
      obj["mobileno"] = obj["MobileNum"];
    }

    if (obj["MobileNum2"] != null && obj["MobileNum2"].isNotEmpty) {
      obj["mobileno2"] = obj["MobileNum2"];
    }

    if (obj["HomeNum"] != null && obj["HomeNum"].isNotEmpty) {
      obj["hometel"] = obj["HomeNum"];
    }

    if (obj["BizNum"] != null && obj["BizNum"].isNotEmpty) {
      obj["officetel"] = obj["BizNum"];
    }

    if (obj["Email"] != null && obj["Email"].isNotEmpty) {
      obj["email"] = obj["Email"];
    }

    if (obj["MonthlyIncome"] != null && obj["MonthlyIncome"] != 0) {
      obj["monthlyincome"] = obj["MonthlyIncome"].toString();
    }

    if (obj["NameOfEmployer"] != null && obj["NameOfEmployer"].isNotEmpty) {
      obj["companyname"] = obj["NameOfEmployer"];
    }

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
    if (widget.buyingFor == "self") {
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          false;
    } else if (widget.buyingFor == "children") {
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] = true;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          true;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          false;
    } else {
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          true;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          false;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          true;
    }
    var result = getInputedData(inputList);
    extraParam(result, context, obj, "po", onAmlaChanged);
    obj = result;
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(obj));
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

  void setAllField(o, field, value) {
    for (var key in o.keys) {
      if (o[key]["enabled"] != null && !o[key]["enabled"]) {
        continue;
      }
      if (o[key]["options"] != null) {
        o[key][field] = value;
        for (var i = 0; i < o[key]["options"].length; i++) {
          if (o[key]["options"][i] is! Map) {
            continue;
          }
          if (o[key]["options"][i]["option_fields"] != null) {
            setAllField(o[key]["options"][i]["option_fields"], field, value);
          }
        }
      } else {
        o[key][field] = value;
      }
    }
  }

  void onDataChanged(result) async {
    setState(() {
      if (result["countryofbirth"] == "USA" || result["nationality"] == "8") {
        inputList["fatca"]["enabled"] = true;
        setAllField(inputList["fatca"]["fields"], "required", true);
        var isUSCitizen = getObjectByKey(inputList, "isUSCitizen");
        var greenCardHolder = getObjectByKey(inputList, "greenCardHolder");
        var isUSResident = getObjectByKey(inputList, "isUSResident");
        var fatcaStatus = getObjectByKey(inputList, "fatcaStatus");
        var taxIdOrSecurityNo = getObjectByKey(inputList, "taxIdOrSecurityNo");
        if (!isUSCitizen["value"] &&
            !greenCardHolder["value"] &&
            !isUSResident["value"]) {
          fatcaStatus["value"] = "nonUSPerson";
        } else if (isUSCitizen["value"] ||
            greenCardHolder["value"] ||
            isUSResident["value"]) {
          if (taxIdOrSecurityNo["value"] == "notdiscloseUS") {
            fatcaStatus["value"] = "recalcitrant";
          } else {
            fatcaStatus["value"] = "USPerson";
          }
        }
      } else {
        inputList["fatca"]["enabled"] = false;
        setAllField(inputList["fatca"]["fields"], "required", false);
      }

      if (!inputList["fatca"]["enabled"] &&
              (result["countryofbirth"] != "USA" &&
                  result["countryofbirth"] != "MYS") ||
          (result["nationality"] != "8" && result["nationality"] != "458")) {
        inputList["crs"]["enabled"] = true;
        setAllField(inputList["crs"]["fields"], "required", true);
      } else {
        inputList["crs"]["enabled"] = false;
        setAllField(inputList["crs"]["fields"], "required", false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buyingFor == "self") {
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          false;
    } else if (widget.buyingFor == "children") {
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] = true;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          true;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          false;

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

      if (widget.buyingFor == "children") {
        if (childRelationList.indexWhere((element) =>
                element["value"] ==
                inputList["policyowner"]["fields"]["relationshipChild"]
                    ["value"]) ==
            -1) {
          inputList["policyowner"]["fields"]["relationshipChild"]["value"] = "";
        }
        inputList["policyowner"]["fields"]["relationshipChild"]["options"] =
            childRelationList;
      }
    } else if (widget.buyingFor == "spouse") {
      inputList["policyowner"]["fields"]["relationshipSpouse"]["enabled"] =
          true;
      inputList["policyowner"]["fields"]["relationshipChild"]["enabled"] =
          false;
      inputList["policyowner"]["fields"]["relationshipSpouse"]["required"] =
          true;
      inputList["policyowner"]["fields"]["relationshipChild"]["required"] =
          false;

      var spouseRelationList = [];

      var gender = getObjectByKey(inputList, "gender");
      var relationshipList = getMasterlookup(type: "Relationship");
      relationshipList.forEach((option) {
        if (option["remark"] != null) {
          dynamic remark = jsonDecode(option["remark"]);

          if (remark["BuyFor"] == "Spouse") {
            if (gender != null && gender["value"] != "") {
              if (remark["gender"] == "E" ||
                  remark["gender"] == gender["value"][0].toUpperCase()) {
                spouseRelationList.add(option);
              }
            } else {
              spouseRelationList.add(option);
            }
          }
        }
      });

      if (widget.buyingFor == "spouse") {
        if (spouseRelationList.indexWhere((element) =>
                element["value"] ==
                inputList["policyowner"]["fields"]["relationshipSpouse"]
                    ["value"]) ==
            -1) {
          inputList["policyowner"]["fields"]["relationshipSpouse"]["value"] =
              "";
        }
        inputList["policyowner"]["fields"]["relationshipSpouse"]["options"] =
            spouseRelationList;
      }
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
      extraParam(result, context, obj, "po", onAmlaChanged);

      bool isBlock = await checkIfCountryBlock(result['nationality'] ?? "");

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

        onDataChanged(result);
        obj = result;
        widget.onChanged(obj);
      });
    });

    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize,
            bottom: gFontSize * 2.5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: generateContent(widList, inputList)));
  }
}
