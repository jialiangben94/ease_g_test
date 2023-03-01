import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/add_info_container.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';

class Nomination extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;

  const Nomination({Key? key, this.obj, this.info, required this.onChanged})
      : super(key: key);
  @override
  NominationState createState() => NominationState();
}

class NominationState extends State<Nomination> {
  late dynamic inputList;
  dynamic inputList2;
  dynamic inputList3;
  late dynamic widList;
  dynamic nominateObj;
  dynamic trusteeObj;
  late dynamic validateTrustee;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    validateTrustee = hideTrustee(widget.info);
    obj = widget.obj;
    var othersRule = """
<table>
<colgroup><col width="4%" /><col width="3%" /><col width="93%" /></colgroup>
  <tr><td></td><td>&#8226;</td><td>${getLocale("Nomination is not allowed for policies affected by the")} ${getLocale("Policy Owner", entity: true)} ${getLocale("upon the life of another person.")}</td></tr>
  <tr><td></td><td>&#8226;</td><td>${getLocale("Submission of a copy of the Nominee(s) NRIC/Passport/Birth Certificate is/are encouraged.")}</td></tr>
  <tr><td></td><td>&#8226;</td><td>${getLocale("If there are more than 3 Nominee(s), please submit an additional form.")}</td></tr>
  <tr><td></td><td>&#8226;</td><td>${getLocale("The latest submission to Etiqa Insurance and endorsement of a nomination by Etiqa Insurance will supersede any previous nomination made.")}</td></tr>
  <tr><td></td><td>&#8226;</td><td>${getLocale("Please inform your Nominee(s) about the nomination pursuant to this application.")}</td></tr>
</table>
""";
    var notes = """
<table>
<colgroup><col width="3%" /><col width="92%" /></colgroup>
  <tr><td>1</td><td>(a) ${getLocale("A Trust in favour of the Nominee(s) is created under Section 130 of the Financial Services Act 2013 (Schedule 10), if the Nominee(s) of the")} ${getLocale("Policy Owner", entity: true)} (${getLocale("other than a Muslim")} ${getLocale("Policy Owner", entity: true)} ${getLocale("Special Translation for /lib/src/screen/new_business/application/nomination/nomination.dart")}) ${getLocale("falls into one or more of the following categories:")}<br><br>i. ${getLocale("Spouse")} <br>ii. ${getLocale("Child")} <br>iii. ${getLocale("Parent (where there is no spouse or child living at the time of making this nomination")})<br><br>(b) ${getLocale("Policy Owner", entity: true)} ${getLocale("may appoint any person, other than himself/herself, to be the Trustee for the Policy moneys by completing the details for the Trustee")}.<br><br>(c) ${getLocale("In the event that the")} ${getLocale("Policy Owner", entity: true)} ${getLocale("does not appoint a Trustee, the competent Nominee(s) or where the Nominee(s) other than the")} ${getLocale("Policy Owner", entity: true)} ${getLocale("and where there is no surviving parent, the Public Trustee, shall be the Trustee. If there is more than one Nominee who is competent to contract, the Nominee(s) shall be joint Trustees")}.<br></td></tr>
  <tr><td>2</td><td>${getLocale("A nomination by a Muslim")} ${getLocale("Policy Owner", entity: true)} ${getLocale("shall not create a Trust in favour for the Nominee(s) of the Policy moneys payable upon death of such Muslim")} ${getLocale("Policy Owner", entity: true)}. ${getLocale("Nominee(s) of a Muslim")} ${getLocale("Policy Owner", entity: true)}, ${getLocale("upon receipt of the Policy moneys, shall distribute the Policy moneys in accordance with Islamic Laws")}.<br></td></tr>
  <tr><td>3</td><td>${getLocale("For Nominee(s) other than those described in item no. 1(a) above, the Nominee(s) shall receive the Policy moneys in the capacity as an executor and not solely as a beneficiary. If the")} ${getLocale("Policy Owner", entity: true)}${getLocale("’s intention is for such Nominee(s) to receive the Policy moneys beneficially and not as an executor, the")} ${getLocale("Policy Owner", entity: true)} ${getLocale("must assign the Policy moneys to such person by completing the assignment form")}.<br></td></tr>
  <tr><td>4</td><td>${getLocale("In a Trust (under Section B below), you cannot revoke your nomination, vary or surrender the Policy or assign or pledge the Policy as security, without the written consent of the Trustee(s). The")} ${getLocale("Policy Owner", entity: true)} ${getLocale("reserves the right to revoke the appointment of the Trustee(s) and substitute any other person thereof or to appoint additional Trustee(s). The receipt of the Policy moneys by the Trustee(s) shall be a discharge to Etiqa insurance of all their liabilities under the Policy")}. <br><br>${getLocale("Note: You are advised to provide details of the Nominee(s) and ensure that the Nominee(s) is/are aware of the Life Insurance Policy that you have purchased. Having a valid nomination on the Policy will expedite the payment of the Policy moneys as we will pay the Policy moneys directly to the Nominee(s) in the proportion that you have indicated in the nomination section")}.<br></td></tr>
</table>
""";

    inputList = {
      "nomination": {
        "fields": {
          "importantNote": {"type": "info2", "text": notes},
          "nominee": {"value": []},
          "trustee": {"value": []},
          "otherRules": {
            "type": "info",
            "label": getLocale("Other Rules and Tips"),
            "show": false,
            "required": false,
            "style": {
              "html": Style(fontSize: FontSize(font16()), color: greyTextColor),
              "td": Style(padding: EdgeInsets.only(bottom: gFontSize * 0.5)),
            },
            "text": othersRule
          }
        }
      }
    };

    var standardObject = getGlobalInputJsonFormat();
    inputList2 = {
      "nominee": {
        "title": getLocale("Add Nominee"),
        "subTitle": getLocale(
            "Go through the questions with your client and fill them accordingly."),
        "fields": {
          "relationship": standardObject["relationshipPO"],
          "salutation": standardObject["salutation"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "gender": standardObject["gender"],
          "dob": standardObject["dob"],
          "percentage": standardObject["percentage"]
        }
      },
      "contactdetails": {
        "title": getLocale("Contact Details"),
        "mainTitle": false,
        "fields": {
          "sameaspo": standardObject['sameaspo'],
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
      },
      "bankaccount": {
        "title": getLocale("Bank Details (Optional)"),
        "fields": {
          "bankname": standardObject["bankname"],
          "bankaccounttype": standardObject["bankaccounttype"],
          "accountno": standardObject["accountno"]
        }
      }
    };

    setAllField(inputList2["nominee"]["fields"], "column", true);
    setAllField(inputList2["occupation"]["fields"], "column", true);
    setAllField(inputList2["occupation"]["fields"], "required", false);
    setAllField(inputList2["bankaccount"]["fields"], "column", true);
    setAllField(inputList2["bankaccount"]["fields"], "required", false);
    inputList2["nominee"]["fields"]["identitytype"]["clientType"] = "4";
    inputList2["nominee"]["fields"]["identitytype"]["options"]
        .forEach((options) {
      if (options["value"] == "birthcert") {
        options["active"] = true;
      }
    });
    inputList2["contactdetails"]["fields"]["email"]["required"] = false;

    nominateObj = {
      "inputList": inputList2,
      "checkCircle": true,
      "radioShow": false,
      "label": "${getLocale("Nominee")}(s)",
      "buttonLabel": "+ ${getLocale("Add Nominee")}",
      "mainTitleKey": "name",
      "subTitleKey": "relationship",
      "infoShowKey": ["identitytype", "gender", "dob", "percentage"],
      "info": {
        "size": {"labelWidth": 40, "valueWidth": 60},
        "naText": ""
      }
    };

    var standardObject2 = getGlobalInputJsonFormat();
    inputList3 = {
      "trustee": {
        "title": getLocale("Add Trustee"),
        "subTitle": getLocale(
            "Go through the questions with your client and fill them accordingly."),
        "fields": {
          "salutation": standardObject2["salutation"],
          "name": standardObject2["name"],
          "identitytype": standardObject2["identitytype"],
          "dob": standardObject2["dob"],
          "gender": standardObject2["gender"]
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
          "occupationDisplay": standardObject2["occupation"],
          "parttime": standardObject2["parttime"],
          "natureofbusiness": standardObject2["natureofbusiness"],
          "companyname": standardObject2["companyname"],
          "monthlyincome": standardObject2["monthlyincome"]
        }
      },
      "bankaccount": {
        "title": getLocale("Bank Details (Optional)"),
        "fields": {
          "bankname": standardObject2["bankname"],
          "bankaccounttype": standardObject2["bankaccounttype"],
          "accountno": standardObject2["accountno"]
        }
      }
    };

    setAllField(inputList3["trustee"]["fields"], "column", true);
    setAllField(inputList3["occupation"]["fields"], "column", true);
    setAllField(inputList3["bankaccount"]["fields"], "column", true);
    setAllField(inputList3["bankaccount"]["fields"], "required", false);
    inputList3["trustee"]["fields"]["identitytype"]["clientType"] = "6";

    trusteeObj = {
      "inputList": inputList3,
      "checkCircle": true,
      "disableDividerTop": true,
      "radioShow": false,
      "label": "${getLocale("Trustee")}(s)",
      "buttonLabel": "+ ${getLocale("Add Trustee")}(s)",
      "mainTitleKey": "name",
      "subTitleLabel": "Name",
      "infoShowKey": ["nric", "gender", "dob", "mobileno"],
      "info": {
        "size": {"labelWidth": 40, "valueWidth": 60},
        "naText": ""
      }
    };

    if (obj != null && obj["nominee"] != null && obj["nominee"].isNotEmpty) {
      nominateObj["value"] = obj["nominee"];
      nominateObj["radioShow"] = true;
      if (obj != null && obj["trustee"] != null && obj["trustee"].isNotEmpty) {
        trusteeObj["value"] = obj["trustee"];
        trusteeObj["radioShow"] = true;
      } else {
        trusteeObj["radioShow"] = false;
      }
    } else {
      nominateObj["radioShow"] = false;
    }
    if (obj == null || obj["nominee"].isEmpty) {
      if (validateTrustee["hideTrustee"]) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => widget.onChanged({"nominee": ""}));
      } else {
        if (obj != null) {
          if (obj["trustee"] == null || obj["trustee"].isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => widget.onChanged({"nominee": "", "trustee": ""}));
          }
        }
        if (obj == null) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.onChanged({"nominee": "", "trustee": ""}));
        }
      }
    }
  }

  void checkPercentage() {
    var percentage = 0;
    for (var i = 0; i < obj["nominee"].length; i++) {
      percentage = percentage + obj["nominee"][i]["percentage"].toInt() as int;
    }

    if (percentage == 100) {
      obj.remove("empty");
    } else if (obj != null && obj["nominee"] == "") {
      obj.remove("empty");
    } else if (obj != null) {
      obj["empty"] = null;
    }
  }

  void nomineeRule() {
    setState(() {
      validateTrustee = hideTrustee(widget.info);
    });
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

  void save() {
    nomineeRule();
    if (!nominateObj["radioShow"]) {
      nominateObj["value"] = "";
    }
    if (!trusteeObj["radioShow"]) {
      trusteeObj["value"] = "";
    }

    if (trusteeObj["radioShow"]) {
      obj = {"nominee": nominateObj["value"], "trustee": trusteeObj["value"]};
    } else {
      obj = {"nominee": nominateObj["value"]};
    }

    if (validateTrustee["hideTrustee"]) {
      obj = {"nominee": nominateObj["value"]};
    }

    checkPercentage();
    widget.onChanged(obj);
  }

  bool checkNomineeTrustee() {
    if (trusteeObj["radioShow"]) {
      if (nominateObj["value"] != null && nominateObj["value"].length == 0) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget nominationRadio() {
      if (validateTrustee["hideNominee"]) return Container();
      return AddInfoContainer(
          obj: nominateObj,
          onChanged: (object) {
            if (object != null && object["onRadioChanged"] != null) {
              var enabled = object["onRadioChanged"];
              nominateObj["radioShow"] = enabled;
              setState(() {});
            }
            save();
          });
    }

    Widget trusteeRadio() {
      if (validateTrustee["hideTrustee"]) {
        obj = {"nominee": nominateObj["value"]};
        return Container();
      }

      return AddInfoContainer(
          obj: trusteeObj,
          nominee: nominateObj["value"],
          onChanged: (object) {
            if (object != null && object["onRadioChanged"] != null) {
              var enabled = object["onRadioChanged"];
              trusteeObj["radioShow"] = enabled;
              setState(() {});
            }
            save();
          });
    }

    widList = generateInputField(context, inputList, (key) {
      setState(() {});
    });

    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Important Note For Nomination and Trust"),
              style: t1FontW5()),
          Text(getLocale("Please read the following carefully."),
              style: sFontWN().copyWith(color: greyTextColor)),
          SizedBox(height: gFontSize * 2),
          widList["nomination"][0]["widget"],
          Text(getLocale("Please select one(1) option only"),
              style: t2FontWN().copyWith(color: greyTextColor)),
          Visibility(
              visible: checkNomineeTrustee(),
              child: Padding(
                  padding: EdgeInsets.only(top: gFontSize * 0.5),
                  child: Text(
                      "* ${getLocale("Please add at least one nominee if you want to appoint a trustee")}",
                      style: sFontWN().copyWith(color: scarletRedColor)))),
          SizedBox(height: gFontSize),
          nominationRadio(),
          trusteeRadio(),
          widList["nomination"][1]["widget"],
        ]));
  }
}
