import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/util/directory.dart';
import 'package:ease/src/util/function.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic formatAPIDate2(timestamp) {
  if (timestamp == null) return "";
  final df = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS');
  return "${df.format(DateTime.fromMicrosecondsSinceEpoch(timestamp))}Z";
}

dynamic formatAPIDate(timestamp) {
  if (timestamp == null) return "";
  final df = DateFormat('dd-MM-yyyy');
  return df.format(DateTime.fromMicrosecondsSinceEpoch(timestamp));
}

//some temp workaround
Future<dynamic> formatClientInfo(type,
    {clientData, signatureData, clientTypeData, relationCodeData}) async {
  var data = json.decode(json.encode(ApplicationFormData.data));
  dynamic mainData;
  dynamic questions;
  var signature = {};
  String? clientType;
  String? relationCode;
  dynamic needs;
  bool isMedicalPlanExist = false;
  bool isSavingInvestPlanExist = false;
  bool isRetirementPlanExist = false;
  bool isChildEduPlanExist = false;
  bool isProtectionPlanExist = false;
  Map<dynamic, dynamic>? coverage = {};
  Map<dynamic, dynamic>? discussion = {};

  if (clientData != null) {
    mainData = clientData;
    signature = signatureData;
    clientType = clientTypeData;
    relationCode = relationCodeData;
  }

  if (type == "policyOwner") {
    mainData = data["policyOwner"];
    questions = data["poquestion"];
    clientType = lookupClientType["policyOwner"];

    if (data["buyingFor"] == BuyingFor.children.toStr) {
      if (isNumeric(mainData["relationshipChild"])) {
        relationCode = mainData["relationshipChild"];
      } else {
        relationCode = lookupRelationship[mainData["relationshipChild"]];
      }
    } else if (data["buyingFor"] == BuyingFor.spouse.toStr) {
      if (isNumeric(mainData["relationshipSpouse"])) {
        relationCode = mainData["relationshipSpouse"];
      } else {
        relationCode = lookupRelationship[mainData["relationshipSpouse"]];
      }
    }

    if (data["declaration"] == null ||
        (data["declaration"] != null &&
            data["declaration"]["ownerIdentity"] != null &&
            data["declaration"]["ownerIdentity"]["remote"])) {
      signature = {};
    } else {
      if (data["declaration"]["ownerIdentity"] != null) {
        signature = data["declaration"]["ownerIdentity"];
        try {
          var path = await getGlobalImageSavePath();
          if (signature["signature"] != null) {
            var image = await checkImage(signature["signature"], path["path"]);
            signature["signature"] = base64Encode(image["data"]);
          }
          if (signature["identityFront"] != null) {
            var image =
                await checkImage(signature["identityFront"], path["path"]);
            signature["identityFront"] = base64Encode(image["data"]);
          }
          if (signature["identityBack"] != null) {
            var image =
                await checkImage(signature["identityBack"], path["path"]);
            signature["identityBack"] = base64Encode(image["data"]);
          }
        } catch (e) {
          rethrow;
        }
      }
    }
  }

  if (type == "lifeInsured") {
    mainData = data["lifeInsured"];

    if (data["buyingFor"] == BuyingFor.self.toStr) {
      relationCode = "24";
    } else if (data["buyingFor"] == BuyingFor.children.toStr) {
      if (data["listOfQuotation"][0]["productPlanCode"] == "PTWI03") {
        relationCode = "";
      } else {
        relationCode = "24";
      }
    } else if (data["buyingFor"] == BuyingFor.spouse.toStr) {
      if (data["listOfQuotation"][0]["productPlanCode"] == "PTWI03") {
        relationCode = "";
      } else {
        relationCode = "24";
      }
    }

    if (mainData["sameasparent"] == true) {
      mainData["address"] = data["policyOwner"]["address"];
      mainData["address1"] = data["policyOwner"]["address1"];
      mainData["address2"] = data["policyOwner"]["address2"];
      mainData["city"] = data["policyOwner"]["city"];
      mainData["postcode"] = data["policyOwner"]["postcode"];
      mainData["state"] = data["policyOwner"]["state"];
      mainData["country"] = data["policyOwner"]["country"];
    }

    questions = data["liquestions"];
    if (data["disclosure"] != null && data["disclosure"]["coverage"] != null) {
      coverage = data["disclosure"]["coverage"];
    }
    if (coverage != null) {
      if (coverage["medical"] != null) {
        isMedicalPlanExist = true;
      }
      if (coverage["saving"] != null) {
        isSavingInvestPlanExist = true;
      }
      if (coverage["retirement"] != null) {
        isRetirementPlanExist = true;
      }
      if (coverage["childreneducation"] != null) {
        isChildEduPlanExist = true;
      }
      if (coverage["protection"] != null) {
        isProtectionPlanExist = true;
      }
    }
    if (data["disclosure"] != null &&
        data["disclosure"]["discussion"] != null) {
      discussion = data["disclosure"]["discussion"];
      discussion!.forEach((key, value) {
        coverage!.putIfAbsent(key, () => [{}]);
      });
    }

    for (var key in coverage!.keys) {
      if (coverage[key] is List) {
        for (var i = 0; i < coverage[key].length; i++) {
          coverage[key][i]["agenextbirthday"] =
              coverage[key][i]["agenextbirthday"] ?? "";
          coverage[key][i]["planpolicyowner"] =
              coverage[key][i]["planpolicyowner"] ?? "";
          coverage[key][i]["planlifeinsured"] =
              coverage[key][i]["planlifeinsured"] ?? "";
          coverage[key][i]["plancompany"] =
              coverage[key][i]["plancompany"] ?? "";
          coverage[key][i]["planname"] = coverage[key][i]["planname"] ?? "";
          coverage[key][i]["plantype"] = coverage[key][i]["plantype"] ?? "";
          coverage[key][i]["planpremiumamount"] =
              coverage[key][i]["planpremiumamount"] ?? "";
          coverage[key][i]["planpaymentmode"] =
              coverage[key][i]["planpaymentmode"] ?? "";

          if (coverage[key][i]["planstartdate"] is int) {
            coverage[key][i]["planstartdate"] =
                formatAPIDate(coverage[key][i]["planstartdate"]) ?? "";
          }
          if (coverage[key][i]["planmaturitydate"] is int) {
            coverage[key][i]["planmaturitydate"] =
                formatAPIDate(coverage[key][i]["planmaturitydate"]) ?? "";
          }

          coverage[key][i]["planlumpsummaturity"] =
              coverage[key][i]["planlumpsummaturity"] ?? "";
          coverage[key][i]["planincomematurity"] =
              coverage[key][i]["planincomematurity"] ?? "";
          coverage[key][i]["planamountmaturity"] =
              coverage[key][i]["planamountmaturity"] ?? "";
          coverage[key][i]["planfeematurity"] =
              coverage[key][i]["planfeematurity"] ?? "";
          coverage[key][i]["additionalbenefit"] =
              coverage[key][i]["additionalbenefit"] ?? "";

          coverage[key][i]["ToDiscussed"] = discussion[key] != null;

          if (discussion[key] != null) {
            coverage[key][i]["YearstoCommit"] = discussion[key]["year"] ?? "";
            coverage[key][i]["AmountAllocate"] =
                discussion[key]["amount"] ?? "";
            coverage[key][i]["NeedAdditionalCoverage"] =
                discussion[key]["needAdditionalCoverage"] ?? "";
            coverage[key][i]["Charge"] = discussion[key]["charge"] ?? "";
            coverage[key][i]["Remarks"] = discussion[key]["remarks"] ?? "";
          }
        }
      }
    }

    clientType = lookupClientType["lifeInsured"];
    if (data["buyingFor"] == BuyingFor.self.toStr) {
      clientType = lookupClientType["poli"];
    }

    if (mainData["monthlyincome"] == null || mainData["monthlyincome"] == "") {
      mainData["monthlyincome"] = "0";
    } else {
      if (mainData["monthlyincome"].contains(",")) {
        mainData["monthlyincome"] =
            mainData["monthlyincome"].replaceAll(",", "");
      }
      mainData["monthlyincome"] =
          double.parse(mainData["monthlyincome"]).toStringAsFixed(2);
    }

    needs = [
      {
        "AlreadyPlanned": data["priority"]["protection"]["planned"],
        "NeedCode": 1,
        "NeedName":
            "Protecting your family against Death, Emergency and Yourself against Disability and Critical Illness",
        "Priority": data["priority"]["protection"]["priority"],
        "ToDiscussed": discussion["protection"] != null
      },
      {
        "AlreadyPlanned": data["priority"]["retirement"]["planned"],
        "NeedCode": 2,
        "NeedName": "Retirement Plan",
        "Priority": data["priority"]["retirement"]["priority"],
        "ToDiscussed": discussion["retirement"] != null
      },
      {
        "AlreadyPlanned": data["priority"]["education"]["planned"],
        "NeedCode": 3,
        "NeedName": "Provision for your children's Education",
        "Priority": data["priority"]["education"]["priority"],
        "ToDiscussed": discussion["education"] != null
      },
      {
        "AlreadyPlanned": data["priority"]["saving"]["planned"],
        "NeedCode": 5,
        "NeedName": "Regular savings for the future",
        "Priority": data["priority"]["saving"]["priority"],
        "ToDiscussed": discussion["saving"] != null
      },
      {
        "AlreadyPlanned": data["priority"]["investment"]["planned"],
        "NeedCode": 4,
        "NeedName": "Lump Sum Investment",
        "Priority": data["priority"]["investment"]["priority"],
        "ToDiscussed": discussion["investment"] != null
      },
      {
        "AlreadyPlanned": data["priority"]["medical"]["planned"],
        "NeedCode": 6,
        "NeedName": "Medical Plan",
        "Priority": data["priority"]["medical"]["priority"],
        "ToDiscussed": discussion["medical"] != null
      }
    ];

    if (data["declaration"] == null) {
      signature = {};
    } else if (data["declaration"] != null &&
            (data["buyingFor"] == BuyingFor.self.toStr &&
                data["declaration"]["ownerIdentity"] != null &&
                data["declaration"]["ownerIdentity"]["remote"]) ||
        (data["buyingFor"] != BuyingFor.self.toStr &&
            data["declaration"]["insuredIdentity"] != null &&
            data["declaration"]["insuredIdentity"]["remote"])) {
      signature = {};
    } else {
      if (data["buyingFor"] == BuyingFor.self.toStr) {
        signature = data["declaration"]["ownerIdentity"];
      } else {
        signature = data["declaration"]["insuredIdentity"];
      }
      try {
        var path = await getGlobalImageSavePath();
        if (signature["signature"] != null) {
          var image = await checkImage(signature["signature"], path["path"]);
          signature["signature"] = base64Encode(image["data"]);
        }
        if (signature["identityFront"] != null) {
          var image =
              await checkImage(signature["identityFront"], path["path"]);
          signature["identityFront"] = base64Encode(image["data"]);
        }
        if (signature["identityBack"] != null) {
          var image = await checkImage(signature["identityBack"], path["path"]);
          signature["identityBack"] = base64Encode(image["data"]);
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  if (type == "witness") {
    if (data["witness"] != null &&
        data["witness"]["witness"] == "othersrelation") {
      clientType = lookupClientType["witness"];
      mainData = data["witness"];

      if (mainData["remote"]) {
        signature = {};
      } else {
        if (mainData["signature"] != null) {
          var path = await getGlobalImageSavePath();
          var image = await checkImage(mainData["signature"], path["path"]);
          signature["signature"] = base64Encode(image["data"]);
        }
      }
    }
  }

  if (type == "agent") {
    clientType = lookupClientType["agent"];
    try {
      var pref = await SharedPreferences.getInstance();
      var string = pref.getString(spkAgent)!;
      var decoded = json.decode(string);

      if (data["agent"] != null && data["agent"]["signature"] != null) {
        var path = await getGlobalImageSavePath();
        var image = await checkImage(data["agent"]["signature"], path["path"]);
        signature["signature"] = base64Encode(image["data"]);
      }

      mainData = {
        "name": decoded["FullName"],
        "email": decoded["EmailAddress"],
        "clientID": decoded["AccountCode"],
        "mobile": decoded["MobilePhone"],
        "isAgent": true
      };
    } catch (e) {
      return null;
    }
  }

  if (type == "payor") {
    mainData = data["payor"];
    clientType = lookupClientType["payor"];

    if (mainData["sameasparent"] == true) {
      mainData["address"] = data["policyOwner"]["address"];
      mainData["address1"] = data["policyOwner"]["address1"];
      mainData["address2"] = data["policyOwner"]["address2"];
      mainData["city"] = data["policyOwner"]["city"];
      mainData["postcode"] = data["policyOwner"]["postcode"];
      mainData["state"] = data["policyOwner"]["state"];
      mainData["country"] = data["policyOwner"]["country"];
    }
    if (isNumeric(mainData["relationship"])) {
      relationCode = mainData["relationship"];
    } else {
      relationCode = lookupRelationship[mainData["relationship"]];
    }

    if (data["declaration"] == null) {
      signature = {};
    } else if (data["declaration"]["payorIdentity"] != null &&
        data["declaration"]["payorIdentity"]["remote"]) {
      signature = {};
    } else {
      signature = data["declaration"]["payorIdentity"];
      try {
        var path = await getGlobalImageSavePath();
        if (signature["signature"] != null) {
          var image = await checkImage(signature["signature"], path["path"]);
          signature["signature"] = base64Encode(image["data"]);
        }
        if (signature["identityFront"] != null) {
          var image =
              await checkImage(signature["identityFront"], path["path"]);
          signature["identityFront"] = base64Encode(image["data"]);
        }
        if (signature["identityBack"] != null) {
          var image = await checkImage(signature["identityBack"], path["path"]);
          signature["identityBack"] = base64Encode(image["data"]);
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  if (type == "nominee") {
    if (data["nomination"] != null &&
        data["nomination"]["nominee"] != null &&
        data["nomination"]["nominee"] is List) {
      var array = [];
      data["nomination"]["nominee"].forEach((nominee) async {
        String? rCode;
        if (isNumeric(nominee["relationship"])) {
          rCode = nominee["relationship"];
        } else {
          rCode = lookupRelationship[nominee["relationship"]];
        }

        if (nominee["sameaspo"] == true) {
          nominee["address"] = data["policyOwner"]["address"];
          nominee["address1"] = data["policyOwner"]["address1"];
          nominee["city"] = data["policyOwner"]["city"];
          nominee["postcode"] = data["policyOwner"]["postcode"];
          nominee["state"] = data["policyOwner"]["state"];
          nominee["country"] = data["policyOwner"]["country"];
        }

        array.add(await formatClientInfo(null,
            clientData: nominee,
            signatureData: {},
            clientTypeData: lookupClientType["nominee"],
            relationCodeData: rCode));
      });
      return array;
    } else {
      return null;
    }
  }

  if (type == "benefitOwner") {
    if (data["benefitOwner"] != null &&
        data["benefitOwner"]["person"] is List) {
      var array = [];
      for (var i = 0; i < data["benefitOwner"]["person"].length; i++) {
        var person = data["benefitOwner"]["person"][i];
        array.add(await formatClientInfo(null,
            clientData: person,
            signatureData: {},
            clientTypeData: lookupClientType["benefitowner"]));
      }
      return array;
    } else {
      return null;
    }
  }

  if (type == "trustee") {
    if (data["nomination"] != null &&
        data["nomination"]["trustee"] != null &&
        data["nomination"]["trustee"] is List) {
      var array = [];
      data["nomination"]["trustee"].forEach((person) async {
        var sign = {};
        if (person["remote"] == null ||
            (person["remote"] != null && person["remote"])) {
          sign = {};
        } else {
          if (data["trusteesign"]
                  ["Identity-${person[person["identitytype"]]}"] !=
              null) {
            var sign2 = data["trusteesign"]["trusteesign"]
                ["Identity-${person[person["identitytype"]]}"];
            var path = await getGlobalImageSavePath();
            var image = await checkImage(sign2["signature"], path["path"]);
            sign2["signature"] = base64Encode(image["data"]);
            image = await checkImage(sign2["identityFront"], path["path"]);
            sign2["identityFront"] = base64Encode(image["data"]);
            image = await checkImage(sign2["identityBack"], path["path"]);
            sign2["identityBack"] = base64Encode(image["data"]);
            sign = sign2;
          }
        }
        array.add(await formatClientInfo(null,
            clientData: person,
            signatureData: sign,
            clientTypeData: lookupClientType["trustee"]));
      });
      return array;
    } else {
      return null;
    }
  }

  if (type == "consentMinor") {
    if (data["consentMinor"] &&
        data["guardian"] != null &&
        data["guardian"] != null) {
      mainData = data["guardian"];
      clientType = lookupClientType["guardian"];
      if (isNumeric(mainData["relationship"])) {
        relationCode = mainData["relationship"];
      } else {
        relationCode = lookupRelationship[mainData["relationship"]];
      }

      var path = await getGlobalImageSavePath();
      if (data["guardiansign"] != null &&
          !data["guardiansign"]["remote"] &&
          data["guardiansign"]["signature"] != null) {
        var image =
            await checkImage(data["guardiansign"]["signature"], path["path"]);
        signature["signature"] = base64Encode(image["data"]);
        image = await checkImage(
            data["guardiansign"]["identityFront"], path["path"]);
        signature["identityFront"] = base64Encode(image["data"]);
        image = await checkImage(
            data["guardiansign"]["identityBack"], path["path"]);
        signature["identityBack"] = base64Encode(image["data"]);
      }
      if (mainData["dob"] == null) {
        if (mainData["identitytype"] != null &&
            (mainData["identitytype"] == "nric" ||
                mainData["identitytype"] == "mypr")) {
          if (mainData[mainData["identitytype"]] != null &&
              mainData[mainData["identitytype"]].isNotEmpty) {
            var idnum = mainData[mainData["identitytype"]];
            var year = idnum.substring(0, 2);
            var day = idnum.substring(4, 6);
            var month = idnum.substring(2, 4);

            //TEMP WORKAROUND AS DateFormat not support for 2 digit as now
            if (int.parse(year) > 50) {
              year = "19$year";
            } else {
              year = "20$year";
            }

            var date = day + "/" + month + "/" + year;
            mainData["dob"] =
                DateFormat("dd/MM/yyyy").parse(date).microsecondsSinceEpoch;
          }
        }
      }
    }
  }

  var formatQuestion = [];
  if (questions != null) {
    if (!questions.keys.contains("1078h")) {
      questions["1078h"] = {
        "QuesNo": "1078h",
        "AnswerValue": "0",
        "AnswerXML": ""
      };
    }
    if (!questions.keys.contains("1078w")) {
      questions["1078w"] = {
        "QuesNo": "1078w",
        "AnswerValue": "0",
        "AnswerXML": ""
      };
    }
    for (var key in questions.keys) {
      if (questions[key] == null) {
        continue;
      }
      if (key == "readAndAgree") {
        continue;
      }
      if (questions[key]["QuesNo"] == "1288" ||
          questions[key]["QuesNo"] == "1032") {
        questions[key]["AnswerXML"] = questions[key]["AnswerXML"]
            .replaceAll('</Row>', '')
            .replaceAll('<Row>', '');
      }
      if (questions[key]["QuesNo"] == "1042") {
        var json = xml2json(questions[key]["AnswerXML"]);
        if (json != null &&
            json["Answer"] != null &&
            json["Answer"].length > 0) {
          for (var e = 0; e < json["Answer"].length; e++) {
            for (var key2 in json["Answer"][e].keys) {
              if (key2 == "IssueDate") {
                if (json["Answer"][e][key2] is int) {
                  json["Answer"][e][key2] =
                      formatAPIDate(json["Answer"][e][key2]);
                } else {
                  int? issuedate = isNumeric(json["Answer"][e][key2])
                      ? json["Answer"][e][key2]
                      : int.tryParse(json["Answer"][e][key2]);
                  if (issuedate != null) {
                    json["Answer"][e][key2] = formatAPIDate(issuedate);
                  }
                }
              }
            }
          }
          questions[key]["AnswerXML"] = json2xml(json);
        }
      }

      if (questions[key]["QuesNo"] == "1334") {
        if (questions["1335"]["AnswerValue"] != "") {
          var boo =
              questions["1335"]["AnswerValue"].toString()[0].toUpperCase() +
                  questions["1335"]["AnswerValue"].toString().substring(1);
          questions[key]["AnswerXML"] =
              "<Row><ROPSubQuestion1335>$boo</ROPSubQuestion1335></Row>";
        }
      }
      if (questions[key]["QuesNo"] == "1335") {
        continue;
      }
      formatQuestion.add(questions[key]);
    }
  }

  return mainData != null
      ? {
          "IsAgent": mainData["isAgent"] ?? false,
          "ClientID": mainData["clientID"] ?? "",
          "IsSmoker": mainData["smoking"] ?? false,
          "ClientType": clientType,
          "MaritalStatus": lookupMaritalStatus[mainData["maritalstatus"]] ??
              mainData["maritalstatus"],
          "IDType": identityTypeMap[mainData["identitytype"]] ??
              mainData["identitytype"],
          "IDNum": mainData[mainData["identitytype"]] ?? "",
          "Race": lookupRace[mainData["race"]] ?? mainData["race"],
          "Religion": mainData["muslim"] == true ? "I" : "O",
          "RelationCode": relationCodeData ?? relationCode,
          "Gender": lookupGender[mainData["gender"]] ?? mainData["gender"],
          "Age": mainData["dob"] != null
              ? getAgeString(
                  DateFormat('dd.M.yyyy').format(
                      DateTime.fromMicrosecondsSinceEpoch(mainData["dob"])),
                  false)
              : 0,
          "CountryOfBirth": mainData["countryofbirth"] ?? "",
          "Salutation": mainData["salutation"],
          "Name": mainData["name"],
          "PrefLngCode": mainData["preferlanguage"] ?? "",
          "DateofBirth": formatAPIDate(mainData["dob"]) ?? "",
          "OccupationCode": mainData["occupation"] != null
              ? json.decode(mainData["occupation"])["OccupationCode"]
              : "",
          "PartTime": mainData["parttimeOcc"] != null
              ? json.decode(mainData["parttimeOcc"])["OccupationCode"]
              : "",
          "NatureOfBiz": mainData["natureofbusiness"] ?? "",
          "EmployerName": mainData["companyname"] ?? "",
          "AutoCreditBankCode": mainData["bankname"] ?? "",
          "AutoCreditBankName": mainData["bankname"] != null
              ? getBankName(mainData["bankname"])
              : "",
          "AutoCreditAccountNumber": mainData["accountno"],
          "Nationality": mainData["nationality"] ?? "",
          "IsBumiputra": false,
          "EducationLevel": mainData["educationlevel"] ?? "",
          "MonthlyIncome": mainData["monthlyincome"] != null &&
                  mainData["monthlyincome"] != ""
              ? mainData["monthlyincome"]
              : "0.00",
          "DistributionBenefit":
              clientType == "4" ? mainData["percentage"] ?? 0 : 0,
          "PercentageShare": 0,
          "YearToSupport": 0,
          "NoOfChild": mainData["numberofchildren"] ?? 0,
          "Contact": {
            "MobileNo":
                mainData["mobileno"] != null ? "0${mainData["mobileno"]}" : "",
            "MobileNo2": mainData["mobileno2"],
            "HomePhone": mainData["hometel"],
            "FaxNo": "",
            "OfficeNo": mainData["officetel"],
            "Email": mainData["email"]
          },
          "Address": [
            {
              "IsPrimary": mainData["mailing"] != null && !mainData["mailing"]
                  ? false
                  : true,
              "Address1": mainData["address"],
              "Address2": mainData["address1"],
              "Address3": mainData["address2"],
              "City": mainData["city"],
              "PostCode": mainData["postcode"],
              "StateCode": lookupState[mainData["state"]] ?? mainData["state"],
              "CountryCode": "MYS",
              "AddressType": "1"
            },
            if (mainData["mailing"] != null && !mainData["mailing"])
              {
                "IsPrimary": true,
                "Address1": mainData["mailingaddress"],
                "Address2": mainData["mailingaddress1"],
                "Address3": mainData["mailingaddress2"],
                "City": mainData["mailingcity"],
                "PostCode": mainData["mailingpostcode"],
                "StateCode": lookupState[mainData["mailingstate"]],
                "CountryCode": mainData["mailingcountry"],
                "AddressType": "2"
              }
          ],
          "Questions": formatQuestion,
          "IsMedicalPlansPolExist": isMedicalPlanExist,
          "IsSavingInvestPlanPolExist": isSavingInvestPlanExist,
          "IsRetirementPlanPolExist": isRetirementPlanExist,
          "IsChildEduPlanPolExist": isChildEduPlanExist,
          "IsPrtPlanPolExist": isProtectionPlanExist,
          "ExistingSavingInvestPlan": coverage["saving"] ?? [],
          "ExistingCoverage": coverage["protection"] ?? [],
          "ExistingMedicalPlan": coverage["medical"] ?? [],
          "ExistingRetirement": coverage["retirement"] ?? [],
          "ExistingChildEdu": coverage["childreneducation"] ?? [],
          "ExistingCoverageDisclosure": [],
          "FATCADetails": (clientType == "1" || clientType == "3")
              ? fatcaDetails(mainData)
              : null,
          "eSignature": {
            "Signature": signature["signature"] ?? "",
            "IdentityFront": signature["identityFront"] ?? "",
            "IdentityBack": signature["identityBack"] ?? ""
          },
          "accountInfo": {
            "TaxPayerID": clientType,
            "BankName": mainData["bankname"] != null
                ? getBankName(mainData["bankname"])
                : "",
            "AccountNo": mainData["accountno"]
          },
          "PotentialArea": {"need": needs ?? []}
        }
      : null;
}

dynamic fatcaDetails(mainData) {
  if (mainData["nationality"] == "8" || mainData["countryofbirth"] == "USA") {
    return {
      "CRSDetails": null,
      "IsUSCitizen": mainData["isUSCitizen"] ?? false,
      "IsUSPR": mainData["greenCardHolder"] ?? false,
      "IsUSResident": mainData["isUSResident"] ?? false,
      "TaxType": mainData["taxIdOrSecurityNo"],
      "TaxPayorID": mainData[mainData["taxIdOrSecurityNo"]],
      "TINReasonBRemark": null
    };
  } else if (mainData["countryofbirth"] != "USA" &&
          mainData["countryofbirth"] != "MYS" ||
      mainData["nationality"] != "8" && mainData["nationality"] != "458") {
    String? reasonnotin;
    if (mainData["reasonnotin"] != null) {
      reasonnotin =
          mainData["reasonnotin"].substring(mainData["reasonnotin"].length - 1);
    }
    return {
      "CRSDetails": {
        "Country": mainData["crscountry"],
        "HasTin": mainData["tinavailable"],
        "TIN": mainData["tin"],
        "TINReason": reasonnotin,
        "NoTINReason": mainData["reasonnotintext"]
      },
      "IsUSCitizen": false,
      "IsUSPR": false,
      "IsUSResident": false,
      "TaxType": null,
      "TaxPayorID": null,
      "TINReasonBRemark": mainData["reasonnotin"] == "reasonA"
          ? "TIN is not issued by the country/jurisdiction of tax residence"
          : mainData["reasonnotin"] == "reasonB"
              ? "TIN is not required by country of tax residence"
              : mainData["reasonnotin"] == "reasonC"
                  ? "Unable to provide TIN"
                  : null
    };
  } else {
    return null;
  }
}

Future<List> formatProductDetails({QuickQuotation? quo}) async {
  var data = json.decode(json.encode(ApplicationFormData.data));
  quo ??= QuickQuotation.fromMap(data["listOfQuotation"][0]);
  String? prodcode = quo.productPlanCode;

  var products = [];
  var riders = quo.riderOutputDataList != null
      ? quo.riderOutputDataList!
          .map((data) => data.toMap())
          .toList(growable: false)
      : [];

  var productSetup =
      await getProductDetails(prodcode == "PCHI04" ? "PCHI03" : prodcode);
  var riderSetup =
      await getRiderPlanDetails(prodcode == "PCHI04" ? "PCHI03" : prodcode);

  // Product mapping
  products.add({
    "RiderOption": "",
    "GrossPremium": quo.basicPlanPremiumAmount,
    "ProdCode": quo.productPlanCode,
    "ProdVersion": productSetup["ProductSetup"]["ProdVersion"],
    "SumAssured": quo.basicPlanSumInsured,
    "SumAssuredIOS": "0.00",
    "PolicyTerm": quo.basicPlanPolicyTerm ?? quo.policyTerm,
    "PremiumPayTerm": quo.basicPlanPaymentTerm,
    "ModalPremium": quo.basicPlanPremiumAmount,
    "Units": "0",
    "MaturityAge": prodcode == "PCHI03" ||
            prodcode == "PCHI04" ||
            prodcode == "PTHI01" ||
            prodcode == "PTHI02" ||
            prodcode == "PCEL01"
        ? "0"
        : quo.maturityAge ?? "0",
    "ProductType": productSetup["ProductSetup"]["ProdType"],
    "IsUnitBasedProd": productSetup["ProductSetup"]["IsUnitBasedProd"],
    "PremiumBasis": productSetup["ProductSetup"]["PremiumBasis"],
    "LOB": productSetup["ProductSetup"]["LOB"],
    "ClientTypeID": 2
  });

  // Enricher mapping
  var enrichers = riderSetup
      .where(
          (element) => element["ProductSetup"]["ProdName"].contains("Enricher"))
      .toList();

  if (enrichers.isNotEmpty) {
    if (enrichers.length > 1) {
      enrichers.sort((a, b) {
        int aa = a != null && a["ProductSetup"]["ProdVersion"] != null
            ? a["ProductSetup"]["ProdVersion"] ?? 1
            : 1;
        int bb = b != null && b["ProductSetup"]["ProdVersion"] != null
            ? b["ProductSetup"]["ProdVersion"] ?? 1
            : 1;
        return bb.compareTo(aa);
      });
    }

    var enricher = enrichers[0];
    var riderD = productSetup["RiderList"].firstWhere((element) =>
        element["RiderCode"] == enricher["ProductSetup"]["ProdCode"]);

    products.add({
      "RiderOption": riderD["RiderOption"],
      "GrossPremium": quo.enricherPremiumAmount,
      "ProdCode": enricher["ProductSetup"]["ProdCode"],
      "ProdVersion": enricher["ProductSetup"]["ProdVersion"],
      "SumAssured": quo.enricherSumInsured ?? 0,
      "SumAssuredIOS": "0.00",
      "PolicyTerm": quo.enricherPolicyTerm,
      "PremiumPayTerm": quo.enricherPaymentTerm,
      "ModalPremium": quo.enricherPremiumAmount,
      "Units": "0",
      "MaturityAge": quo.maturityAge ?? "0",
      "ProductType": enricher["ProductSetup"]["ProdType"],
      "IsUnitBasedProd": enricher["ProductSetup"]["IsUnitBasedProd"],
      "PremiumBasis": enricher["ProductSetup"]["PremiumBasis"],
      "LOB": enricher["ProductSetup"]["LOB"],
      "ClientTypeID": riderD["ClientType"]
    });
  }

  // Regular Top-Up mapping
  if (quo.rtuAmt != null && quo.rtuAmt != "0" && quo.rtuAmt != "0.00") {
    var rtus = riderSetup
        .where((element) =>
            element["ProductSetup"]["ProdName"].contains("Regular Top-Up") ||
            element["ProductSetup"]["ProdName"].contains("Regular Top-up"))
        .toList();

    if (rtus.isNotEmpty) {
      if (rtus.length > 1) {
        rtus.sort((a, b) {
          int aa = a != null && a["ProductSetup"]["ProdVersion"] != null
              ? a["ProductSetup"]["ProdVersion"] ?? 1
              : 1;
          int bb = b != null && b["ProductSetup"]["ProdVersion"] != null
              ? b["ProductSetup"]["ProdVersion"] ?? 1
              : 1;
          return bb.compareTo(aa);
        });
      }
      var rtu = rtus[0];
      var ridersetups = productSetup["RiderList"]
          .where((e) => e["RiderCode"] == rtu["ProductSetup"]["ProdCode"])
          .toList();
      var ridersetup = ridersetups[0];
      var rtuSAIOS = quo.rtuSAIOS != null ? toRM(quo.rtuSAIOS) : "0.00";

      products.add({
        "RiderOption": ridersetup["RiderOption"],
        "GrossPremium": quo.rtuAmt,
        "ProdCode": rtu["ProductSetup"]["ProdCode"],
        "ProdVersion": rtu["ProductSetup"]["ProdVersion"],
        "SumAssured": rtuSAIOS,
        "SumAssuredIOS": rtuSAIOS,
        "PolicyTerm": quo.rtuPolicyTerm,
        "PremiumPayTerm": quo.rtuPaymentTerm,
        "ModalPremium": quo.rtuAmt,
        "Units": "0",
        "MaturityAge": quo.maturityAge ?? "0",
        "ProductType": rtu["ProductSetup"]["ProdType"],
        "IsUnitBasedProd": rtu["ProductSetup"]["IsUnitBasedProd"],
        "PremiumBasis": rtu["ProductSetup"]["PremiumBasis"],
        "LOB": rtu["ProductSetup"]["LOB"],
        "ClientTypeID": ridersetup["ClientType"]
      });
    }
  }

  // Riders mapping
  for (var i = 0; i < riders.length; i++) {
    if (riders[i]["riderName"].contains("IL Savings Growth") ||
        riders[i]["riderName"].contains("Takafulink Savings Flexi")) {
      continue;
    }
    dynamic riderDs;

    // For rider that have childcode
    if (prodcode == "PCWA01") {
      if (riders[i]["riderCode"] == "RCIHC1" ||
          riders[i]["riderCode"] == "RCIMP1" ||
          riders[i]["riderCode"] == "RCHB01" ||
          riders[i]["riderCode"] == "RCME01" ||
          riders[i]["riderCode"] == "RTIMP1" ||
          riders[i]["riderCode"] == "RTIHC1") {
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["childCode"])
            .toList();
      } else if (riders[i]["riderPlan"] == "2% of Basic Plan Sum Insured") {
        riders[i]["childCode"] = "RFNA2";
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["childCode"])
            .toList();
      } else if (riders[i]["riderPlan"] == "3% of Basic Plan Sum Insured") {
        riders[i]["childCode"] = "RFNA3";
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["childCode"])
            .toList();
      } else {
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["riderCode"])
            .toList();
      }
    } else {
      if (riders[i]["riderCode"] == "RCIHC1" ||
          riders[i]["riderCode"] == "RCIMP1" ||
          riders[i]["riderCode"] == "RCHB01" ||
          riders[i]["riderCode"] == "RCME01" ||
          riders[i]["riderCode"] == "RTIMP1" ||
          riders[i]["riderCode"] == "RTIHC1" ||
          riders[i]["riderCode"] == "RFNA1") {
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["childCode"])
            .toList();
      } else {
        riderDs = productSetup["RiderList"]
            .where((value) => value["RiderCode"] == riders[i]["riderCode"])
            .toList();
      }
    }
    var riderD = riderDs[0];
    var selectedRiders = quo.eligibleRiders != null
        ? quo.eligibleRiders!
            .map((data) => data.toJson())
            .toList(growable: false)
        : [];

    // Sort rider product version
    var riderSetups = selectedRiders
        .where((e) => e["ProductSetup"]["ProdCode"] == riders[i]["riderCode"])
        .toList();
    if (riderSetups.length > 1) {
      riderSetups.sort((a, b) {
        int aa = a != null && a["ProductSetup"]["ProdVersion"] != null
            ? a["ProductSetup"]["ProdVersion"] ?? 1
            : 1;
        int bb = b != null && b["ProductSetup"]["ProdVersion"] != null
            ? b["ProductSetup"]["ProdVersion"] ?? 1
            : 1;
        return bb.compareTo(aa);
      });
    }
    var riderSetup = riderSetups[0];

    if (riders[i]["riderMonthlyPremium"] != null &&
        riders[i]["riderMonthlyPremium"] == "N/A") {
      riders[i]["riderMonthlyPremium"] = "0";
    }
    if (riders[i]["riderCode"] == "HMND" && riders[i]["Units"] == null) {
      riders[i]["Units"] = riders[i]["riderSA"];
    }
    if (riderSetup["ProductSetup"]["IsUnitBasedProd"] == true &&
        riders[i]["Units"] == null) riders[i]["Units"] = "1";

    String? riderSA;
    String riderModalPrem = "0";
    if (riders[i]["riderCode"] == "RCIHC1" ||
        riders[i]["riderCode"] == "RCIMP1") {
      riderSA = isNumeric(riders[i]["riderSA"])
          ? riders[i]["riderSA"]
          : quo.totalPremium;
      riderModalPrem = riders[i]["riderNotionalPrem"] ?? "0";
    } else if (riderSetup["ProductSetup"]["IsUnitBasedProd"]) {
      riderSA = riders[i]["riderSA"];
      riderModalPrem = riders[i]["riderMonthlyPremium"] ?? "0";
    } else {
      riderSA = isNumeric(riders[i]["riderSA"])
          ? riders[i]["riderSA"]
          : quo.totalPremium;
      riderModalPrem = riders[i]["riderNotionalPrem"] ?? "0";
    }
    String? deductibleLimit;
    if (riders[i]["riderCode"] == "RCIMP1" ||
        riders[i]["riderCode"] == "RTIMP1") {
      deductibleLimit = lookupMedDeductible[riders[i]["tempSA"]];
    }
    var riderSAIOS = riders[i]["riderSAIOS"] != null
        ? toRM(riders[i]["riderSAIOS"])
        : "0.00";

    if (riders[i]["riderCode"] == "RTIAW2") {
      var getSA = quo.vpmsinput!.elementAt(
          quo.vpmsinput!.indexWhere((element) => element.contains("A_WI_SA")));
      riderSA = getSA[1];
    }
    String? riderMaturityAge;
    if (prodcode == "PTWI03") {
      int calcMaturityAge = int.parse(riders[i]["riderOutputTerm"]) +
          int.parse(data["listOfQuotation"][0]["anb"]);
      riderMaturityAge = calcMaturityAge.toString();

      // Set maturity age (EPT)
      if (riders[i]["riderCode"] == "RTICI5" ||
          riders[i]["riderCode"] == "RTICI4" ||
          riders[i]["riderCode"] == "RTIWP7" ||
          riders[i]["riderCode"] == "RTIWP8" ||
          riders[i]["riderCode"] == "RTIWC4") {
        riderMaturityAge = "100";
      }
    } else {
      riderMaturityAge = "0";
    }

    products.add({
      "RiderOption": riderD["RiderOption"],
      "GrossPremium":
          riders[i]["GrossPremium"] ?? riders[i]["riderMonthlyPremium"] ?? 0,
      "ProdCode": riderD["RiderCode"],
      "ProdVersion": riderSetup["ProductSetup"]["ProdVersion"],
      "SumAssured": riderSA,
      "SumAssuredIOS": riderSAIOS,
      "PolicyTerm": riders[i]["riderOutputTerm"],
      "PremiumPayTerm": prodcode == "PTWI03"
          ? riders[i]["riderOutputTerm"]
          : riders[i]["riderPaymentTerm"],
      "ModalPremium": riderModalPrem,
      "Units": riders[i]["Units"] ?? "0",
      "MaturityAge": riders[i]["riderMaturityAge"] ?? riderMaturityAge,
      "ProductType": riderSetup["ProductSetup"]["ProdType"],
      "IsUnitBasedProd": riderSetup["ProductSetup"]["IsUnitBasedProd"],
      "PremiumBasis": riderSetup["ProductSetup"]["PremiumBasis"],
      "LOB": riderSetup["ProductSetup"]["LOB"],
      "ClientTypeID": riderD["ClientType"],
      "IsDeductible": riders[i]["riderCode"] == "RCIMP1" ||
          riders[i]["riderCode"] == "RTIMP1",
      "DeductibleLimit": deductibleLimit
    });
  }
  return products;
}

Future<Map> getProductDetails(productCode) async {
  List<ProductPlan> currPPList =
      await ProductPlanRepositoryImpl().getProductPlanSetup();
  var map = {};
  for (var i = 0; i < currPPList.length; i++) {
    if (currPPList[i].productSetup!.prodCode == productCode) {
      map = currPPList[i].toJson();
      break;
    }
  }
  return map;
}

Future<List> getRiderPlanDetails(productCode) async {
  var productSetup = await getProductDetails(productCode);
  List<ProductPlan> currPPList =
      await ProductPlanRepositoryImpl().getRiderPlanSetup();
  List map = [];
  var riderList = [];
  for (var e = 0; e < productSetup["RiderList"].length; e++) {
    riderList.add(productSetup["RiderList"][e]["RiderCode"]);
  }

  for (var i = 0; i < currPPList.length; i++) {
    if (riderList.contains(currPPList[i].productSetup!.prodCode)) {
      map.add(currPPList[i].toJson());
    }
  }
  return map;
}

Future<Map> getTsarReqObj(QuickQuotation quickqtn,
    {String? setID,
    bool getQuotationHistoryID = true,
    String? totalPremium}) async {
  var data = json.decode(json.encode(ApplicationFormData.data));
  String? payby = "2";
  var client = [];
  if (data["buyingFor"] == BuyingFor.self.toStr) {
    if (data["consentMinor"] != false) {
      client.add(await formatClientInfo("lifeInsured",
          relationCodeData: data["guardian"]["relationship"]));
    } else {
      client.add(await formatClientInfo("lifeInsured", relationCodeData: "24"));
    }

    payby = "3";
  } else {
    client.add(await formatClientInfo("lifeInsured", relationCodeData: ""));
    client.add(await formatClientInfo("policyOwner"));
    payby = lookupClientType[data["payor"]["whopaying"]];
  }

  if (data["payor"] != null && data["payor"]["whopaying"] == "othersrelation") {
    client.add(await formatClientInfo("payor"));
    payby = "7";
  }

  var witness = await formatClientInfo("witness");
  var agent = await formatClientInfo("agent");
  var nominee = await formatClientInfo("nominee");
  var benefitOwner = await formatClientInfo("benefitOwner");
  var consentMinor = await formatClientInfo("consentMinor");
  var trustee = await formatClientInfo("trustee");
  if (witness != null) client.add(witness);
  if (agent != null) client.add(agent);
  if (nominee != null) client.addAll(nominee);
  if (benefitOwner != null) client.addAll(benefitOwner);
  if (consentMinor != null) client.add(consentMinor);
  if (trustee != null) client.addAll(trustee);

  var productSetup = await getProductDetails(
      quickqtn.productPlanCode == "PCHI04"
          ? "PCHI03"
          : quickqtn.productPlanCode);

  if (productSetup["ProductSetup"] != null) {
    productSetup["ProductSetup"]["ProdCode"] = quickqtn.productPlanCode;
  }

  Random random = Random();
  var now = DateTime.now();
  String formattedDate = DateFormat('yyMMdd').format(now);
  var pref = await SharedPreferences.getInstance();
  Agent nagent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
  String newSetID =
      nagent.accountCode! + formattedDate + random.nextInt(9999999).toString();
  var products = await formatProductDetails(quo: quickqtn);

  // get quotation ID if not yet
  if (getQuotationHistoryID) {
    if (quickqtn.quotationHistoryID == null ||
        quickqtn.isSavedOnServer == null ||
        !quickqtn.isSavedOnServer!) {
      var temp = json.decode(json.encode(data));
      temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));
      temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));
      temp["policyOwner"] = json.encode(temp["policyOwner"]);
      temp["lifeInsured"] = json.encode(temp["lifeInsured"]);
      temp = Quotation.fromMap(temp);
      if (temp.buyingFor == BuyingFor.self.toStr) {
        temp.lifeInsured.clientType = lookupClientType["poli"];
        temp.policyOwner.clientType = lookupClientType["poli"];
      } else {
        temp.policyOwner.clientType = lookupClientType["policyOwner"];
        temp.lifeInsured.clientType = lookupClientType["lifeInsured"];
      }

      String action = "A";
      if (quickqtn.isSavedOnServer != null && quickqtn.isSavedOnServer!) {
        action = "U";
      }
      dynamic response = await savetoserver(temp, quickqtn, action);
      if (response != null && response["IsSuccess"]) {
        quickqtn.isSavedOnServer = response["IsSuccess"];
        quickqtn.quotationHistoryID = response["QuotationHistoryID"];
      }
    }
  }

  var obj = {
    "SetID": setID ?? newSetID,
    "QuotationID": quickqtn.quotationHistoryID ?? 0,
    "QuotationDate": quickqtn.dateTime,
    "PayMode": lookupPayMode[quickqtn.paymentMode],
    "PayMethod": "0",
    "PayBy": payby,
    "CampaignCode": quickqtn.campaign != null
        ? quickqtn.campaign!.prodCode == "default"
            ? "10000001"
            : quickqtn.campaign!.campaignName == "BRP Code"
                ? "BRP"
                : quickqtn.campaign!.prodCode ?? "10000001"
        : "10000001",
    "CampaignRemark": quickqtn.campaign != null &&
            quickqtn.campaign!.campaignName == "BRP Code"
        ? quickqtn.campaign!.campaignRemarks
        : null,
    "TotalPremium": toRM(quickqtn.totalPremium ?? totalPremium),
    "TotalPremiumIOS": toRM(quickqtn.basicPlanTotalPremiumIOS),
    "IsBackDate": false,
    "BackdatedDate": null,
    "TSARID": 0,
    "ClientList": client,
    "Product": productSetup["ProductSetup"],
    "BasicPlanData": products,
    "QuotationFund": quickqtn.fundOutputDataList != null
        ? quickqtn.fundOutputDataList!
            .map((data) => data.toMap())
            .toList(growable: false)
        : [],
    "QuoTopUp": {
      "TopUpAmount": quickqtn.rtuPremiumAmount,
      "PolicyYear": quickqtn.rtuPolicyTerm != "N/A" ? quickqtn.rtuPolicyTerm : 0
    },
    "tsarRes": null,
    "fffInfo": null,
    "sisInfo": null,
    "prodRecList": null
  };

  write(obj, "tsar");
  return obj;
}

Future<Map> getSubmitAppObj(
    {String? setID, String? paymentMethod, bool? includeAgent}) async {
  Random random = Random();
  var data = json.decode(json.encode(ApplicationFormData.data));
  String? payby = "2";

  var client = [];
  if (data["buyingFor"] == BuyingFor.self.toStr) {
    payby = "3";
    client.add(await formatClientInfo("lifeInsured"));
  } else {
    client.add(await formatClientInfo("lifeInsured", relationCodeData: ""));
    client.add(await formatClientInfo("policyOwner"));
    payby = lookupClientType[data["payor"]["whopaying"]];
  }

  if (data["payor"] != null && data["payor"]["whopaying"] == "othersrelation") {
    client.add(await formatClientInfo("payor"));
    payby = "7";
  }

  var witness = await formatClientInfo("witness");
  var agent = await formatClientInfo("agent");
  var nominee = await formatClientInfo("nominee");
  var benefitOwner = await formatClientInfo("benefitOwner");
  var consentMinor = await formatClientInfo("consentMinor");
  var trustee = await formatClientInfo("trustee");

  if (witness != null) client.add(witness);
  if (includeAgent != null) {
    if (includeAgent && agent != null) client.add(agent);
  } else {
    if (agent != null) client.add(agent);
  }

  if (nominee != null) client.addAll(nominee);
  if (benefitOwner != null) client.addAll(benefitOwner);
  if (consentMinor != null) client.add(consentMinor);
  if (trustee != null) client.addAll(trustee);

  var familyMember = [];
  if (data["familyMember"] != null) {
    for (var i = 0; i < data["familyMember"].length; i++) {
      final df = DateFormat('yyyy-MM-dd');
      var dob = df.format(
          DateTime.fromMicrosecondsSinceEpoch(data["familyMember"][i]["dob"]));
      familyMember.add({
        "relation":
            lookupRelationship[data["familyMember"][i]["relationship"]] ??
                data["familyMember"][i]["relationship"],
        "Name": data["familyMember"][i]["name"],
        "Gender": lookupGender[data["familyMember"][i]["gender"]] ??
            data["familyMember"][i]["gender"],
        "DOB": dob,
        "YearToSupport": int.parse(data["familyMember"][i]["yeartosupport"])
      });
    }
  }
  var productSetup = await getProductDetails(
      data["listOfQuotation"][0]["productPlanCode"] == "PCHI04"
          ? "PCHI03"
          : data["listOfQuotation"][0]["productPlanCode"]);
  if (productSetup["ProductSetup"] != null) {
    productSetup["ProductSetup"]["ProdCode"] =
        data["listOfQuotation"][0]["productPlanCode"];
  }
  var products = await formatProductDetails();
  var pref = await SharedPreferences.getInstance();
  Agent nagent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

  var now = DateTime.now();
  String formattedDate = DateFormat('yyMMdd').format(now);
  String newSetID =
      nagent.accountCode! + formattedDate + random.nextInt(9999999).toString();
  DateTime date =
      DateFormat('dd MMM yyyy').parse(data["listOfQuotation"][0]["dateTime"]);

  String potrans = "";
  String? otherpotrans = "";
  for (int i = 0;
      i < data["recommendedProducts"]["purposeOfTrans"].length;
      i++) {
    if (i == data["recommendedProducts"]["purposeOfTrans"].length - 1) {
      potrans = potrans +
          lookupPurposeTrans[data["recommendedProducts"]["purposeOfTrans"][i]]
              .toString();
    } else {
      potrans =
          "$potrans${lookupPurposeTrans[data["recommendedProducts"]["purposeOfTrans"][i]]},";
    }
    if (data["recommendedProducts"]["purposeOfTrans"][i] == "others") {
      otherpotrans = data["recommendedProducts"]["otherPurposeOfTrans"];
    }
  }

  String benefit = "";
  var riders = data["listOfQuotation"][0]["riderOutputDataList"];
  for (var i = 0; i < riders.length; i++) {
    if (i == riders.length - 1) {
      benefit = benefit + riders[i]["riderName"];
    } else {
      benefit = "${benefit + riders[i]["riderName"]}, ";
    }
  }

  if (data["listOfQuotation"][0]["QuotationHistoryID"] == null ||
      !data["listOfQuotation"][0]["isSavedOnServer"] ||
      data["listOfQuotation"][0]["isSavedOnServer"] == null) {
    var temp = json.decode(json.encode(data));
    temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));
    temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));
    temp["policyOwner"] = json.encode(temp["policyOwner"]);
    temp["lifeInsured"] = json.encode(temp["lifeInsured"]);
    temp = Quotation.fromMap(temp);
    if (temp.buyingFor == BuyingFor.self.toStr) {
      temp.lifeInsured.clientType = lookupClientType["poli"];
      temp.policyOwner.clientType = lookupClientType["poli"];
    } else {
      temp.policyOwner.clientType = lookupClientType["policyOwner"];
      temp.lifeInsured.clientType = lookupClientType["lifeInsured"];
    }

    var temp2 = json.decode(json.encode(data["listOfQuotation"][0]));
    temp2 = QuickQuotation.fromMap(temp2);

    String action = "A";
    if (temp2.isSavedOnServer != null && temp2.isSavedOnServer) action = "U";
    dynamic response = await savetoserver(temp, temp2, action);
    if (response != null && response["IsSuccess"]) {
      data["listOfQuotation"][0]["isSavedOnServer"] = response["IsSuccess"];
      data["listOfQuotation"][0]["QuotationHistoryID"] =
          response["QuotationHistoryID"];
    }
  }

  var tempDisclosure = Map.from(data['intermediary']);
  List disclosure = [];
  String disclosureOther = '';
  tempDisclosure.forEach((key, value) {
    if (value is bool) {
      if (value) {
        disclosure.add(key);
      }
    } else {
      disclosureOther = value;
    }
  });

  // Submit application json (sent to backend)
  var obj = {
    "SetID": setID ?? newSetID,
    "QuotationID": data["listOfQuotation"][0]["QuotationHistoryID"],
    "QuotationDate": DateFormat('yyyy-MM-dd').format(date),
    "PayMode": lookupPayMode[data["listOfQuotation"][0]["paymentMode"]],
    "PayMethod": paymentMethod != null
        ? paymentMethod == "creditdebit"
            ? lookupPayMethod["creditcard"]
            : lookupPayMethod[paymentMethod]
        : lookupPayMethod["creditcard"],
    "PayBy": payby,
    "CampaignCode": data["listOfQuotation"][0]["campaign"]["ProdCode"] ==
            "default"
        ? "10000001"
        : data["listOfQuotation"][0]["campaign"]["CampaignName"] == "BRP Code"
            ? "BRP"
            : data["listOfQuotation"][0]["campaign"]["ProdCode"] ?? "10000001",
    "CampaignRemark":
        data["listOfQuotation"][0]["campaign"]["CampaignName"] == "BRP Code"
            ? data["listOfQuotation"][0]["campaign"]["CampaignRemarks"]
            : null,
    "TotalPremium": num.parse(data["listOfQuotation"][0]["totalPremium"])
        .toStringAsFixed(2),
    "TotalPremiumIOS":
        data["listOfQuotation"][0]["basicPlanTotalPremiumIOS"] != null
            ? toRM(data["listOfQuotation"][0]["basicPlanTotalPremiumIOS"])
            : "0.00",
    "IsAdhocTopUp":
        data["listOfQuotation"][0]["adhocAmt"] == null ? false : true,
    "AdhocTopupAmt": data["listOfQuotation"][0]["adhocAmt"] ?? "0.00",
    "IsBackDate": false,
    "BackdatedDate": "1900-01-01T00:00:00",
    "TSARID": 0,
    "ClientList": client,
    "Product": productSetup["ProductSetup"],
    "BasicPlanData": products,
    "QuotationFund": data["listOfQuotation"][0]["fundOutputDataList"],
    "QuoTopUp": {
      "TopUpAmount": data["listOfQuotation"][0]["rtuPremiumAmount"] ?? 0,
      "PolicyYear": data["listOfQuotation"][0]["rtuPolicyTerm"] == null
          ? 0
          : data["listOfQuotation"][0]["rtuPolicyTerm"] != "N/A"
              ? data["listOfQuotation"][0]["rtuPolicyTerm"]
              : 0,
    },
    "tsarRes": data["tsarRes"],
    "fffInfo": {
      "FFFId": 0,
      "FFFNo": "",
      "AllocateCurrentIncome": 0,
      "AllocIncForChildEduPlan": 0,
      "CltAllocIncForRetirement": 0,
      "SpoPrtAllocIncForRetirement": 0,
      "CltAllocIncForProtection": 0,
      "SpoPrtAllocIncForProtection": 0,
      "AdvReason": "",
      "MatureYearsForSaving": 0,
      "MonthlyAllocationForSaving": 0,
      "MatureYearsForRetirement": 0,
      "MonthlyAllocationForRetirement": 0,
      "MatureYearsForChildEdu": 0,
      "MonthlyAllocationForChildEdu": 0,
      "YearsForProtection": 0,
      "ChargeForMedical": 0,
      "AnbForSaving": 0,
      "AnbForRetirement": 0,
      "AnbForChildEdu": 0,
      "Disclosure": disclosure.join(','),
      "DisclosureOthers": disclosureOther,
      "InvestPreference": data["investmentPreference"]["investmentpreference"],
      "FinancialNeedAnalysisJSON": "",
      "NeedType": "AT",
      "NeedName": "",
      "NeedPty": 0,
      "NeedAmount": 0,
      "NeedShortFall": 0,
      "ContributionAmount": 0,
      "PayMode": lookupPayMode[data["listOfQuotation"][0]["paymentMode"]],
      "ClientChoice": lookupClientChoice[data["disclosure"]["currentOption"]],
      "IsAckReq": true,
      "AcknowledgeBy": "",
      "AcknowledgedDate": formatAPIDate2(DateTime.now().microsecondsSinceEpoch),
      "InvestRiskLevel": checkFundRisk(),
      "IsProspect": "0",
      "IsPurchasedMedPlan": true,
      "PurchasedMedPlanName": "",
      "PreferredMedCoverage": "",
      "IsInterestedInMedplan": true,
      "PrdRecReason": data["recommendedProducts"]["recommendreason"] ?? "",
      "IsRiskReasonEntered": data["recommendedProducts"]["riskjustify"] != null,
      "SubmissionRiskReason": data["recommendedProducts"]["riskjustify"] ?? "",
      "familyList": familyMember
    },
    "sisInfo": {
      "SISNo": "",
      "BasicContribution": data["listOfQuotation"][0]["basicContribution"],
      "MinSA": data["listOfQuotation"][0]["minsa"] ?? 0,
      "SAM": data["listOfQuotation"][0]["sam"] ?? 0,
      "SustainabilityPeriod": "",
      "PurposeOfTrans": potrans,
      "PurposeOthers": otherpotrans,
      "RateScalesOption": data["listOfQuotation"][0]["guaranteedCashPayment"],
      "PremOption": 0,
      "GCPTerm": data["listOfQuotation"][0]["gcpTerm"] ??
          data["listOfQuotation"][0]["gcpTerm"] ??
          0,
      "GCPPremAmt": data["listOfQuotation"][0]["gcpPremAmt"] ??
          data["listOfQuotation"][0]["gcpPremAmt"] ??
          0,
      "TotalPremiumAfterLoad":
          data["listOfQuotation"][0]["totalPremOccLoad"] ?? 0,
      "IsStepUp": data["listOfQuotation"][0]["isSteppedPremium"] ?? 0
    },
    "propInfo": {
      "LocOfSign": data["agent"] != null && data["agent"]["signAt"] != null
          ? data["agent"]["signAt"]
          : "",
      "AutoCdtBankCode": data["policyOwner"]["bankname"],
      "AutoCdtACNum": data["policyOwner"]["accountno"],
      "AutoCdtACHolderName": data["policyOwner"]["name"],
      "AutoCdtAccType": data["policyOwner"]["bankaccounttype"],
      "InitialPayMthd": "string",
      "PayRetryCount": 0,
      "FirstPayRetryDateTime": "2021-04-08T01:29:27.056Z",
      "IsAdvLumpsum": true,
      "AdvLumpsumPeriod": "",
      "AdvLumpsumYear": 0,
      "NominationType": "",
      "TabungHajiAccountNo": "",
      "PayorMotherName": "",
      "SourceOfFund": data["policyOwner"]["sourceoffund"] == "8a"
          ? "8"
          : data["policyOwner"]["sourceoffund"],
      "SourceOfFundOthers": data["policyOwner"]["sourceoffund"] == "8a"
          ? objMapping["allowance"]
          : data["policyOwner"]["othersource"] ?? "",
      "IsDeclarationAgree": true,
      "LeaderAckStatus": "",
      "LeaderAckDateTime": "",
      "CaseType": ""
    },
    "prodRecList": [
      {
        "FFFPrdRecID": 0,
        "FFFID": 0,
        "Priority": 1,
        "ProdCode": data["listOfQuotation"][0]["productPlanCode"],
        "ProdVersion": 1,
        "PolicyTerm": data["listOfQuotation"][0]["basicPlanPolicyTerm"] ??
            data["listOfQuotation"][0]["policyTerm"],
        "SumAssured": data["listOfQuotation"][0]["sumInsuredAmt"],
        "Premium": data["listOfQuotation"][0]["totalPremium"],
        "PayMode": lookupPayMode[data["listOfQuotation"][0]["paymentMode"]],
        "Benefit": benefit,
        "Reason": data["recommendedProducts"]["recommendreason"] ?? "",
        "CreatedBy": "",
        "CreatedDateTime": DateFormat('yyyy-MM-dd').format(now),
        "ModifiedBy": "",
        "ModifiedDateTime": "",
        "LeadFFF": null
      }
    ]
  };

  if (data["listOfQuotation"][0]["productPlanCode"] == "PCEL01") {
    obj["isCallVPMS"] = false;
  }

  write(obj, "submitapp");

  return obj;
}

void write(obj, name) async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/$name.json";
  final file = File(path);
  file.writeAsStringSync(json.encode(obj));
}

dynamic updateRemoteStatus(listOfRecipient, res) {
  dynamic update;
  if (res != null && res["resSubmit"] != null) {
    ApplicationFormData.data["application"] = res["resSubmit"];
  }
  if (res != null && res["ClientRemoteList"].length > 0) {
    listOfRecipient.forEach((element) {
      var recipient = res["ClientRemoteList"].firstWhere(
          (remote) => (remote["nric"] == element["IDNum"] &&
              remote["ClientName"] == element["name"]),
          orElse: () => null);
      if (recipient != null) {
        element["ClientID"] = recipient["ClientID"];
        element["VerifyStatus"] = recipient["VerifyStatus"];
        element["PaymentStatus"] = recipient["PaymentStatus"];
        element["SignatureDatetime"] = recipient["SignatureDatetime"];
        element["PaymentDatetime"] = recipient["PaymentDatetime"];
        element["signature"] = recipient["signature"];
        element["Front"] = recipient["Front"];
        element["Back"] = recipient["Back"];
        element["Remark"] = recipient["Remark"];
      }
    });
    update = listOfRecipient;
    return update;
  } else {
    return listOfRecipient;
  }
}

String remoteClientListID(List<dynamic> receipient) {
  String clientIDList = "";

  if (receipient.length > 1) {
    for (var i = 0; i < receipient.length; i++) {
      if (i == receipient.length - 1) {
        clientIDList = clientIDList + receipient[i]["ClientID"];
      } else {
        clientIDList = "${clientIDList + receipient[i]["ClientID"]};";
      }
    }
  } else {
    clientIDList = receipient[0]["ClientID"];
  }
  return clientIDList;
}

clientjson() async {
  var data = json.decode(json.encode(ApplicationFormData.data));
  String? payby = "2";

  var client = [];
  if (data["buyingFor"] == BuyingFor.self.toStr) {
    payby = "3";
    client.add(await formatClientInfo("lifeInsured"));
  } else {
    client.add(await formatClientInfo("lifeInsured"));
    client.add(await formatClientInfo("policyOwner"));
    payby = lookupClientType[data["payor"]["whopaying"]];
  }

  if (data["payor"] != null && data["payor"]["whopaying"] == "othersrelation") {
    client.add(await formatClientInfo("payor"));
    payby = "7";
  }

  var witness = await formatClientInfo("witness");
  var agent = await formatClientInfo("agent");
  var nominee = await formatClientInfo("nominee");
  var benefitOwner = await formatClientInfo("benefitOwner");
  var consentMinor = await formatClientInfo("consentMinor");
  var trustee = await formatClientInfo("trustee");

  if (witness != null) client.add(witness);
  if (agent != null) client.add(agent);

  if (nominee != null) client.addAll(nominee);
  if (benefitOwner != null) client.addAll(benefitOwner);
  if (consentMinor != null) client.add(consentMinor);
  if (trustee != null) client.addAll(trustee);
  var obj = {
    "PayBy": payby,
    "ClientList": client,
  };

  return obj;
}
