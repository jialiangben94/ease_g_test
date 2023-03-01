import 'dart:convert';

import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/declaration/widget.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class Declaration extends StatefulWidget {
  final Function(dynamic obj) onChanged;
  const Declaration({Key? key, required this.onChanged}) : super(key: key);
  @override
  DeclarationState createState() => DeclarationState();
}

class DeclarationState extends State<Declaration> {
  dynamic obj;
  dynamic inputList;
  late dynamic widList;

  @override
  void initState() {
    super.initState();
    var info = ApplicationFormData.data;
    obj = ApplicationFormData.data["declaration"];

    info ??= {};
    if (info["policyOwner"] == null) {
      info["policyOwner"] = {};
    }
    if (info["payor"] == null) {
      info["payor"] = {};
    }
    if (info["lifeInsured"] == null) {
      info["lifeInsured"] = {};
    }

    var mapInfo = json.decode(json.encode(info));
    replaceAllMapping(mapInfo);

    var notes = """
<div>${getLocale("Please read carefully before signing this application.")}</div><br><br>
<table><colgroup><col width="5%" /><col width="90%" /></colgroup>
  <tr><td>1.</td><td>${getLocale("I/We am/are aware that I/we must answer all question and declaration in this application, and that these answers and declaration are accurate and complete. I/We agree that failure to answer a question or declaration, or incorrectly answering a question or declaration, may result in termination of the Policy, a claim not being paid, or or the terms and conditions of the Policy being changed.")}<br></td></tr>
  <tr><td>2.</td><td>${getLocale("I/We agree to notify")} ${getLocale("Etiqa Insurance", entity: true)} ${getLocale("in writing should there be a change to any answer or declaration in this application, prior to the date of issuance of the Policy. I/We agree that failure to notify")} ${getLocale("Etiqa Life Insurance", entity: true)} ${getLocale("of any such change, may result in termination of the Policy, a claim not being paid, or the terms and conditions of the Policy being changed.")}<br></td></tr>
  <tr><td>3.</td><td>${getLocale("I/We confirm the I/We fully understand that my/our answers and/or statement given in this application and any other relevant documents completed by me/us in connection with this application and in any medical report, questionnaire or amendment thereto shall be relied upon by Etiqa Insurance in deciding whether to accept my/our application or not.")}<br></td></tr>
  <tr><td>4.</td><td>${getLocale("I/We have understood that the purchase of 'Optional Rider and Benefit' is not compulsory and is not compulsory and is at my/our sole discretion. I/We have understood the need for these 'Optional Rider and Benefit' before consenting to include them to my/our basic Policy with an additional premium.")}<br></td></tr>
  <tr><td>5.</td><td>${getLocale("I/We hereby authorise any physician, hospital, clinic, Insurance company/Takaful operator, financial institution or any other organisation or company or person that has any records or knowledge about me/us, my/our financial standing or my/our health, to disclose to Etiqa Insurance or its representatives any or all information about me/us with referent to my/our family history and/or my/our financial standing and/or medical history before or after my/our death. I/We agree that a photocopy or facsimile of this authorisation shall be considered as effective and valid as the original and legally binding on anyone who takes over any of my/our legal rights.")}<br></td></tr>
  <tr><td>6.</td><td>${getLocale("I/We understand and agree that the Insurance coverage I/we have applied for shall only take effect on the date the Policy CONTRACT HAS BEEN ISSUED by Etiqa Insurance provided always that this application has been approved and that the full initial premium has been received by Etiqa Insurance during my/our lifetime and that prior to or at the date of commencement of the cover, there has been no alterations as to my/our health. If the initial premium is paid via cheque, I/we understand that the Insurance coverage will only commence after the cheque has been cleared.")}<br></td></tr>
  <tr><td>7.</td><td>${getLocale("I/We understand that in the period between submitting this application and issuance of the Policy by Etiqa Insurance, the lesser of the Basic Sum Insured, RM250,000 per Policy/RM500,000 per life, will be paid on death by accidental causes only, and only when such death occurs within ninety (90) days of this application date. I/We understand that the payment will be adjusted by the rates of premium paid over the total annual premium payable, and is only made if payment by cheque is cleared by the bank. I/We understand that this payment will terminate on the later of the issuance of Policy by Etiqa Insurance, the commencement date as set out in the Policy or the date of notification from Etiqa Insurance that this application is declined or cancelled. (Note: Accident is defined as a sudden, violent, unforeseen and unplanned event that results in bodily injury that is external and visible in nature.)")}<br></td></tr>
  <tr><td>8.</td><td><b>${getLocale("Personal Date Protection Act 2010 (PDPA)")}</b><br><br>${getLocale("I/We, agree, consent and allow Etiqa Insurance to process my/our personal data (including sensitive personal data) (‘Personal Data’) with the intention of entering into a contract of Insurance, in compliance with the provisions of the the PDPA.")}<br><br>${getLocale("I/We, understand and agree that any Personal Data collected or held by Etiqa Insurance (whether contained in this application or otherwise obtained) may be held, used, processed and disclosed by Etiqa Insurance to individuals and/or organisations related to and associated with Etiqa Insurance or any selected third party (within or outside Malaysia, including medical institutions, reinsurers, claim adjusters/investigators, solicitors, industry associations, regulators, statutory bodies and government authorities) for the purpose of processing this application and providing subsequent service related to it and to communicate with me/us for such purposes.")}<br><br>${getLocale("I/We understand that I/We have a right to obtain access to and to request correction of any Personal Data held by Etiqa Insurance concerning me/us. Such request can be made by completing the Access Request Form available at all Etiqa Insurance branches/or contact Etiqa Insurance via email at PDPA@etiqa.com.my. In accordance with the provisions of the PDPA, I/we may contact the Customer Service Centre at Etiqa Insurance Oneline at 1-300 13 8888 for the details of my/our Personal Data. Such information shall only be granted upon verification.")}<br><br>${getLocale("I/We agree, consent and allow Etiqa Insurance to share my/our Personal Data with Maybank Group, Etiqa Insurance’s agents or strategic partners and other thirds parties (“other entities”) as Etiqa Insurance deems fit and I/we may receive marketing communication from Etiqa Insurance or from these other entities about products and services that may be of interest to me/us.")}<br><br>${getLocale("Should I/we not provide an updated bank account for auto credit purposes to Etiqa Insurance (please refer to Section B above), I/we consent that my account with Maybank Group may be utilised for the same purposes.")}<br></td></tr>
  <tr><td>9.</td><td>${getLocale("I/We understand that the projected benefits shown in the sales illustrations are for illustration purposes only and are not guaranteed. The assumptions used to illustrate a range of returns on the Investment Linked Fund are hypothetical and actual returns may be higher or lower than these assumptions (if applicable).")}<br></td></tr>
  <tr><td>10.</td><td><b>${getLocale("Foreign Account Tax Compliance Act (FATCA)")}</b><br><br>${getLocale("I/We hereby consent that Etiqa Insurance, which includes its affiliates and branches, may disclose my/our information to the regulatory authorities to observe and fulfil the requirements of FATCA as may be stipulated by applicable laws, regulations, agreement or regulatory guidelines or directives (as circulated or amended from time to time).")}<br><br>${getLocale("I/We hereby consent that Etiqa Insurance, to the extent permitted under applicable law, may withhold from my/our account(s) (as defined under FATCA) under my/our relevant insurance policy, such amount in accordance with the requirements of FATCA as may be stipulated by applicable laws, regulations, agreement or regulatory guidelines or directives (as circulated or amended from time to time).")}<br><br>${getLocale("I/We hereby consent that Etiqa Insurance may classify me/us as recalcitrant account holder(s) as (as defined under FATCA) and/or suspend, recall or terminate my/our account(s) without Etiqa Insurance being held liable, in the event I/we fail to provide accurate and complete information and/or documentation as Etiqa Insurance may require.")}<br><br>${getLocale("I/We undertake to notify Etiqa Insurance in writing within thirty (30) days if there is a change in any information I/we have provided to Etiqa Insurance that would affect my/our status under FATCA")}.<br></td></tr>
</table>
""";

    inputList = {
      "declaration": {
        "fields": {
          "importantNote": {"type": "info2", "text": notes},
          "readAndAgree": {
            "type": "radiocheck",
            "label": getLocale(
                "I have read, understood and agree to the terms stated in the disclosure above."),
            "value": false,
            "required": true
          },
          "agreeMarketing": {
            "type": "radiocheck",
            "label":
                """${getLocale("I would like to receive marketing and promotional materials from")} ${getLocale("Etiqa Insurance", entity: true)}.""",
            "value": false,
            "required": false
          }
        }
      },
      "ownerIdentity": {
        "titleAsKey": true,
        "fields": {
          "remote": {
            "type": "switchRemote",
            "label": getLocale("Prefer to capture his/her signature remotely"),
            "value": false,
            "enabled": true,
            "required": true
          },
          "signature": {
            "type": "signature",
            "label": (mapInfo["policyOwner"]["name"] ?? ""),
            "headerLabel":
                "${getLocale("Policy Owner", entity: true)} - ${(mapInfo["policyOwner"]["name"] ?? "")}",
            "value": "",
            "required": true
          },
          "identityFront": {
            "type": "camera",
            "label": (mapInfo["policyOwner"]["identitytype"] ?? "") +
                " ${getLocale("Front")}",
            "value": "",
            "required": true
          },
          "identityBack": {
            "type": "camera",
            "label": (mapInfo["policyOwner"]["identitytype"] ?? "") +
                " ${getLocale("Back for Camera")}",
            "value": "",
            "required": true
          }
        }
      },
      "insuredIdentity": {
        "titleAsKey": true,
        "fields": {
          "remote": {
            "type": "switchRemote",
            "label": getLocale("Prefer to capture his/her signature remotely"),
            "value": false,
            "enabled": true,
            "required": true
          },
          "signature": {
            "type": "signature",
            "label": (mapInfo["lifeInsured"]["name"] ?? ""),
            "headerLabel":
                "${getLocale("Life Insured", entity: true)} - ${(mapInfo["lifeInsured"]["name"] ?? "")}",
            "value": "",
            "required": true
          },
          "identityFront": {
            "type": "camera",
            "label": (mapInfo["lifeInsured"]["identitytype"] ?? "") +
                " ${getLocale("Front")}",
            "value": "",
            "required": true
          },
          "identityBack": {
            "type": "camera",
            "label": (mapInfo["lifeInsured"]["identitytype"] ?? "") +
                " ${getLocale("Back for Camera")}",
            "value": "",
            "required": true
          }
        }
      }
    };

    if (info["buyingFor"] == BuyingFor.self.toStr) {
      inputList.remove("insuredIdentity");
    }

    if (info["payor"] != null &&
        info["payor"]["whopaying"] != null &&
        info["payor"]["whopaying"] != "policyOwner" &&
        info["payor"]["whopaying"] != "lifeInsured") {
      inputList["payorIdentity"] = {
        "titleAsKey": true,
        "fields": {
          "remote": {
            "type": "switchRemote",
            "label": getLocale("Prefer to capture his/her signature remotely"),
            "value": false,
            "enabled": true,
            "required": true
          },
          "signature": {
            "type": "signature",
            "label": (mapInfo["payor"]["name"] ?? ""),
            "headerLabel": "Payor - ${(mapInfo["payor"]["name"] ?? "")}",
            "value": "",
            "required": true
          },
          "identityFront": {
            "type": "camera",
            "label": (mapInfo["payor"]["identitytype"] ?? "") +
                " ${getLocale("Front")}",
            "value": "",
            "required": true
          },
          "identityBack": {
            "type": "camera",
            "label": (mapInfo["payor"]["identitytype"] ?? "") +
                " ${getLocale("Back for Camera")}",
            "value": "",
            "required": true
          }
        }
      };
    }

    generateDataToObjectValue(obj, inputList);

    if (obj != null && !obj.isEmpty) {
      for (var key in obj.keys) {
        if (inputList[key] != null &&
            inputList[key]["fields"] != null &&
            obj[key] is Map) {
          for (var key2 in obj[key].keys) {
            inputList[key]["fields"][key2]["value"] = obj[key][key2];
          }
        }
      }
    }
  }

  void checkInput() {
    for (var key in inputList.keys) {
      if (key != "declaration") {
        var remote = inputList[key]["fields"]["remote"];
        if (remote["value"]) {
          inputList[key]["fields"]["signature"]["required"] = false;
          inputList[key]["fields"]["identityFront"]["required"] = false;
          inputList[key]["fields"]["identityBack"]["required"] = false;
        } else {
          inputList[key]["fields"]["signature"]["required"] = true;
          inputList[key]["fields"]["identityFront"]["required"] = true;
          inputList[key]["fields"]["identityBack"]["required"] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      checkInput();
      var result = getInputedData(inputList);
      if (result["readAndAgree"] != null && !result["readAndAgree"]) {
        result["empty"] = null;
      }
      obj = result;
      widget.onChanged(obj);
      setState(() {});
    });

    List<Widget> agreeContent() {
      List<Widget> inWidList = [];
      for (var wid in widList["declaration"]) {
        inWidList.add(wid["widget"]);
        inWidList.add(SizedBox(height: gFontSize * 0.7));

        if (wid["key"] == "importantNote") {
          inWidList.add(SizedBox(height: gFontSize));
        }
      }
      return inWidList;
    }

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              "${getLocale("Declaration for")} ${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
              style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          ...agreeContent(),
          SizedBox(height: gFontSize * 1.1),
          const Divider(thickness: 1),
          SizedBox(height: gFontSize * 1.5),
          Text(getLocale("Please attach your NRIC and sign below"),
              style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          ...signatureContent(widList, inputList)
        ]));
  }
}
