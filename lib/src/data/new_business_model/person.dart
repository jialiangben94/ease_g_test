import 'dart:convert';
import 'dart:io';

import 'package:ease/src/data/new_business_model/coverage.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/util/function.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Person {
  String? clientType;
  String? nric;
  final String? cltID;
  final String? leadID;
  String? name;
  String? gender;
  String? dob;
  int? age;
  bool? isJuvenile;
  bool? isSmoker;
  Occupation? occupation;
  final String? mobileNum;
  final String? mobileNum2;
  final String? homeNum;
  final String? bizNum;
  final String? email;
  final ClientAddress? address;
  String? maritalStatus;
  String? nationality;
  final double? monthlyIncome;
  final String? nameOfEmployer;
  final String? potentialArea;
  List<Coverage>? existingSavingInvestPlan;
  List<Coverage>? existingCoverage;
  List<Coverage>? existingMedicalPlan;
  List<Coverage>? existingRetirement;
  List<Coverage>? existingChildEdu;
  List<Coverage>? existingCoverageDisclosure;
  final bool? isInterestedInMedplan;
  final String? preferredMedCoverage;
  final bool? isPurchasedMedPlan;
  final String? purchasedMedPlanName;
  final String? prdRecReason;
  final String? investPreference;
  String? preferlanguage;

  Person(
      {this.clientType,
      this.nric,
      this.cltID,
      this.leadID,
      this.name,
      this.gender,
      this.dob,
      this.age,
      this.isJuvenile,
      this.isSmoker,
      this.occupation,
      this.mobileNum,
      this.mobileNum2,
      this.homeNum,
      this.bizNum,
      this.email,
      this.address,
      this.maritalStatus,
      this.nationality,
      this.monthlyIncome,
      this.nameOfEmployer,
      this.potentialArea,
      this.existingSavingInvestPlan,
      this.existingCoverage,
      this.existingMedicalPlan,
      this.existingRetirement,
      this.existingChildEdu,
      this.existingCoverageDisclosure,
      this.isInterestedInMedplan,
      this.preferredMedCoverage,
      this.isPurchasedMedPlan,
      this.purchasedMedPlanName,
      this.prdRecReason,
      this.investPreference,
      this.preferlanguage});

  Map<String, dynamic> toJson() {
    return {
      'clientType': clientType,
      'nric': nric,
      'CltId': cltID,
      'LeadID': leadID,
      'name': name,
      'gender': gender,
      'dob': dob,
      'age': age,
      'isJuvenile': isJuvenile,
      'smoking': isSmoker ?? false,
      'occupation': jsonEncode(occupation!.toJson()),
      'MobileNum': mobileNum,
      'MobileNum2': mobileNum2,
      'HomeNum': homeNum,
      'BizNum': bizNum,
      'Email': email,
      'Contact': address != null ? jsonEncode(address!.toJson()) : null,
      'MaritalStatus': maritalStatus,
      'Nationality': nationality,
      'MonthlyIncome': monthlyIncome,
      'NameOfEmployer': nameOfEmployer,
      'PotentialArea': potentialArea,
      'ExistingSavingInvestPlan': existingSavingInvestPlan != null
          ? existingSavingInvestPlan!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingCoverage': existingCoverage != null
          ? existingCoverage!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingMedicalPlan': existingMedicalPlan != null
          ? existingMedicalPlan!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingRetirement': existingRetirement != null
          ? existingRetirement!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingChildEdu': existingChildEdu != null
          ? existingChildEdu!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingCoverageDisclosure': existingCoverageDisclosure != null
          ? existingCoverageDisclosure!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'IsInterestedInMedplan': isInterestedInMedplan,
      'PreferredMedCoverage': preferredMedCoverage,
      'IsPurchasedMedPlan': isPurchasedMedPlan ?? false,
      'PurchasedMedPlanName': purchasedMedPlanName,
      'PrdRecReason': prdRecReason,
      'InvestPreference': investPreference,
      'preferlanguage': preferlanguage
    };
  }

  // JSON for quotation history API
  Map<String, dynamic> toJsonAPI() {
    String convertDOBFormat(String dob) {
      DateTime tempDate = DateFormat("dd.M.yyyy").parse(dob);
      String date = DateFormat("dd-MM-yyyy").format(tempDate);
      return date;
    }

    return {
      'clientType': clientType,
      'nric': nric,
      'name': name,
      'gender': gender,
      'dob': convertDOBFormat(dob!),
      'age': age,
      'isJuvenile': isJuvenile,
      'smoking': isSmoker ?? false,
      'occupation': occupation!.toJson(),
      'ExistingSavingInvestPlan': existingSavingInvestPlan != null
          ? existingSavingInvestPlan!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingCoverage': existingCoverage != null
          ? existingCoverage!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingMedicalPlan': existingMedicalPlan != null
          ? existingMedicalPlan!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingRetirement': existingRetirement != null
          ? existingRetirement!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingChildEdu': existingChildEdu != null
          ? existingChildEdu!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
      'ExistingCoverageDisclosure': existingCoverageDisclosure != null
          ? existingCoverageDisclosure!
              .map((data) => data.toJson())
              .toList(growable: false)
          : [],
    };
  }

  static Person fromJson(Map<String, dynamic> map) {
    return Person(
        clientType: map['clientType'],
        nric: map['nric'],
        cltID: map['CltId'],
        leadID: map['LeadID'],
        name: map['name'],
        gender: map['gender'],
        dob: map['dob'],
        age: map['age'],
        isJuvenile: map['isJuvenile'],
        isSmoker: map['smoking'] ?? false,
        occupation: Occupation.fromJson(jsonDecode(map['occupation'])),
        mobileNum: map['MobileNum'] ?? "",
        mobileNum2: map['MobileNum2'] ?? "",
        homeNum: map['HomeNum'] ?? "",
        bizNum: map['BizNum'] ?? "",
        email: map['Email'] ?? "",
        address: map['Contact'] != null
            ? ClientAddress.fromJson(jsonDecode(map['Contact']))
            : ClientAddress(),
        maritalStatus: map['MaritalStatus'] ?? "",
        nationality: map['Nationality'] ?? "",
        monthlyIncome: map['MonthlyIncome'] ?? 0,
        nameOfEmployer: map['NameOfEmployer'] ?? "",
        potentialArea: map['PotentialArea'] ?? "",
        existingSavingInvestPlan: map["ExistingSavingInvestPlan"] != null &&
                map["ExistingSavingInvestPlan"] != ""
            ? List<Coverage>.from(
                map["ExistingSavingInvestPlan"].map((x) => Coverage.fromMap(x)))
            : [],
        existingCoverage: map["ExistingCoverage"] != null && map["ExistingCoverage"] != ""
            ? List<Coverage>.from(
                map["ExistingCoverage"].map((x) => Coverage.fromMap(x)))
            : [],
        existingMedicalPlan:
            map["ExistingMedicalPlan"] != null && map["ExistingMedicalPlan"] != ""
                ? List<Coverage>.from(
                    map["ExistingMedicalPlan"].map((x) => Coverage.fromMap(x)))
                : [],
        existingRetirement:
            map["ExistingRetirement"] != null && map["ExistingRetirement"] != ""
                ? List<Coverage>.from(
                    map["ExistingRetirement"].map((x) => Coverage.fromMap(x)))
                : [],
        existingChildEdu: map["ExistingChildEdu"] != null && map["ExistingChildEdu"] != ""
            ? List<Coverage>.from(map["ExistingChildEdu"].map((x) => Coverage.fromMap(x)))
            : [],
        existingCoverageDisclosure: map["ExistingCoverageDisclosure"] != null && map["ExistingCoverageDisclosure"] != "" ? List<Coverage>.from(map["ExistingCoverageDisclosure"].map((x) => Coverage.fromMap(x))) : [],
        isInterestedInMedplan: map['IsInterestedInMedplan'] ?? false,
        preferredMedCoverage: map['PreferredMedCoverage'] ?? "",
        isPurchasedMedPlan: map['IsPurchasedMedPlan'] ?? false,
        purchasedMedPlanName: map['PurchasedMedPlanName'] ?? "",
        prdRecReason: map['PrdRecReason'] ?? "",
        investPreference: map['InvestPreference'] ?? "",
        preferlanguage: map['preferlanguage']);
  }

  // parse JSON from API
  static Future<Person> fromJsonFFF(Map<String, dynamic> map) async {
    Occupation? occ;
    if (map['ContactInd'] != null &&
        map['ContactInd']['OccupationCode'] != null) {
      await searchOccupationListByCode(map['ContactInd']['OccupationCode'])
          .then((value) {
        occ = value;
      });
    }

    int age =
        map['NRIC'] != null ? getAgeString(nricToDOB(map['NRIC']), false) : 0;
    String? dob;
    if (map['ContactInd'] != null && map['ContactInd']['BirthDt'] != null) {
      dob = map['ContactInd']['BirthDt'];
    } else {
      dob = map['NRIC'] != null ? nricToDOB(map['NRIC']) : null;
    }

    return Person(
        nric: map['NRIC'],
        cltID: map['CltId'],
        leadID: map['LeadID'],
        name: map['Name'],
        gender: map['Gender'],
        dob: dob,
        age: age,
        isJuvenile: age < 16,
        isSmoker: map['IsSmoker'],
        occupation: occ,
        mobileNum: map['MobileNum'] ?? "",
        mobileNum2: map['MobileNum2'] ?? "",
        homeNum: map['HomeNum'] ?? "",
        bizNum: map['BizNum'] ?? "",
        email: map['Email'] ?? "",
        address: map['Contact'] != null
            ? ClientAddress.fromJson(map['Contact'])
            : ClientAddress(),
        maritalStatus:
            map['ContactInd'] != null && map['ContactInd']['MaritalStatus'] != null
                ? map['ContactInd']['MaritalStatus']
                : "",
        nationality:
            map['ContactInd'] != null && map['ContactInd']['Nationality'] != null
                ? map['ContactInd']['Nationality']
                : "",
        monthlyIncome:
            map['ContactInd'] != null && map['ContactInd']['MonthlyIncome'] != null
                ? map['ContactInd']['MonthlyIncome']
                : 0,
        nameOfEmployer: map['ContactInd'] != null &&
                map['ContactInd']['NameOfEmployer'] != null
            ? map['ContactInd']['NameOfEmployer']
            : "",
        potentialArea: map['ContactInd'] != null && map['ContactInd'] != null
            ? map['PotentialArea']
            : "",
        existingSavingInvestPlan: map["ExistingSavingInvestPlan"] != null
            ? List<Coverage>.from(json
                .decode(map["ExistingSavingInvestPlan"])
                .map((x) => Coverage.fromMap2(x)))
            : [],
        existingCoverage: map["ExistingCoverageList"] != null
            ? List<Coverage>.from(map["ExistingCoverageList"].map((x) => Coverage.fromMap(x)))
            : [],
        existingMedicalPlan: map["ExistingMedicalPlan"] != null ? List<Coverage>.from(json.decode(map["ExistingMedicalPlan"]).map((x) => Coverage.fromMap2(x))) : [],
        existingRetirement: map["ExistingRetirement"] != null ? List<Coverage>.from(json.decode(map["ExistingRetirement"]).map((x) => Coverage.fromMap2(x))) : [],
        existingChildEdu: map["ExistingChildEdu"] != null ? List<Coverage>.from(json.decode(map["ExistingChildEdu"]).map((x) => Coverage.fromMap2(x))) : [],
        existingCoverageDisclosure: map["ExistingCoverageDisclosure"] != null ? List<Coverage>.from(json.decode(map["ExistingCoverageDisclosure"]).map((x) => Coverage.fromMap2(x))) : [],
        isInterestedInMedplan: map['IsInterestedInMedplan'] ?? false,
        preferredMedCoverage: map['PreferredMedCoverage'] ?? "",
        isPurchasedMedPlan: map['IsPurchasedMedPlan'] ?? false,
        purchasedMedPlanName: map['PurchasedMedPlanName'] ?? "",
        prdRecReason: map['PrdRecReason'] ?? "",
        investPreference: map['InvestPreference'] ?? "");
  }
}

String nricToDOB(String nric) {
  String year = nric.substring(0, 2);
  String day = nric.substring(4, 6);
  String month = nric.substring(2, 4);
  if (int.parse(year) > 50) {
    year = "19$year";
  } else {
    year = "20$year";
  }
  return DateFormat('dd.M.yyyy').format(DateTime.parse("$year-$month-$day"));
}

Future<Occupation?> searchOccupationListByCode(String? keyword) async {
  List<Occupation> occupationList = [];
  Occupation? resultOcc;
  final output = await getTemporaryDirectory();
  String path = "${output.path}/occ.json";
  final file = File(path);

  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      Occupation occ = Occupation.fromJson(data[i]);
      occupationList.add(occ);
    }
  }

  for (int i = 0; i < occupationList.length; i++) {
    if (occupationList[i]
        .occupationCode!
        .toLowerCase()
        .contains(keyword!.toLowerCase())) resultOcc = occupationList[i];
  }
  return resultOcc;
}

class ClientAddress {
  final String? adr1;
  final String? adr2;
  final String? adr3;
  final String? adr4;
  final String? adr5;
  final String? city;
  final String? pincode;
  final String? state;
  final String? country;

  ClientAddress(
      {this.adr1,
      this.adr2,
      this.adr3,
      this.adr4,
      this.adr5,
      this.city,
      this.pincode,
      this.state,
      this.country});

  factory ClientAddress.fromJson(Map<String, dynamic> parsedJson) {
    return ClientAddress(
        adr1: parsedJson['Adr1'] ?? "",
        adr2: parsedJson['Adr2'] ?? "",
        adr3: parsedJson['Adr3'] ?? "",
        adr4: parsedJson['Adr4'] ?? "",
        adr5: parsedJson['Adr5'] ?? "",
        city: parsedJson['City'] ?? "",
        pincode: parsedJson['PinCode'] ?? "",
        state: parsedJson['State'] ?? "",
        country: parsedJson['Country'] ?? "");
  }

  Map<String, dynamic> toJson() => {
        'Adr1': adr1,
        'Adr2': adr2,
        'Adr3': adr3,
        'Adr4': adr4,
        'Adr5': adr5,
        'City': city,
        'PinCode': pincode,
        'State': state,
        'Country': country
      };
}
