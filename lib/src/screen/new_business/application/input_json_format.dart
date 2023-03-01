import 'dart:convert';
import 'package:ease/src/data/postcode_city.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';

Map<String, String>? getCityByPostcode(postcode) {
  var list = postcodeCityList;
  Map<String, String>? map;
  if (postcode != null && !postcode.isEmpty) {
    for (var i = 0; i < list["state"].length; i++) {
      for (var e = 0; e < list["state"][i]["city"].length; e++) {
        if (list["state"][i]["city"][e]["postcode"].indexOf(postcode) > -1) {
          map = {
            "city": list["state"][i]["city"][e]["name"],
            "state": list["state"][i]["name"]
          };
        }
      }
    }
  }
  return map;
}

List<Map<String, dynamic>> getAllStateCity(type) {
  var list = postcodeCityList;
  List<Map<String, dynamic>> array = [];
  for (var i = 0; i < list["state"].length; i++) {
    if (type == "state") {
      array.add({
        "label": list["state"][i]["name"],
        "active": true,
        "value": list["state"][i]["name"]
      });
    } else {
      for (var e = 0; e < list["state"][i]["city"].length; e++) {
        array.add({
          "label": list["state"][i]["city"][e]["name"],
          "active": true,
          "value": list["state"][i]["city"][e]["name"]
        });
      }
    }
  }
  return array;
}

List<dynamic> getBankList() {
  var list = [];

  var bankList2 = getMasterlookup(type: "BankList");
  bankList2.forEach((bank) {
    List<dynamic> accountTypes = [];
    var data = bankList2.where((row) => (row["value"] == bank["value"]));
    data.forEach((element) {
      if (element["AccountNumLength"] != null) {
        accountTypes.add({
          "AccountTypeCode": element["AccountTypeCode"],
          "AccountNumLength": element["AccountNumLength"]
        });
      }
    });

    list.add({
      "label": bank["label"],
      "active": true,
      "AccountTypes": accountTypes,
      "value": bank["value"]
    });
  });

  return list;
}

String getBankName(String bankcode) {
  String bankName = "";

  var bankList2 = getMasterlookup(type: "BankList");
  var bank = bankList2.firstWhere((value) => value["value"] == bankcode,
      orElse: () => null);
  if (bank != null) bankName = bank["label"];

  return bankName;
}

dynamic getGlobalInputJsonFormat() {
  var map = objMapping;
  var salutation = {
    "type": "option1",
    "options": getMasterlookup(type: "Salutation"),
    "label": getLocale("Salutation"),
    "value": "",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option")
  };

  var name = {
    "type": "text",
    "label": getLocale("Full Name"),
    "value": "",
    "regex": "",
    "required": true,
    "maxLength": 50,
    "size": {}
  };

  var countrylist = getMasterlookup(type: "Country");
  var nationalitylist = getMasterlookup(type: "Nationality");

  var usTaxId = {
    "label": "US Tax ID",
    "active": true,
    "value": "usTaxId",
    "option_fields": {
      "usTaxId": {
        "type": "number",
        "label": "US Tax ID",
        "value": "",
        "regex": "",
        "size": {"textWidth": 40, "fieldWidth": 70, "emptyWidth": 12},
        "required": true,
      }
    }
  };

  var socialSecurity = {
    "label": getLocale("Social Security No"),
    "active": true,
    "value": "socialSecurity",
    "option_fields": {
      "socialSecurity": {
        "type": "number",
        "label": getLocale("Social Security No"),
        "value": "",
        "regex": "",
        "size": {"textWidth": 40, "fieldWidth": 70, "emptyWidth": 12},
        "required": true
      }
    }
  };

  var taxIdOrSecurityNo = {
    "type": "option1",
    "label": getLocale("Please select an option"),
    "value": "",
    "subfields": true,
    "required": true,
    "size": {"textWidth": 40, "fieldWidth": 70, "emptyWidth": 12},
    "options": [
      json.decode(json.encode(usTaxId)),
      json.decode(json.encode(socialSecurity)),
      {
        "label": getLocale("Unable to provide US Tax ID or Social Security No"),
        "active": true,
        "value": "notdiscloseUS"
      }
    ]
  };

  var isUSResident = {
    "type": "switchButton",
    "options": [
      {
        "label": map["yes"],
        "active": true,
        "value": true,
        "option_fields": {"taxIdOrSecurityNo": taxIdOrSecurityNo}
      },
      {"label": map["no"], "active": true, "value": false}
    ],
    "label": getLocale("Are you a US Resident?"),
    "value": true,
    "regex": "",
    "expand": true,
    "required": true
  };

  var greenCardHolder = {
    "type": "switchButton",
    "options": [
      {
        "label": map["yes"],
        "active": true,
        "value": true,
        "option_fields": {"taxIdOrSecurityNo": taxIdOrSecurityNo}
      },
      {
        "label": map["no"],
        "active": true,
        "value": false,
        "option_fields": {"isUSResident": isUSResident}
      }
    ],
    "label":
        getLocale("Do you hold a US Permanent Resident Card / Green Card?"),
    "value": true,
    "regex": "",
    "expand": true,
    "required": true
  };

  var isUSCitizen = {
    "type": "switchButton",
    "options": [
      {
        "label": map["yes"],
        "active": true,
        "value": true,
        "option_fields": {"taxIdOrSecurityNo": taxIdOrSecurityNo}
      },
      {
        "label": map["no"],
        "active": true,
        "value": false,
        "option_fields": {"greenCardHolder": greenCardHolder}
      }
    ],
    "label": getLocale("Are you a US Citizen?"),
    "value": true,
    "regex": "",
    "expand": true,
    "required": true
  };

  var fatcaStatus = {
    "type": "option1",
    "label": getLocale("FATCA Status"),
    "value": "USPerson",
    "disabled": true,
    "size": {"textWidth": 40, "fieldWidth": 70, "emptyWidth": 12},
    "options": [
      {
        "label": getLocale("US Person"),
        "active": true,
        "value": "USPerson",
        "option_fields": {
          "notes": {
            "type": "paragraph",
            "style": bFontW5(),
            "isRequired": true,
            "column": false,
            "text": getLocale("Note: Please provide U.S. IRS W9 form")
          }
        }
      },
      {
        "label": getLocale("Non US Person"),
        "active": true,
        "value": "nonUSPerson"
      },
      {
        "label": getLocale("Recalcitrant"),
        "active": true,
        "value": "recalcitrant"
      }
    ]
  };

  var fatca = {
    "title": getLocale("Foreign Account Tax Compliance Act (FATCA)"),
    "mainTitle": false,
    "fields": {"isUSCitizen": isUSCitizen, "fatcaStatus": fatcaStatus},
    "enabled": false
  };

  var reasonnotintext = {
    "type": "text",
    "label": getLocale("Please explain why you are unable to provide a TIN"),
    "regex": "",
    "value": "",
    "required": true,
    "size": {"textWidth": 35, "fieldWidth": 75, "emptyWidth": 8},
    "maxLines": 3,
    "column": true,
    "sentence": true
  };

  var reasonnotin = {
    "type": "options2",
    "options": [
      {
        "label": getLocale(
            "TIN is not issued by the country/jurisdiction of tax residence"),
        "active": true,
        "value": "reasonA"
      },
      {
        "label": getLocale("TIN is not required by country of tax residence"),
        "active": true,
        "value": "reasonB"
      },
      {
        "label": getLocale("Unable to provide TIN"),
        "active": true,
        "value": "reasonC",
        "option_fields": {"reasonnotintext": reasonnotintext}
      }
    ],
    "label": getLocale("Please state reason"),
    "value": "",
    "regex": "",
    "size": {"textWidth": 25, "fieldWidth": 80, "emptyWidth": 12},
    "required": true
  };

  var tin = {
    "type": "number",
    "label": "TIN",
    "value": "",
    "regex": "",
    "required": true,
    "size": {"textWidth": 25, "fieldWidth": 80, "emptyWidth": 12}
  };

  var tinavailable = {
    "type": "switchButton",
    "options": [
      {
        "label": map["yes"],
        "active": true,
        "value": true,
        "option_fields": {"tin": tin}
      },
      {
        "label": map["no"],
        "active": true,
        "value": false,
        "option_fields": {"reasonnotin": reasonnotin}
      }
    ],
    "label": getLocale("Do you have the Taxpayor Identification Number (TIN)?"),
    "value": true,
    "regex": "",
    "expand": true,
    "required": true
  };

  dynamic crsCountry = [];
  countrylist.forEach((count) {
    if (count["value"] != "USA" && count["value"] != "MYS") {
      crsCountry.add(count);
    }
  });

  dynamic onlyMalaysia = [];
  countrylist.forEach((count) {
    if (count["value"] == "MYS") {
      onlyMalaysia.add(count);
    }
  });

  var country = {
    "type": "option1",
    "options": countrylist,
    "label": getLocale("Country"),
    "value": "MYS",
    "regex": "",
    "expand": true,
    "required": true
  };

  var countryMYS = {
    "type": "option1",
    "options": onlyMalaysia,
    "label": getLocale("Country"),
    "value": "MYS",
    "regex": "",
    "expand": true,
    "required": true
  };

  var crscountry = {
    "type": "option1",
    "options": crsCountry,
    "label": getLocale("Country/Jurisdiction of Tax Residence"),
    "value": "",
    "regex": "",
    "expand": true,
    "required": true
  };

  var crs = {
    "title": getLocale("Common Reporting Standard (CRS)"),
    "mainTitle": false,
    "fields": {"crscountry": crscountry, "tinavailable": tinavailable},
    "enabled": false
  };

  var preferlanguage = {
    "type": "option1",
    "options": [
      {"label": "English", "active": true, "value": "ENG"},
      {"label": "Malay", "active": true, "value": "BMY"},
      // {"label": "Chinese", "active": true, "value": "CHN"},
      // {"label": "Tamil", "active": true, "value": "TAM"},
      // {"label": "Others", "active": true, "value": "OTH"},
    ],
    "label": getLocale("Preferred Language"),
    "value": "",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option")
  };

  var defaultCountry = {
    "type": "option1",
    "options": countrylist,
    "label": getLocale("Country of Birth"),
    "value": "MYS",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option"),
  };

  var countryofbirth = {
    "type": "option1",
    "options": countrylist,
    "label": getLocale("Country of Birth"),
    "value": "",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option"),
  };

  var defaultNationality = {
    "type": "option1",
    "options": nationalitylist,
    "label": getLocale("Nationality"),
    "value": "458",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option")
  };

  var nationality = {
    "type": "option1",
    "options": nationalitylist,
    "label": getLocale("Nationality"),
    "value": "",
    "regex": "",
    "required": true,
    "placeholder": getLocale("Please select an option")
  };

  dynamic nric = {
    "label": map["nric"],
    "active": true,
    "value": "nric",
    "option_fields": {
      "nric": {
        "type": "number",
        "label": map["nric"],
        "value": "",
        "regex": "",
        "required": true,
        "maxLength": 12,
        "size": {}
      },
      "oldic": {
        "type": "text",
        "label": map["oldic"],
        "value": "",
        "regex": "",
        "enabled": false,
        "required": false,
        "size": {}
      },
      "countryofbirth": defaultCountry,
      "nationality": defaultNationality
    }
  };

  var passport = {
    "label": map["passport"],
    "value": "passport",
    "active": true,
    "option_fields": {
      "passport": {
        "type": "text",
        "label": map["passport"],
        "value": "",
        "regex": "",
        "required": true,
        "maxLength": 20,
        "size": {}
      },
      "countryofbirth": countryofbirth,
      "nationality": nationality
    }
  };

  var birthcert = {
    "label": map["birthcert"],
    "value": "birthcert",
    "active": false,
    "option_fields": {
      "nric": {
        "type": "number",
        "label": map["nric"],
        "value": "",
        "regex": "",
        "required": true,
        "maxLength": 12,
        "size": {}
      },
      "oldic": {
        "type": "text",
        "label": map["oldic"],
        "value": "",
        "regex": "",
        "enabled": false,
        "required": false,
        "size": {}
      },
      "birthcert": {
        "type": "text",
        "label": map["birthcert"],
        "value": "",
        "regex": "",
        "required": true,
        "size": {}
      },
      "countryofbirth": countryofbirth,
      "nationality": nationality
    }
  };

  var mypr = {
    "label": map["mypr"],
    "value": "mypr",
    "active": true,
    "option_fields": {
      "mypr": {
        "type": "number",
        "label": map["mypr"],
        "value": "",
        "regex": "^[0-9]{12}\$",
        "required": true,
        "size": {}
      },
      "countryofbirth": countryofbirth,
      "nationality": nationality
    }
  };

  var policeic = {
    "label": map["policeic"],
    "value": "policeic",
    "active": true,
    "option_fields": {
      "nric": {
        "type": "number",
        "label": map["nric"],
        "value": "",
        "regex": "",
        "required": true,
        "maxLength": 12,
        "size": {}
      },
      "oldic": {
        "type": "text",
        "label": map["oldic"],
        "value": "",
        "regex": "",
        "enabled": false,
        "required": false,
        "size": {}
      },
      "policeic": {
        "type": "text",
        "label": map["policeic"],
        "value": "",
        "regex": "",
        "required": true,
        "size": {}
      },
      "countryofbirth": defaultCountry,
      "nationality": defaultNationality
    }
  };

  var armyic = {
    "label": map["armyic"],
    "value": "armyic",
    "active": true,
    "option_fields": {
      "nric": {
        "type": "number",
        "label": map["nric"],
        "value": "",
        "regex": "",
        "required": true,
        "maxLength": 12,
        "size": {}
      },
      "oldic": {
        "type": "text",
        "label": map["oldic"],
        "value": "",
        "regex": "",
        "enabled": false,
        "required": false,
        "size": {}
      },
      "armyic": {
        "type": "text",
        "label": map["armyic"],
        "value": "",
        "regex": "",
        "required": true,
        "size": {}
      },
      "countryofbirth": defaultCountry,
      "nationality": defaultNationality
    }
  };

  var identitytype = {
    "type": "option1",
    "label": getLocale("Identity Type"),
    "value": "nric",
    "subfields": true,
    "required": true,
    "options": [
      json.decode(json.encode(nric)),
      json.decode(json.encode(birthcert)),
      json.decode(json.encode(mypr)),
      json.decode(json.encode(passport)),
      json.decode(json.encode(policeic)),
      json.decode(json.encode(armyic))
    ]
  };

  var gender = {
    "type": "option2",
    "options": [
      {
        "label": getLocale("Male"),
        "active": true,
        "value": "Male"
      }, //map["male"]
      {
        "label": getLocale("Female"),
        "active": true,
        "value": "Female"
      } //map["female"]
    ],
    "label": getLocale("Gender"),
    "value": "",
    "regex": "",
    "required": true
  };

  var dob = {
    "type": "date",
    "label": getLocale("Date of Birth"),
    "value": "",
    "regex": "",
    "required": true
  };

  var raceoption = getMasterlookup(type: "Race");
  raceoption.forEach((option) {
    if (option["value"] == "CCO1") {
      option["option_fields"] = {
        "racedesc": {
          "type": "text",
          "label": getLocale("Please specify"),
          "value": "",
          "regex": "",
          "size": {},
          "required": true
        }
      };
    }
  });

  var race = {
    "type": "option1",
    "options": raceoption,
    "label": getLocale("Race"),
    "value": "",
    "regex": "",
    "placeholder": getLocale("Please select an option"),
    "required": true
  };

  var muslim = {
    "type": "option2",
    "options": [
      {"label": getLocale("Yes"), "active": true, "value": true},
      {"label": getLocale("No"), "active": true, "value": false}
    ],
    "label": getLocale("Muslim"),
    "value": "",
    "regex": "",
    "required": true
  };

  var numberchildren = {
    "type": "number",
    "label": getLocale("Number of Children"),
    "value": "",
    "regex": "",
    "required": true,
    "size": {},
    "maxLength": 2
  };

  var maritalOptions = getMasterlookup(type: "MaritalSt");
  for (var i = 0; i < maritalOptions.length; i++) {
    if (maritalOptions[i]["value"] == "1" ||
        maritalOptions[i]["value"] == "3" ||
        maritalOptions[i]["value"] == "4") {
      maritalOptions[i]["option_fields"] = {"numberofchildren": numberchildren};
    }
  }

  var maritalstatus = {
    "type": "option1",
    "options": maritalOptions,
    "label": getLocale("Marital Status"),
    "value": "",
    "regex": "",
    "placeholder": getLocale("Please select an option"),
    "required": true
  };

  var smoking = {
    "type": "option2",
    "options": [
      {"label": getLocale("Yes"), "active": true, "value": true},
      {"label": getLocale("No"), "active": true, "value": false}
    ],
    "label": getLocale("Smoking"),
    "value": "",
    "regex": "",
    "required": true
  };

  var address = {
    "type": "text",
    "label": getLocale("Address line 1"),
    "value": "",
    "regex": "",
    "required": true,
    "maxLength": 50,
    "size": {}
  };

  var address1 = {
    "type": "text",
    "label": getLocale("Address line 2"),
    "value": "",
    "regex": "",
    "required": false,
    "maxLength": 50,
    "size": {}
  };

  var postcode = {
    "type": "number",
    "label": getLocale("Postcode"),
    "value": "",
    "regex": "",
    "required": true,
    "size": {},
    "maxLength": 5
  };

  var cityList = getAllStateCity("city");

  var city = {
    "type": "option1",
    "label": getLocale("City"),
    "options": cityList,
    "value": "",
    "regex": "",
    "required": true,
    "size": {}
  };

  var state = {
    "type": "option1",
    "label": getLocale("State"),
    "options": getAllStateCity("state"),
    "value": "",
    "regex": "",
    "required": true,
    "size": {}
  };

  var mailing = {
    "type": "switch",
    "value": true,
    "revertvalue": true,
    "label": getLocale("This is my mailing address"),
    "regex": "",
    "required": true,
    "option_fields": {
      "mailingaddress": json.decode(json.encode(address)),
      "mailingaddress1": json.decode(json.encode(address1)),
      "mailingpostcode": json.decode(json.encode(postcode)),
      "mailingcity": json.decode(json.encode(city)),
      "mailingstate": json.decode(json.encode(state)),
      "mailingcountry": json.decode(json.encode(country))
    }
  };

  var email = {
    "type": "email",
    "label": getLocale("Email"),
    "value": "",
    "regex": "",
    "required": true,
    "size": {},
  };

  var hometel = {
    "type": "number",
    "label": getLocale("Home Telephone No."),
    "value": "",
    "regex": "",
    "maxLength": 13,
    "required": false,
    "size": {},
  };

  var officetel = {
    "type": "number",
    "label": getLocale("Office Telephone No."),
    "value": "",
    "regex": "^[0-9]{10,13}\$",
    "maxLength": 13,
    "required": false,
    "size": {},
  };

  var mobileno = {
    "type": "telnumber",
    "label": getLocale("Mobile No. 1"),
    "prefix": "+60 ",
    "value": "",
    "regex": "",
    "maxLength": 12,
    "required": true,
    "size": {},
    "placeholder": "126669898"
  };

  var mobileno2 = {
    "type": "number",
    "label": getLocale("Mobile No. 2"),
    "value": "",
    "regex": "^[0-9]{10,13}\$",
    "maxLength": 13,
    "required": false,
    "size": {},
    "placeholder": "60126669898"
  };

  var occupation = {
    "type": "option1",
    "label": getLocale("Occupation"),
    "value": "",
    "regex": "",
    "options": [],
    "required": true,
    "placeholder": getLocale("Please select an occupation")
  };

  var parttime = {
    "type": "option1",
    "label": getLocale("Part Time (if any)"),
    "value": "",
    "regex": "",
    "options": [],
    "required": false,
    "placeholder": getLocale("Please select an occupation")
  };

  var natureofbusiness = {
    "type": "text",
    "label": getLocale("Nature of business"),
    "value": "",
    "regex": "",
    "size": {},
    "required": false,
    "maxLength": 30
  };

  var companyname = {
    "type": "text",
    "label": getLocale("Company Name"),
    "value": "",
    "regex": "",
    "required": true,
    "maxLength": 50,
    "size": {}
  };

  var monthlyincome = {
    "type": "currency",
    "label": getLocale("Monthly Income"),
    "value": "",
    "prefix": "RM ",
    "regex": "",
    "required": true,
    "maxLength": 12,
    "size": {}
  };

  var sourceoffundlist = getMasterlookup(type: "SourceofFund");

  sourceoffundlist.forEach((option) {
    if (option["value"] == "8") {
      option["option_fields"] = {
        "othersource": {
          "type": "text",
          "label": getLocale("Please specify"),
          "value": "",
          "regex": "",
          "size": {},
          "required": true,
          "maxLength": 50
        }
      };
    }
  });

  var sourceoffund = {
    "type": "option1",
    "label": getLocale("Source"),
    "value": "1",
    "subfields": true,
    "required": true,
    "options": sourceoffundlist,
  };

  var jobtitle = {
    "type": "option2",
    "enabled": true,
    "subfields": true,
    "options": [
      {
        "label": map["selfemployed"],
        "value": "selfemployed",
        "active": true,
        "option_fields": {
          "natureofbusiness": natureofbusiness,
          "companyname": companyname,
          "monthlyincome": monthlyincome
        }
      },
      {
        "label": map["employed"],
        "value": "employed",
        "active": true,
        "option_fields": {
          "occupationDisplay": occupation,
          "companyname": companyname,
          "monthlyincome": monthlyincome
        }
      },
      {
        "label": map["busniessowner"],
        "value": "busniessowner",
        "active": true,
        "option_fields": {
          "companyname": companyname,
        }
      },
      {"label": map["notworking"], "active": true, "value": "notworking"},
    ],
    "label": getLocale("I am"),
    "value": "employed",
    "regex": "",
    "required": true
  };

  var bankname = {
    "type": "option1",
    "label": getLocale("Bank Name"),
    "value": "",
    "regex": "",
    "required": true,
    "options": getBankList(),
    "placeholder": getLocale("Please select an option")
  };

  var bankaccounttype = {
    "type": "option1",
    "label": getLocale("Account Type"),
    "value": "",
    "regex": "",
    "required": true,
    "options": getMasterlookup(type: "AccountType"),
    "placeholder": getLocale("Please select an option")
  };

  var bankaccounttype2 = {
    "type": "option2",
    "label": getLocale("Account Type"),
    "value": "",
    "regex": "",
    "required": true,
    "options": [
      {"label": getLocale("Saving"), "active": true, "value": "Saving"},
      {"label": getLocale("Current"), "active": true, "value": "Current"}
    ],
    "placeholder": getLocale("Please select an option")
  };

  var accountno = {
    "type": "number",
    "label": "${getLocale("Account No")}.",
    "regex": "",
    "value": "",
    "maxLength": 17,
    "required": true
  };

  var creditterminfo = {
    "type": "info",
    "label": getLocale("View Terms and Conditions"),
    "required": false,
    "show": false,
    "paddingBottom": 0,
    "paddingTop": gFontSize * 0.7,
    "paddingRight": gFontSize * 1.5,
    "text": """
    <br>
<div><b>${getLocale("Terms & Condition")}</b></div>
<p>a. ${getLocale("Direct Credit facility is only applicable to the")} ${getLocale("Policy Owner", entity: true)}${getLocale("'s bank account")}.</p><br><br>
<p>b. ${getLocale("Bank account must be maintained in Malaysia. In the case of an account outside Malaysia, please make a written request, providing account details to")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)}. ${getLocale("Etiqa Life Insurance Berhad", entity: true)} ${getLocale("reserves the right to agree or decline the request, and will advise you in writing")}</p><br><br>
<p>c. ${getLocale("The")} ${getLocale("Policy Owner", entity: true)} ${getLocale("shall furnish a copy of the bank passbook or bank statement for verification of account details. In the event of invalid/inaccurate details and payment is credited based on these details, then the payment is deemed as full payment and")} ${getLocale("Etiqa Insurance", entity: true)} ${getLocale("shall be released and fully discharged form further liability in respect of that payment")}.</p>
"""
  };

  var studying = {
    "type": "option2",
    "subfields": true,
    "options": [
      {
        "label": map["yes"],
        "value": true,
        "active": true,
        "option_fields": {
          "educationlv": {
            "type": "option1",
            "options": getMasterlookup(type: "EducationLevel"),
            "label": getLocale("Education Level"),
            "value": "kindergarten",
            "regex": "",
            "required": true
          }
        }
      },
      {"label": map["no"], "active": true, "value": false}
    ],
    "label": getLocale("Still Studying?"),
    "value": "",
    "regex": "",
    "required": true
  };

  // Education level
  var belowsecondary = {
    "label": map["belowsecondary"],
    "value": "1",
    "active": true,
    "options_field": {},
  };

  var secondary = {
    "label": map["secondary"],
    "value": "2",
    "active": true,
    "options_field": {},
  };

  var diploma = {
    "label": map["diploma"],
    "value": "3",
    "active": true,
    "options_field": {},
  };

  var bachelor = {
    "label": map["bachelor"],
    "value": "4",
    "active": true,
    "options_field": {},
  };

  var master = {
    "label": map["master"],
    "value": "5",
    "active": true,
    "options_field": {},
  };

  var doctorate = {
    "label": map["doctorate"],
    "value": "6",
    "active": true,
    "options_field": {},
  };

  var profqualification = {
    "label": map["profqualification"],
    "value": "7",
    "active": true,
    "options_field": {},
  };

  var notapplicable = {
    "label": map["notapplicable"],
    "value": "8",
    "active": true,
    "options_field": {},
  };

  var educationlevel = {
    "type": "option1",
    "label": getLocale("Education"),
    "value": "1",
    "subfields": true,
    "required": true,
    "options": [
      json.decode(json.encode(belowsecondary)),
      json.decode(json.encode(secondary)),
      json.decode(json.encode(diploma)),
      json.decode(json.encode(bachelor)),
      json.decode(json.encode(master)),
      json.decode(json.encode(doctorate)),
      json.decode(json.encode(profqualification)),
      json.decode(json.encode(notapplicable))
    ]
  };

  var sameasparent = {
    "type": "switch",
    "value": true,
    "revertvalue": true,
    "subfields": true,
    "option_fields": {
      "address": address,
      "address1": address1,
      "postcode": postcode,
      "city": city,
      "state": state,
      "country": country,
      "mailing": mailing
    },
    "label":
        "${getLocale("Same as")} ${getLocale("Policy Owner", entity: true)}",
    "regex": "",
    "required": true
  };

  var sameaspo = {
    "type": "switch",
    "value": false,
    "revertvalue": true,
    "subfields": true,
    "option_fields": {
      "address": address,
      "address1": address1,
      "postcode": postcode,
      "city": city,
      "state": state,
      "country": country,
      "mailing": mailing
    },
    "label":
        "${getLocale("Same as")} ${getLocale("Policy Owner", entity: true)}",
    "regex": "",
    "required": true
  };

  var childRelationList = [];
  var spouseRelationList = [];
  var payorRelationList = [];

  var relationshipList = getMasterlookup(type: "Relationship");
  relationshipList.forEach((option) {
    if (option["remark"] != null) {
      dynamic remark = jsonDecode(option["remark"]);
      if (remark["BuyFor"] == "Children") {
        childRelationList.add(option);
      }
      if (remark["BuyFor"] == "Spouse") {
        spouseRelationList.add(option);
      }
      if (remark["type"] == "payor") {
        payorRelationList.add(option);
      }
    }
  });
  var relationshipChild = {
    "type": "option1",
    "options": childRelationList,
    "label": getLocale("Relationship with Child"),
    "value": "",
    "regex": "",
    "required": true
  };

  var relationshipSpouse = {
    "type": "option1",
    "options": spouseRelationList,
    "label":
        "${getLocale("Relationship with")} ${getLocale("Life Insured", entity: true)}",
    "value": "",
    "regex": "",
    "required": true
  };

  var relationshipPO = {
    "type": "option1",
    "options": getMasterlookup(type: "Relationship"),
    "label":
        "${getLocale("Relationship with")} ${getLocale("Policy Owner", entity: true)}",
    "value": "",
    "regex": "",
    "required": true
  };

  var relationshipPayor = {
    "type": "option1",
    "options": payorRelationList,
    "label":
        "${getLocale("Relationship with")} ${getLocale("Policy Owner", entity: true)}",
    "value": "",
    "regex": "",
    "required": true
  };

  var whopaying = {
    "type": "option1",
    "label": getLocale("Who is Paying"),
    "value": "",
    "regex": "",
    "placeholder": getLocale("Please select an option"),
    "required": true,
    "subfields": true,
    "options": [
      {
        "label":
            '${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}',
        "active": true,
        "value": "policyOwner"
      },
      {
        "label": getLocale("Policy Owner", entity: true),
        "active": false,
        "value": "policyOwner"
      },
      {
        "label": getLocale("Life Insured", entity: true),
        "active": false,
        "value": "lifeInsured"
      },
      {
        "label": map["othersrelation"],
        "value": "othersrelation",
        "active": true,
        "option_fields": {
          "relationship": relationshipPayor,
          "salutation": salutation,
          "name": name,
          "identitytype": identitytype,
          "gender": gender,
          "dob": dob,
          "maritalstatus": maritalstatus
        }
      }
    ]
  };

  var signature = {
    "type": "signature",
    "label": "",
    "headerLabel": "Signature",
    "value": "",
    "required": true
  };

  var witness = {
    "type": "option1",
    "label": getLocale("Who is the witness of the application?"),
    "value": "agent",
    "required": true,
    "column": true,
    "subfields": true,
    "options": [
      {
        "label": getLocale("Agent"),
        "active": true,
        "value": "agent",
      },
      {
        "label": getLocale("Others"),
        "value": "othersrelation",
        "active": true,
        "option_fields": {
          "salutation": salutation,
          "name": name,
          "identitytype": identitytype,
          "gender": gender,
          "dob": dob,
          "remote": {
            "type": "switchRemote",
            "label": getLocale("Prefer to capture his/her signature remotely"),
            "value": false,
            "enabled": true,
            "required": true
          },
          "signature": signature
        }
      }
    ]
  };

  var yeartosupport = {
    "type": "number",
    "label": getLocale("Year(s) to Support"),
    "value": "",
    "regex": "",
    "required": true,
    "maxLength": 2,
    "placeholder": "",
    "size": {}
  };

  var percentage = {
    "type": "sliderInt",
    "label": getLocale("Percentage/Share %"),
    "indicator": "%",
    "min": 0.0,
    "max": 100.0,
    "required": true,
    "value": 0.0,
    "options": [
      "1",
      "50",
      "100",
    ]
  };

  var planpolicyowner = {
    "type": "text",
    "label": getLocale("Policy Owner/Takaful Participant"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var agenextbirthdate = {
    "type": "text",
    "label": getLocale("Your age at the next birthdate"),
    "value": "",
    "size": {},
    "required": false,
    "column": true,
    "disableEdit": true
  };

  var plancompany = {
    "type": "text",
    "label": getLocale("Insurance Company/Takaful Operator"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var planname = {
    "type": "text",
    "label": getLocale("Plan Name"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var plantype = {
    "type": "text",
    "label": getLocale("Type of Plan"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var planpremiumamount = {
    "type": "currency",
    "label": getLocale("Premium/Contribution Amount"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planstartdate = {
    "type": "date",
    "label": getLocale("Start Date"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var planmaturitydate = {
    "type": "date",
    "label": getLocale("Maturity Date"),
    "value": "",
    "minimum": DateTime.now().subtract(const Duration(days: 1)),
    "maximum": DateTime.now().add(const Duration(days: 365 * 100)),
    "size": {},
    "required": true,
    "column": true
  };

  var planamountmaturity = {
    "type": "currency",
    "label": getLocale("Amount Available at Maturity"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planlumpsummaturity = {
    "type": "currency",
    "label": getLocale("Projected Lump Sum at Maturity"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planincomematurity = {
    "type": "currency",
    "label": getLocale("Projected Annual Income at Maturity"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planfeematurity = {
    "type": "currency",
    "label": getLocale("Projected Value of Fees Paid at Maturity"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var additionalbenefit = {
    "maxLines": 3,
    "type": "text",
    "label": getLocale("Additional Benefits (if any)"),
    "enabled": true,
    "value": "",
    "required": false,
    "column": true,
    "sentence": true,
  };

  var planpaymentmode = {
    "type": "option1",
    "options": [
      {"label": getLocale("Monthly"), "active": true, "value": "monthly"},
      {"label": getLocale("Quarterly"), "active": true, "value": "quarterly"},
      {
        "label": getLocale("Half Quarterly"),
        "active": true,
        "value": "halfquarterly"
      },
      {"label": getLocale("Yearly"), "active": true, "value": "yearly"},
    ],
    "label": getLocale("Payment Frequency"),
    "value": "",
    "regex": "",
    "required": true,
    "column": true,
    "placeholder": getLocale("Please select an option")
  };

  var planlifeinsured = {
    "type": "text",
    "label": getLocale("Life Insured/Person Covered"),
    "value": "",
    "size": {},
    "required": true,
    "column": true
  };

  var planpremiumcontribution = {
    "type": "currency",
    "label": getLocale("Premium/Contribution Amount"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "prefix": "RM "
  };

  var plandeathbenefit = {
    "type": "currency",
    "label": getLocale("Death Benefit"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var plandisabilitybenefit = {
    "type": "currency",
    "label": getLocale("Disability Benefit"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var plancibenefit = {
    "type": "currency",
    "label": getLocale("Criticall Illness Benefit"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planroomboard = {
    "type": "currency",
    "label": getLocale("Room and Board"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 8,
    "prefix": "RM "
  };

  var planannuallimit = {
    "type": "currency",
    "label": getLocale("Overall Annual Limit"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var planlifelimit = {
    "type": "currency",
    "label": getLocale("Overall Lifetime Limit"),
    "value": "",
    "size": {},
    "required": true,
    "column": true,
    "maxLength": 12,
    "prefix": "RM "
  };

  var plancoinsurance = {
    "type": "number",
    "label":
        "${getLocale("Co-insurance")} (%) / ${getLocale("Self-deductible")} (RM)",
    "value": "",
    "size": {},
    "required": true,
    "column": true,
  };

  return {
    "salutation": salutation,
    "name": name,
    "countryofbirth": countryofbirth,
    "nationality": nationality,
    "identitytype": identitytype,
    "gender": gender,
    "dob": dob,
    "race": race,
    "muslim": muslim,
    "maritalstatus": maritalstatus,
    "smoking": smoking,
    "address": address,
    "address1": address1,
    "postcode": postcode,
    "city": city,
    "state": state,
    "country": countryMYS,
    "mailing": mailing,
    "hometel": hometel,
    "officetel": officetel,
    "mobileno": mobileno,
    "mobileno2": mobileno2,
    "email": email,
    "jobtitle": jobtitle,
    "natureofbusiness": natureofbusiness,
    "occupation": occupation,
    "companyname": companyname,
    "parttime": parttime,
    "monthlyincome": monthlyincome,
    "educationlevel": educationlevel,
    "sourceoffund": sourceoffund,
    "bankname": bankname,
    "accountno": accountno,
    "bankaccounttype": bankaccounttype,
    "bankaccounttype2": bankaccounttype2,
    "creditterminfo": creditterminfo,
    "studying": studying,
    "whopaying": whopaying,
    "relationshipChild": relationshipChild,
    "relationshipSpouse": relationshipSpouse,
    "relationshipPO": relationshipPO,
    "yeartosupport": yeartosupport,
    "sameasparent": sameasparent,
    "sameaspo": sameaspo,
    "percentage": percentage,
    "witness": witness,
    "fatca": fatca,
    "crs": crs,
    "preferlanguage": preferlanguage,
    "planpolicyowner": planpolicyowner,
    "agenextbirthdate": agenextbirthdate,
    "plancompany": plancompany,
    "planname": planname,
    "plantype": plantype,
    "planpremiumamount": planpremiumamount,
    "planstartdate": planstartdate,
    "planmaturitydate": planmaturitydate,
    "planamountmaturity": planamountmaturity,
    "planlumpsummaturity": planlumpsummaturity,
    "planincomematurity": planincomematurity,
    "planfeematurity": planfeematurity,
    "additionalbenefit": additionalbenefit,
    "planpaymentmode": planpaymentmode,
    "planlifeinsured": planlifeinsured,
    "planpremiumcontribution": planpremiumcontribution,
    "plandeathbenefit": plandeathbenefit,
    "plandisabilitybenefit": plandisabilitybenefit,
    "plancibenefit": plancibenefit,
    "planroomboard": planroomboard,
    "planannuallimit": planannuallimit,
    "planlifelimit": planlifelimit,
    "plancoinsurance": plancoinsurance,
  };
}

dynamic getInputedData(inputList, {bool specialConvert = false}) {
  Map<String, dynamic> input = {};
  for (var key in inputList.keys) {
    if (inputList[key] is! Map) continue;
    if (inputList[key]["fields"] != null &&
        inputList[key]["titleAsKey"] != null &&
        inputList[key]["titleAsKey"]) {
      input[key] = getEachInputedData(inputList[key]["fields"],
          specialConvert: specialConvert);
      if (input[key].isEmpty) {
        input.remove(key);
      }
    } else if (inputList[key]["fields"] != null) {
      input.addAll(getEachInputedData(inputList[key]["fields"],
          specialConvert: specialConvert));
    } else {
      input.addAll(
          getEachInputedData(inputList, specialConvert: specialConvert));
    }
  }
  return input;
}

dynamic getEachInputedData(inputList, {bool specialConvert = false}) {
  Map<String, dynamic> input = {};
  for (var key in inputList.keys) {
    var obj = inputList[key];
    if (obj is! Map) continue;
    var commType = [
      "text",
      "number",
      "telnumber",
      "email",
      "date",
      "radiocheck",
      "numberpicker",
      "numberpickerdouble",
      "camera",
      "signature"
    ];

    if (key == "oldic") {
      var nric = inputList["nric"];
      if (nric["value"] != null &&
          nric["value"] != "" &&
          nric["value"].length == 12) {
        var year = nric["value"].substring(0, 2);
        if (int.parse(year) > 50) {
          year = "19$year";
        } else {
          year = "20$year";
        }
        if (int.parse(year) < 1977) {
          obj["enabled"] = true;
          obj["required"] = true;
        } else {
          obj["enabled"] = false;
          obj["required"] = false;
        }
      }
    }

    if (obj["enabled"] != null && !obj["enabled"]) {
      continue;
    } else if (obj["error"] != null && !obj["error"].isEmpty) {
      input[key] = null;
      continue;
    } else if (obj["type"] != null) {
      var type = obj["type"];
      if (type.indexOf("info") > -1) {
        continue;
      } else if (type.indexOf("paragraph") > -1) {
        continue;
      } else if (obj["required"] == false && obj["value"] == "") {
        input[key] = "";
      } else if (obj["required"] != null &&
          obj["required"] &&
          (obj["value"] == null || obj["value"] == "")) {
        input[key] = null;
      } else if (commType.contains(type)) {
        if (obj["required"] != null && obj["required"]) {
          if (obj["value"] == null ||
              (obj["value"] is! bool &&
                  obj["value"] is! num &&
                  obj["value"].isEmpty)) {
            input[key] = null;
          } else {
            input[key] = (specialConvert && obj["value"] is String)
                ? convertSpecialCharacterToXmlString(obj["value"], true)
                : obj["value"];
          }
        } else {
          input[key] = (specialConvert && obj["value"] is String)
              ? convertSpecialCharacterToXmlString((obj["value"] ?? ""), true)
              : (obj["value"] ?? "");
        }
        if (obj["option_fields"] != null) {
          input.addAll(getEachInputedData(obj["option_fields"]));
        }
      } else if (type.indexOf("option") > -1) {
        int index = obj["options"]
            .indexWhere((option) => option["value"] == obj["value"]);
        var ops = index > -1 ? obj["options"][index] : null;
        if (obj["error"] != null) {
          input[key] = null;
        } else if (obj["value"] != null && obj["value"] is bool) {
          input[key] = obj["value"];
        } else {
          input[key] = obj["value"] == null || obj["value"].isEmpty
              ? null
              : obj["value"];
        }
        if (ops != null && ops["option_fields"] != null) {
          input.addAll(getEachInputedData(ops["option_fields"]));
        }
      } else if (type == "question") {
        if (input[key] == null) input[key] = {};
        input[key]["QuesNo"] = key;
        input[key]["AnswerValue"] = obj["value"];
        input[key]["AnswerXML"] = "";

        if (obj["options"] != null) {
          int index = obj["options"]
              .indexWhere((option) => option["value"] == obj["value"]);
          var ops = index > -1 ? obj["options"][index] : null;

          if (ops != null && ops["option_fields"] != null) {
            input[key]["AnswerXML"] = obj["AnswerXML"];
          }
          if (input[key]["AnswerValue"] && input[key]["AnswerXML"] == "") {
            if (key != "1333" && key != "1334" && key != "1335") {
              input[key]["empty"] = null;
            }
          }
        }
      } else if (type == "switch") {
        if (obj["option_fields"] != null && obj["value"] != null) {
          input[key] = obj["value"];
          if (obj["revertvalue"] != null &&
              obj["revertvalue"] &&
              !obj["value"]) {
            input.addAll(getEachInputedData(obj["option_fields"]));
          } else if (obj["value"] &&
              obj["revertvalue"] != null &&
              !obj["revertvalue"]) {
            input.addAll(getEachInputedData(obj["option_fields"]));
          }
        }
      } else if (type == "switchButton" || type == "switchRemote") {
        input[key] = obj["value"];
        if (obj["options"] != null) {
          int index = obj["options"]
              .indexWhere((option) => option["value"] == obj["value"]);
          var ops = index > -1 ? obj["options"][index] : null;
          if (ops != null && ops["option_fields"] != null) {
            input.addAll(getEachInputedData(ops["option_fields"]));
          }
        }
      } else if (type.indexOf("slider") > -1) {
        if (type == "sliderInt") {
          input[key] = obj["value"].round().toInt();
        } else if (type == "sliderDouble") {
          input[key] = num.parse(obj["value"].toStringAsFixed(2));
        } else {
          input[key] = obj["value"];
        }
      } else if (obj["value"] != null) {
        input[key] = obj["value"];
      }
    } else if (obj["option_fields"] != null) {
      input[key] = getEachInputedData(obj["option_fields"]);
    } else if (obj["value"] != null) {
      input[key] = obj["value"];
    }
  }

  return input;
}

dynamic generateDataToObjectValue(mainData, object,
    {bool specialConvert = false}) {
  if (mainData == null || object == null) {
    return;
  }
  for (var key in object.keys) {
    if (object[key] is! Map) continue;
    if (object[key]["fields"] != null) {
      generateEachDataToObjectValue(mainData, object[key]["fields"],
          specialConvert: specialConvert);
    } else {
      generateEachDataToObjectValue(mainData, object,
          specialConvert: specialConvert);
    }
  }
}

dynamic generateEachDataToObjectValue(mainData, object,
    {bool specialConvert = false}) {
  for (var key in object.keys) {
    if (object[key] is! Map) continue;
    var obj = object[key];
    var type = obj != null && obj is Map ? obj["type"] : null;
    if (type != null) {
      var commType = [
        "text",
        "number",
        "telnumber",
        "email",
        "date",
        "currency",
        "sliderInt",
        "sliderDouble",
        "radiocheck",
        "numberpicker",
        "numberpickerdouble",
        "camera",
        "signature"
      ];
      if (type.indexOf("info") > -1) {
        continue;
      } else if (commType.contains(type)) {
        obj["value"] = mainData != null && mainData[key] != null
            ? (specialConvert
                ? convertSpecialCharacterToXmlString(mainData[key], false)
                : mainData[key])
            : obj["value"];
        if (obj["option_fields"] != null) {
          generateEachDataToObjectValue(mainData, obj["option_fields"]);
        }
      } else if (type == "optionList") {
        if (mainData[key] == null) {
          continue;
        }
        obj["value"] = mainData[key];
      } else if (type.indexOf("option") > -1) {
        if (mainData[key] == null) {
          continue;
        }
        int index = obj["options"]
            .indexWhere((option) => option["value"] == mainData[key]);

        var ops = index > -1 ? obj["options"][index] : null;
        if (index > -1) {
          obj["value"] = mainData[key];
        }

        if (ops != null && ops["option_fields"] != null) {
          generateEachDataToObjectValue(mainData, ops["option_fields"]);
        }
      } else if (type == "question") {
        if (mainData[key] != null && mainData[key] is Map) {
          if (obj["options"] != null) {
            int index = obj["options"].indexWhere(
                (option) => option["value"] == mainData[key]["AnswerValue"]);
            if (index > -1) {
              obj["value"] = mainData[key]["AnswerValue"];
            }
            obj["AnswerXML"] = mainData[key]["AnswerXML"];
          } else {
            obj["value"] = mainData[key]["AnswerValue"];
            obj["AnswerXML"] = mainData[key]["AnswerXML"];
          }
        }
      } else if (type == "switch") {
        if (obj["option_fields"] != null) {
          obj["value"] = mainData != null && mainData[key] != null
              ? mainData[key]
              : obj["value"];
          if (obj["value"] != null) {
            if (!obj["value"] &&
                obj["revertvalue"] != null &&
                obj["revertvalue"]) {
              generateEachDataToObjectValue(mainData, obj["option_fields"]);
            } else if (obj["value"] &&
                (obj["revertvalue"] == null || !obj["revertvalue"])) {
              generateEachDataToObjectValue(mainData, obj["option_fields"]);
            }
          } else if (obj["revertvalue"] != null && obj["revertvalue"]) {
            obj["value"] = true;
          } else {
            obj["value"] = false;
          }
        }
      } else if (type == "switchButton" || type == "switchRemote") {
        obj["value"] = mainData[key] ?? obj["value"];
        if (obj["options"] != null) {
          int index = obj["options"]
              .indexWhere((option) => option["value"] == mainData[key]);

          var ops = index > -1 ? obj["options"][index] : null;
          if (ops != null && ops["option_fields"] != null) {
            generateEachDataToObjectValue(mainData, ops["option_fields"]);
          }
        }
      } else if (obj["value"] != null) {
        obj["value"] = mainData[key];
      }
    } else if (obj != null && obj["titleAsKey"] != null && obj["titleAsKey"]) {
      if (obj["fields"] != null && mainData[key] != null) {
        generateEachDataToObjectValue(mainData[key], obj["fields"]);
      }
    } else if (mainData != null && mainData[key] != null) {
      if (obj["option_fields"] != null) {
        generateEachDataToObjectValue(mainData[key], obj["option_fields"]);
      } else {
        obj["value"] = mainData[key];
      }
    }
  }
}

dynamic getObjectByKey(object, key2) {
  dynamic obj;
  for (var key in object.keys) {
    if (object[key] is Map && object[key]["fields"] != null) {
      obj = getEachObjectByKey(object[key]["fields"], key2);
    } else {
      obj = getEachObjectByKey(object, key2);
    }
    if (obj != null) {
      break;
    }
  }
  return obj;
}

dynamic getEachObjectByKey(object, key2) {
  dynamic obj;
  for (var key in object.keys) {
    if (key == key2) {
      obj = object[key];
      break;
    } else if (object[key] is Map && object[key]["option_fields"] != null) {
      obj = getEachObjectByKey(object[key]["option_fields"], key2);
    } else if (object[key] is Map && object[key]["options"] != null) {
      for (var i = 0; i < object[key]["options"].length; i++) {
        if (object[key]["options"][i] is Map &&
            object[key]["options"][i]["option_fields"] != null) {
          obj = getEachObjectByKey(
              object[key]["options"][i]["option_fields"], key2);
          if (obj != null) {
            break;
          }
        }
      }
    }

    if (obj != null) {
      break;
    }
  }
  return obj;
}

dynamic replaceAllMapping(object) {
  if (object == null) return;

  if (object is List) {
    for (var i = 0; i < object.length; i++) {
      replaceAllMapping(object[i]);
    }
  } else if (object is Map) {
    for (var key in object.keys) {
      if (object[key] is Map) {
        replaceAllMapping(object[key]);
      } else if (object[key] is List) {
        replaceAllMapping(object[key]);
      } else {
        if (objMapping[object[key]] != null) {
          object[key] = objMapping[object[key]];
        }
      }
    }
  } else {}
}

String? convertSpecialCharacterToXmlString(String value, bool isEncode) {
  var converted = value;
  xmlMapping.forEach((key, value) {
    if (isEncode) {
      if (converted.contains(key)) {
        converted = converted.replaceAll(key, value);
      }
    } else {
      if (converted.contains(value)) {
        converted = converted.replaceAll(value, key);
      }
    }
  });
  return converted;
}

Map<String, String> xmlMapping = {
  "&": "&amp;",
  "<": "&It;",
  ">": "&gt;",
  "\"": "&quot;",
  "\u201c": "&quot;", //open single quote
  "\u201d": "&quot;", //close single quote
  "'": "&apos;",
  "\u2018": "&apos;", //open double quotes
  "\u2019": "&apos;" //close double quotes
};
