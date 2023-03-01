import 'dart:convert';

import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/custom_column_table.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentDeclaration extends StatefulWidget {
  final dynamic obj;
  final Function(dynamic obj) onChanged;

  const AgentDeclaration({Key? key, this.obj, required this.onChanged})
      : super(key: key);
  @override
  AgentDeclarationState createState() => AgentDeclarationState();
}

class AgentDeclarationState extends State<AgentDeclaration> {
  dynamic inputList;
  late dynamic widList;
  late dynamic agentDeclaration;
  dynamic agent = {};
  dynamic obj;

  @override
  void initState() {
    super.initState();

    agentDeclaration = """
${getLocale("Please read carefully before signing this application.")}

${getLocale("I hereby declare that the information contained in this application form is only information given to me by the")} "${getLocale("Life Insured", entity: true)}/${getLocale("Policy Owner", entity: true)}" ${getLocale("and i have not withheld any other information which might influence the acceptance of this application.")}

${getLocale("In compliance with the Anti-Money Laundering & Anti-Terrorism Financing, and Proceeds of Unlawful Activities Act 2001 and Financial Services Act 2013, I hereby certify that the")} ${getLocale("Life Insured", entity: true)}${getLocale("'s")}/${getLocale("Policy Owner", entity: true)}${getLocale("'s Original NRIC/Birth Certificate/Passport was sighted and verified by me at the point of sale.")}

${getLocale("I hereby declare and confirm that i have presented and explained to the")} "${getLocale("Life Insured", entity: true)}/${getLocale("Policy Owner", entity: true)}" ${getLocale("the information contained in the Medical and Health Insurance checklist (where applicable), brochure (where applicable), product disclosure sheet and Sales Illustration (where applicable) in respect of the products and its Benefit(s), features as described therein.")}

${getLocale("I hereby agree that by selecting the button I am signing this Proposal Form and any other related documents ('Document') electronically and that my electronic signature is the legal equivalent of my manual signature on there Documents. Further, by selecting the button, I hereby consent to be legally bound by the terms and conditions of these Documents.")}

${getLocale("I hereby further agree and consent that the use if a key pad, mouse other device to select an item, button, icon or similar act/action, or to otherwise provide")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)} ${getLocale("via this Agency EPP STP platform, or in accessing or making any transaction regrading any agreement, acknowledgement, consent terms, disclosure or conditions constitutes my signature ('E-Signature'), acceptance and agreement as if actually signed by me in writing.")}

${getLocale("I also agree that no certification authority or other third party verification is necessary to validate my E-Signature and that the lack of such certification or third party verification will not in any way affect the enforceability of my E-Signature or any resulting contract between me and")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)}.
    """;

    inputList = {
      "agent": {
        "fields": {
          "signAt": {
            "type": "text",
            "label": getLocale("Signing at"),
            "value": "",
            "required": true,
            "column": true,
            "maxLength": 30,
          },
        }
      },
      "agentIdentity": {
        "fields": {
          "signature": {
            "type": "signature",
            "label": "",
            "headerLabel": "",
            "value": "",
            "required": true
          }
        }
      }
    };

    obj = widget.obj;

    generateDataToObjectValue(obj, inputList);

    if (obj != null && !obj.isEmpty) {
      for (var key in obj.keys) {
        if (obj[key] is Map) {
          for (var key2 in obj[key].keys) {
            inputList[key]["fields"][key2]["value"] = obj[key][key2];
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      var result = getInputedData(inputList);
      obj = result;
      widget.onChanged(obj);
    });

    List<Widget> agreeContent() {
      List<Widget> inWidList = [];
      for (var wid in widList["agent"]) {
        inWidList.add(wid["widget"]);
        inWidList.add(SizedBox(height: gFontSize * 0.7));
      }
      return inWidList;
    }

    Widget agentDetails() {
      var keys = [
        "AccountStatus",
        "FullName",
        "AccountCode",
        "EmailAddress",
        "MobilePhone"
      ];
      if (agent.isEmpty) {
        SharedPreferences.getInstance().then((pref) {
          var string = pref.getString(spkAgent);
          if (string != null) {
            var decoded = json.decode(string);
            for (var key in decoded.keys) {
              if (keys.contains(key)) {
                agent[key] = {};
                var label = key[0];
                for (var i = 1; i < key.length; i++) {
                  label = key[i].toUpperCase() != key[i]
                      ? label + key[i]
                      : label + " " + key[i];
                }
                agent[key]["label"] = getLocale(label);
                agent[key]["value"] = key == 'AccountStatus'
                    ? getLocale(decoded['AccountStatus'])
                    : decoded[key].toString();
              }
            }
            setState(() {});
          }
        });
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Agent Details"), style: t1FontW5()),
        SizedBox(height: gFontSize * 1.5),
        CustomColumnTable(arrayObj: [agent])
      ]);
    }

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Declaration for Agent"), style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          Text(agentDeclaration, style: bFontWN()),
          SizedBox(height: gFontSize * 1.5),
          const Divider(thickness: 1),
          SizedBox(height: gFontSize * 1.5),
          agentDetails(),
          SizedBox(height: gFontSize * 1.5),
          ...agreeContent(),
          SizedBox(height: gFontSize * 1.5),
          Text(getLocale("Please sign below"), style: bFontW5()),
          SizedBox(
              height: gFontSize * 15,
              width: gFontSize * 23,
              child: widList["agentIdentity"][0]["widget"])
        ]));
  }
}
