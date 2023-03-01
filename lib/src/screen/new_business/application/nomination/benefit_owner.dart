import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/add_info_container.dart';
import 'package:ease/src/widgets/radio_dropdown.dart';
import 'package:flutter/material.dart';

class BenefitOwner extends StatefulWidget {
  final dynamic obj;
  final Function(dynamic obj) onChanged;

  const BenefitOwner({Key? key, this.obj, required this.onChanged})
      : super(key: key);
  @override
  BenefitOwnerState createState() => BenefitOwnerState();
}

class BenefitOwnerState extends State<BenefitOwner> {
  dynamic inputList;
  dynamic benefitOwnerObj;
  dynamic noBenefitOwnerObj;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    obj = widget.obj;
    var standardObject = getGlobalInputJsonFormat();
    inputList = {
      "benefitOwner": {
        "title": getLocale("Add Beneficial Owner"),
        "subTitle": getLocale(
            "Go through the questions with your client and fill them accordingly."),
        "fields": {
          "salutation": standardObject["salutation"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "gender": standardObject["gender"],
          "dob": standardObject["dob"]
        }
      },
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
      "occupation": {
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
    inputList["benefitOwner"]["fields"]["identitytype"]["clientType"] = "99";

    setAllField(inputList["benefitOwner"]["fields"], "column", true);

    inputList["occupation"]["fields"]["occupationDisplay"]["required"] = true;
    inputList["occupation"]["fields"]["companyname"]["required"] = true;
    inputList["occupation"]["fields"]["monthlyincome"]["required"] = true;

    benefitOwnerObj = {
      "inputList": inputList,
      "checkCircle": true,
      "radioShow": false,
      "maximum": 1,
      "label": getLocale("Yes"),
      "buttonLabel": "+ ${getLocale("Add Beneficial Owner")}",
      "mainTitleKey": "name",
      "subTitleLabel": "Name",
      "infoShowKey": ["nric", "gender", "dob", "mobileno"],
      "info": {
        "size": {"labelWidth": 40, "valueWidth": 60},
        "naText": ""
      },
      "value": []
    };

    noBenefitOwnerObj = {
      "checkCircle": true,
      "label": getLocale("No"),
      "radioShow": false
    };

    if (obj != null && obj["person"] != null && !obj["person"].isEmpty) {
      benefitOwnerObj["value"] = obj["person"];
    }

    if (!benefitOwnerObj["value"].isEmpty) {
      benefitOwnerObj["radioShow"] = true;
    } else if (obj != null && obj["person"] == "") {
      benefitOwnerObj["radioShow"] = false;
      noBenefitOwnerObj["radioShow"] = true;
    } else {
      benefitOwnerObj["radioShow"] = false;
      noBenefitOwnerObj["radioShow"] = true;
    }

    if (obj == null || obj["person"] == null || obj["person"].isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onChanged({"person": ""}));
    }
  }

  void setAllField(o, field, value) {
    for (var key in o.keys) {
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

  @override
  Widget build(BuildContext context) {
    setAllField(inputList["benefitOwner"]["fields"], "column", true);
    Widget benefitOwnerRadio() {
      return AddInfoContainer(
          obj: benefitOwnerObj,
          onChanged: (object) {
            obj = {"person": benefitOwnerObj["value"]};
            widget.onChanged(obj);
            if (object != null && object["onRadioChanged"] != null) {
              var enabled = object["onRadioChanged"];
              benefitOwnerObj["radioShow"] = enabled;
              noBenefitOwnerObj["radioShow"] = !enabled;
              setState(() {});
            }
          });
    }

    Widget noBenefitOwnerRadio() {
      return RadioDropdown(
          obj: noBenefitOwnerObj,
          disableDividerTop: true,
          onChanged: (enabled) {
            setState(() {
              noBenefitOwnerObj["radioShow"] = enabled;
              benefitOwnerObj["radioShow"] = !enabled;
              if (enabled) {
                obj = {"person": ""};
                benefitOwnerObj["value"] = "";
              } else {
                obj = {"person": []};
                benefitOwnerObj["value"] = [];
              }
            });
            widget.onChanged(obj);
          });
    }

    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Beneficial Owner"), style: t1FontW5()),
          SizedBox(height: gFontSize * 2),
          Text(getLocale("What is a Beneficial Owner?"), style: bFontWN()),
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: gFontSize, horizontal: gFontSize * 0.8),
              child: Text(
                  "1. ${getLocale("On whose behalf this transaction is being conducted, or")}\n2. ${getLocale("Ultimately controls the policy / beneficiary, or")}\n3. ${getLocale("Ultimately will benefit or receive the money arising from the payout to the beneficiary")}",
                  style: bFontWN())),
          Container(
              padding: EdgeInsets.symmetric(vertical: gFontSize),
              child: Text(
                  getLocale("Is there a Beneficial Owner in this proposal?"),
                  style: t2FontWN().copyWith(color: greyTextColor))),
          benefitOwnerRadio(),
          noBenefitOwnerRadio(),
        ]));
  }
}
