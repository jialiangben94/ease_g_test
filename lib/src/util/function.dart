import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:ease/app_localization.dart';
import 'package:ease/main.dart';
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/data/new_business_model/master_lookup.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' show join;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

// ProdCode, vpms filename
Map<String, String> availableProductCode = {
  "PCEL01": "Triple Growth",
  "PCHI03": "MaxiPro",
  "PCHI04": "MaxiPro",
  "PCJI02": "MegaPlus",
  "PCTA01": "Etiqa Life Secure",
  "PCWA01": "Enrich Life Plan",
  "PCWI03": "Securelink",
  "PCEE01": "Aspire",
  "PTWI03": "ElitePlus Takafulink",
  "PTHI01": "Hadiyyah",
  "PTHI02": "Hadiyyah",
  "PTJI01": "Mahabbah",
};

int getAge(DateTime birthDate) {
  //first check if date is datetime or not

  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;
  int month1 = currentDate.month;
  int month2 = birthDate.month;

  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = currentDate.day;
    int day2 = birthDate.day;
    if (day2 > day1) {
      age--;
    }
  }
  return age;
}

Map validateRTU(String? value, String? frequency) {
  if (isNumeric(frequency)) {
    frequency = convertPaymentMode(frequency);
  }

  Map data = {'success': false, 'message': '', 'val': value};

  if (value != null && value.isNotEmpty) {
    //FIRST REMOVE ANY ','
    value = value.replaceAll(RegExp(','), "");
    //REMOVE ANY DECIMAL POINT
    var x = value.split('.');
    int y = int.parse(x[0]);

    if (x[0].isEmpty) {
      data['success'] = false;
      data['message'] = getLocale('Amount cannot be empty');
    } else {
      int multiple = 10;
      if (frequency == "Monthly") {
        multiple = 10;
      } else if (frequency == "Quarterly") {
        multiple = 30;
      } else if (frequency == "Half Yearly") {
        multiple = 60;
      } else if (frequency == "Yearly") {
        multiple = 120;
      }
      if (y < multiple || y % multiple != 0) {
        data['success'] = false;
        data['message'] =
            "${getLocale("The minimum regular top up must be")} ${toRM(multiple, rm: true)} ${getLocale(frequency!).toLowerCase()} ${getLocale("and \nmust be in multiple of")} ${toRM(multiple, rm: true)}.";
      } else {
        data['success'] = true;
        data['message'] = '';
      }
    }
  } else {
    data['success'] = false;
    data['message'] = getLocale('Amount cannot be empty');
  }

  return data;
}

Map validateAdhoc(String? value, String? frequency) {
  if (isNumeric(frequency)) {
    frequency = convertPaymentMode(frequency);
  }

  Map data = {'success': false, 'message': '', 'val': value};

  if (value != null && value.isNotEmpty) {
    //FIRST REMOVE ANY ','
    value = value.replaceAll(RegExp(','), "");
    //REMOVE ANY DECIMAL POINT
    var x = value.split('.');
    int y = int.parse(x[0]);

    if (x[0].isEmpty) {
      data['success'] = false;
      data['message'] = getLocale('Amount cannot be empty');
    } else {
      int minimum = 500;
      int multiple = 1;

      if (y < minimum || y % multiple != 0) {
        data['success'] = false;
        data['message'] =
            "${getLocale("The minimum ad hoc top up must be")} RM$minimum, ${getLocale("and \nmust be in multiple of")} RM$multiple.";
      } else {
        data['success'] = true;
        data['message'] = '';
      }
    }
  } else {
    data['success'] = false;
    data['message'] = getLocale('Amount cannot be empty');
  }

  return data;
}

// set isANB to true to get ANB, set to false to get Age only
int getAgeString(String sbirthDate, bool isANB, {int? additionalMonth}) {
  //STRING FORMAT MUST BE dd.M.yyyy
  DateTime currentDate = DateTime.now();
  if (additionalMonth != null) {
    var jiffy = Jiffy()..add(months: additionalMonth);
    currentDate = jiffy.dateTime;
  }
  DateTime birthDate = DateFormat("dd.M.yyyy").parse(sbirthDate);

  int age = currentDate.year - birthDate.year;
  int month1 = currentDate.month;
  int month2 = birthDate.month;

  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = currentDate.day;
    int day2 = birthDate.day;
    if (day2 > day1) {
      age--;
    }
  }

  if (isANB) {
    return age + 1; //ANB
  } else {
    return age; //AGE
  }
}

int getAgeInDays(DateTime birthDate) {
  final date2 = DateTime.now();
  return date2.difference(birthDate).inDays;
}

int getAgeInDaysFromString(String sbirthDate) {
//STRING FORMAT MUST BE dd.M.yyyy
  DateTime birthDate = DateFormat("dd.M.yyyy").parse(sbirthDate);
  final date2 = DateTime.now();

  return date2.difference(birthDate).inDays;
}

// Date in dd/mm/yyyy format only
String dateToVPMS(String dateInput) {
  if (dateInput != '') {
    var day = int.parse(dateInput.substring(0, 2));
    var month = int.parse(dateInput.substring(3, 5));
    var year = int.parse(dateInput.substring(6, 10));
    return "$day.$month.$year"; // dd.mm.yyyy format for VPMS.
  }
  return "";
}

String dateToVpmsInverse(String dateTime) {
  // Date in dd.mm.yyyy format only
  DateTime tempDate = DateFormat("dd.M.yyyy").parse(dateTime);
  String date = DateFormat("dd/MMM/yyyy").format(tempDate);
  return date;
}

String dateTimetoWithoutTime(String dateTime) {
  // Date in dd.mm.yyyy format only
  DateTime tempDate = DateFormat("dd MMM yyyy").parse(dateTime);
  String date = DateFormat("dd MMM yyyy").format(tempDate);
  return date;
}

List<Color> getColor(String? category) {
  if (category == getLocale("Follow Up Required")) {
    return [orangeRedColor, lightOrangeRedColor];
  } else if (category == getLocale("High Potential")) {
    return [cyanColor, lightCyanColor];
  } else if (category == getLocale("Low Potential")) {
    return [darkBrownColor, lightBrownColor];
  } else {
    return [greyTextColor, greyBorderColor];
  }
}

String convertVPMSBool(bool data) {
  if (data) {
    return 'Y';
  } else {
    return 'N';
  }
}

String convertCurrencyStringToGeneralNumber(String text) {
  var data = text;
  // if (text.contains('.')) {
  //   var ndata = text.split('.');
  //   data = ndata[0];
  // }

  return data.replaceAll(RegExp(','), '');
}

String convertPaymentMode(String? paymentMode) {
  //This will convert payment mode accordingly.
  //If feed number, will return full string payment mode
  //If feed in full string payment mode, will return number

  var data = "";

  if (paymentMode == "1") {
    data = "Monthly";
  } else if (paymentMode == "3") {
    data = "Quarterly";
  } else if (paymentMode == "6") {
    data = "Half Yearly";
  } else if (paymentMode == "12") {
    data = "Yearly";
  } else if (paymentMode == "Monthly") {
    data = "1";
  } else if (paymentMode == "Quarterly") {
    data = "3";
  } else if (paymentMode == "Half Yearly") {
    data = "6";
  } else if (paymentMode == "Yearly") {
    data = "12";
  }

  return data;
}

String convertPaymentModeInt(String? paymentMode) {
  //This will convert payment mode accordingly.
  //If feed number, will return full string payment mode
  //If feed in full string payment mode, will return number

  var data = "";

  if (paymentMode == "1") {
    data = "Monthly";
  } else if (paymentMode == "3") {
    data = "Quarterly";
  } else if (paymentMode == "6") {
    data = "Half Yearly";
  } else if (paymentMode == "12") {
    data = "Yearly";
  } else {
    data = paymentMode ?? '';
  }

  return data;
}

String convertPaymentModeToNumber(String? paymentMode) {
  //IN VPMS INPUT 12 = YEARLY, 6 HALF YEARLY, 3 QUARTERLY, 1 MONTHLY
  var data = "";
  if (paymentMode == "Monthly") {
    data = "1";
  } else if (paymentMode == "Quarterly") {
    data = "12";
  } else if (paymentMode == "Half Yearly") {
    data = "2";
  } else {
    data = "12";
  }
  return data;
}

constructValidationField(arrBasicAndRiders, String prodCode) {
  var strValidationFields = "";
  var separator = "|";
  arrBasicAndRiders.forEach((item) {
    var term = item["inputTermVarname"];
    var sa = item["inputSAVarname"];

    if (item["varname"] != null && item["varname"] != "N/A") {
      if (item["varname"].indexOf("N/A|") > -1) {
        var arrRTU = item["varname"].split("|");

        if (arrRTU.length > 0) {
          var strIndicator = arrRTU[1];

          //megaplus - have to show a_basic_premium error message first
          if (prodCode != "PCJI02") {
            if (strIndicator != "") {
              strValidationFields +=
                  strIndicator + separator + item["premiumVarname"] + separator;
            }
          }
        } else {
          strValidationFields += item["premiumVarname"] + separator;
        }
      } else {
        sa = item["varname"];
      }
    }
    if (item["inputSAVarname"] != null && item["inputSAVarname"] != "") {
      sa = item["inputSAVarname"];
    }
    if (sa != null) {
      if (sa.toString().trim() != "") {
        strValidationFields += sa.toString() + separator;
      }
    }
    if (item["deductibleVarCoverageVarname"] != null) {
      strValidationFields +=
          item["deductibleVarCoverageVarname"].toString() + separator;
    }
    if (item["varname"] == "N/A") {
      strValidationFields += item["premiumVarname"].toString() + separator;
    }
    if (term != null) {
      if (term.toString().trim() != "") {
        strValidationFields += term.toString() + separator;
      }
    }
  });
  if (strValidationFields.trim() != "") {
    strValidationFields =
        strValidationFields.substring(0, strValidationFields.length - 1);
  }
  return strValidationFields;
}

getRiderByIndicator(indicatorVarname, inputSAVarname, inputTermVarname,
    premiumVarname, deductibleVarCoverageVarname) {
  var result = {
    "varname": indicatorVarname,
    "inputSAVarname": inputSAVarname,
    "inputTermVarname": inputTermVarname,
    "premiumVarname": premiumVarname,
    "deductibleVarCoverageVarname": deductibleVarCoverageVarname
  };

  return result;
}

getRiderByInputSA(inputSAVarname, inputTermVarname, premiumVarname) {
  var result = {
    "varname": inputSAVarname,
    "inputTermVarname": inputTermVarname,
    "premiumVarname": premiumVarname
  };

  return result;
}

String generateQuickQuotationId() {
  return const Uuid().v4().substring(0, 7);
}

List<ProductPlan> sortRiderX(List<ProductPlan> allRider, String liGender,
    int liAnb, Quotation qtn, bool juvenile, String dob) {
  String? buyingFor = "";
  bool isJuvenile = false;
  int ageInDays = 0;

  try {
    buyingFor = qtn.buyingFor;
    isJuvenile = juvenile;
  } catch (e) {
    rethrow;
  }

  List<ProductPlan> riderList = [];

  if (isJuvenile == true) {
    ageInDays = getAgeInDaysFromString(dob);
  }

  for (var element in allRider) {
    //1. Don't want to include Enricher & RTU
    if (element.productSetup!.prodName != "Enricher" &&
        element.productSetup!.prodName != "Regular Top-Up") {
      //2. Only select rider with dual gender or same with LI gender
      if (element.productSetup!.gender == "E" ||
          element.productSetup!.gender == liGender) {
        //3. CaterIsJuvenile
        if (isJuvenile) {
          if (element.productSetup!.isJuvenile!) {
            if (ageInDays > element.productSetup!.childEntryAge! &&
                element.productSetup!.maxChildEntryAge == 0) {
              //////////////// REMOVE DUPLICATED PLAN & CATER FOR SPOUSE & JUVENILE /////////////
              if (!element.productSetup!.prodName!.contains('Plan')) {
                if (element.productSetup!.prodName!.contains("Spouse") &&
                    buyingFor == "Spouse") {
                  riderList.add(element);
                } else if (element.productSetup!.prodName!.contains("Spouse") &&
                    buyingFor != "Spouse") {
                } else if (element.productSetup!.prodName!
                        .contains("Juvenile") &&
                    buyingFor == "Children") {
                  riderList.add(element);
                } else if (element.productSetup!.prodName!
                        .contains("Juvenile") &&
                    buyingFor != "Children") {
                } else {
                  riderList.add(element);
                }
                ///////////////////////////////////////////////////////////////////////////////////

              }
            } else if (ageInDays > element.productSetup!.childEntryAge! &&
                element.productSetup!.maxChildEntryAge! > 0 &&
                ageInDays < element.productSetup!.maxChildEntryAge!) {
              //////////////// REMOVE DUPLICATED PLAN & CATER FOR SPOUSE & JUVENILE /////////////
              if (!element.productSetup!.prodName!.contains('Plan')) {
                if (element.productSetup!.prodName!.contains("Spouse") &&
                    buyingFor == "Spouse") {
                  riderList.add(element);
                } else if (element.productSetup!.prodName!.contains("Spouse") &&
                    buyingFor != "Spouse") {
                } else if (element.productSetup!.prodName!
                        .contains("Juvenile") &&
                    buyingFor == "Children") {
                  riderList.add(element);
                } else if (element.productSetup!.prodName!
                        .contains("Juvenile") &&
                    buyingFor != "Children") {
                } else {
                  riderList.add(element);
                }
                ///////////////////////////////////////////////////////////////////////////////////
              }
            }
          }
        } //3. Cater Non Juvenile
        else if (!isJuvenile) {
          //////////////// REMOVE DUPLICATED PLAN & CATER FOR SPOUSE & JUVENILE /////////////
          if (!element.productSetup!.prodName!.contains('Plan')) {
            if (element.productSetup!.prodName!.contains("Spouse") &&
                buyingFor == "Spouse") {
              riderList.add(element);
            } else if (element.productSetup!.prodName!.contains("Spouse") &&
                buyingFor != "Spouse") {
            } else if (element.productSetup!.prodName!.contains("Juvenile") &&
                buyingFor == "Children") {
            } else if (element.productSetup!.prodName!.contains("Juvenile") &&
                buyingFor != "Children") {
            } else {
              riderList.add(element);
            }
            ///////////////////////////////////////////////////////////////////////////////////
          }
        }
      }
    }
  }

  return riderList;
}

int convertStringToInt(String data) {
  try {
    return int.parse(data);
  } catch (e) {
    return 0;
  }
}

int convertDoubleToInt(double data) {
  try {
    return data.toInt();
  } catch (e) {
    return 0;
  }
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

String toRM(dynamic number, {bool? rm}) {
  final formatter = NumberFormat("#,##0.00", "en_US");
  if (!(number is int || number is double)) {
    if (isNumeric(number)) {
      number = double.parse(number);
    }
  }
  if (number is int || number is double) {
    if (rm != null && rm) return "RM ${formatter.format(number)}";
    return formatter.format(number);
  } else {
    if (rm != null && rm) return "RM $number";
    return formatter.format(number);
  }
}

ProductPlan? loadProductPlanData(
    BuildContext context, QuickQuotation quickQtn) {
  ProductPlan? productPlan;

  ProductPlanState data = BlocProvider.of<ProductPlanBloc>(context).state;

  if (data is ProductPlanLoaded) {
    List<ProductPlan> plan = data.props[0] as List<ProductPlan>;
    return productPlan = plan.firstWhere((element) =>
        element.productSetup!.prodCode == quickQtn.productPlanCode);
  } else {
    return productPlan;
  }
}

List<ProductPlan> loadBasicPlanRiderList(
    BuildContext context, ProductPlan productPlan) {
  List<ProductPlan> basicPlanRidersList = [];
  ProductPlanState data = BlocProvider.of<ProductPlanBloc>(context).state;

  if (data is ProductPlanLoaded) {
    List<ProductPlan> plan = data.props[0] as List<ProductPlan>;

    var productPlanRiderCode = [];
    for (var element in productPlan.riderList!) {
      productPlanRiderCode.add(element.riderCode);
    }

    for (int i = 0; i < plan.length; i++) {
      if (plan[i].productSetup!.prodCode![0] == "R" &&
          productPlanRiderCode.contains(plan[i].productSetup!.prodCode)) {
        if (!basicPlanRidersList.contains(plan[i])) {
          basicPlanRidersList.add(plan[i]);
        }
      }
    }
    return basicPlanRidersList;
  } else {
    return basicPlanRidersList;
  }
}

enum QuotationStatus { incomplete, active, expiredAge, expiredVPMS, invalid }

class VPMSStatus {
  final String? prodCode;
  String? vpmsversion;
  bool? isLatest;

  VPMSStatus({this.prodCode, this.isLatest, this.vpmsversion});

  Map<String, dynamic> toJson() {
    return {
      'prodCode': prodCode,
      'isLatest': isLatest,
      'vpmsversion': vpmsversion
    };
  }

  factory VPMSStatus.fromMap(Map<String, dynamic> map) {
    return VPMSStatus(
        prodCode: map['prodCode'],
        isLatest: map['isLatest'],
        vpmsversion: map['vpmsversion']);
  }
}

Future<QuotationStatus> isQuotationActive(
    BuildContext context,
    String? productPlanCode,
    String? vpmsVersion,
    String dob,
    int age,
    String? status,
    String totPrem) async {
  bool isLatestVpms = true;
  final pref = await SharedPreferences.getInstance();

  bool vpmscheckafterlogin = false;
  if (pref.getBool("vpmscheckafterlogin") != null) {
    vpmscheckafterlogin = pref.getBool("vpmscheckafterlogin")!;
  }

  List<VPMSStatus> vpmsstatuslist = [];
  if (pref.getString("vpmsstatus") == null) {
    await pref.setString("vpmsstatus", json.encode({}));
  }
  var data = json.decode(pref.getString("vpmsstatus")!);
  for (int i = 0; i < data.length; i++) {
    VPMSStatus vpmsstatus = VPMSStatus.fromMap(data[i]);
    vpmsstatuslist.add(vpmsstatus);
  }

  if (vpmsstatuslist.any((element) => element.prodCode == productPlanCode)) {
    VPMSStatus vpmsstatus = vpmsstatuslist
        .firstWhere((element) => element.prodCode == productPlanCode);
    if (vpmsstatus.vpmsversion != null &&
        vpmsstatus.vpmsversion == vpmsVersion &&
        vpmscheckafterlogin) {
      isLatestVpms = vpmsstatus.isLatest ?? true;
    } else {
      bool conn = await checkConnectivity();
      if (conn &&
          productPlanCode != null &&
          vpmsVersion != null &&
          vpmsVersion != "") {
        var vpmsObj = {
          "Method": "GET",
          "Param": {
            "ProdCode": productPlanCode,
            "vpmsVersion": vpmsVersion,
            "AppId": "stp.etiqa.com.my"
          }
        };
        await NewBusinessAPI().validation(vpmsObj).then((response) async {
          if (response != null && response["VpmsVersion"] == vpmsVersion) {
            isLatestVpms = false;
            vpmsstatus.vpmsversion = response["VpmsVersion"];
          } else {
            vpmsstatus.vpmsversion = vpmsVersion;
          }
        }).onError((error, stackTrace) {
          isLatestVpms = true;
        });
      }
      vpmsstatus.isLatest = isLatestVpms;
    }
  } else {
    bool conn = await checkConnectivity();
    String? vpmsversion = vpmsVersion;
    if (conn &&
        productPlanCode != null &&
        vpmsVersion != null &&
        vpmsVersion != "") {
      var vpmsObj = {
        "Method": "GET",
        "Param": {
          "ProdCode": productPlanCode,
          "vpmsVersion": vpmsVersion,
          "AppId": "stp.etiqa.com.my"
        }
      };
      await NewBusinessAPI().validation(vpmsObj).then((response) async {
        if (response != null && response["VpmsVersion"] == vpmsVersion) {
          isLatestVpms = false;
          vpmsversion = response["VpmsVersion"];
        } else {
          vpmsversion = vpmsVersion;
        }
      }).onError((error, stackTrace) {
        isLatestVpms = true;
      });
    }
    vpmsstatuslist.add(VPMSStatus(
        prodCode: productPlanCode,
        isLatest: isLatestVpms,
        vpmsversion: vpmsversion));
  }

  await pref.setString("vpmsstatus", json.encode(vpmsstatuslist));
  await pref.setBool("vpmscheckafterlogin", true);

  // get current ANB and compare with recorded age
  if (totPrem == '-') {
    return QuotationStatus.incomplete;
  }
  if ((getAgeString(dob, false) > age)) {
    return QuotationStatus.expiredAge;
  } else if (!isLatestVpms) {
    return QuotationStatus.expiredVPMS;
  } else if (status == "2") {
    return QuotationStatus.invalid;
  } else {
    return QuotationStatus.active;
  }
}

String? countdownReminder(String? reminderDate) {
  if (reminderDate != null) {
    DateTime reminderDate2 = DateTime.parse(reminderDate);
    DateTime dateNow = DateTime.now();
    int difference = reminderDate2.difference(dateNow).inDays + 1;
    if ((difference % 7) == 0) {
      return "${difference ~/ 7} week(s)";
    } else {
      return "$difference day(s)";
    }
  } else {
    return null;
  }
}

String getLocale(String term, {bool? entity}) {
  if (kDebugMode) {
    return AppLocalizations.of(navigatorKey.currentContext!)!
            .translate(term, ent: entity) ??
        "err";
  }
  return AppLocalizations.of(navigatorKey.currentContext!)!
          .translate(term, ent: entity) ??
      term;
}

// void setQuickQuotationVersion(Quotation quotation) {
//   int qtnLength = 1;

//   quotation.listOfQuotation
//       .sort((a, b) => a.lastUpdatedTime.compareTo(b.lastUpdatedTime));
//   Future.delayed(const Duration(milliseconds: 5), () {
//     quotation.listOfQuotation.forEach((element) {
//       element.version = qtnLength.toString();
//       qtnLength++;

//       print(
//           "ID ${element.quickQuoteId} | DATE ${element.lastUpdatedTime} | VERSION ${element.version}");
//     });
//   });
// }

void setQuickQuotationVersion(
    Quotation quotation, QuickQuotation? quickQuotation, Status? status) {
  List<int> currentVersion = [];

  if (quotation.listOfQuotation!.length <= 1) {
    quickQuotation!.version = 1.toString();
  } else {
    for (var element in quotation.listOfQuotation!) {
      var data = element!.version;
      if (data != null) {
        currentVersion.add(int.parse(data));
      }
    }

    var maxVersion = currentVersion.reduce((max));

    if (status == Status.editAge || quickQuotation!.version == null) {
      quickQuotation!.version = (maxVersion + 1).toString();
    }

    quickQuotation.version = (maxVersion + 1).toString();
  }
}

int getTimestamp({DateTime? date}) {
  if (date != null) {
    return date.microsecondsSinceEpoch;
  } else {
    return DateTime.now().microsecondsSinceEpoch;
  }
}

String getStandardDateFormat({DateTime? date, int? timestamp}) {
  if (date != null) {
    return DateFormat('dd MMM yyyy').format(date);
  } else if (timestamp != null) {
    return DateFormat('dd MMM yyyy')
        .format(DateTime.fromMicrosecondsSinceEpoch(timestamp));
  } else {
    return DateFormat('dd MMM yyyy').format(DateTime.now());
  }
}

String generateRandomId() {
  return const Uuid().v4().substring(0, 7);
}

Future<dynamic> checkImage(image, path) async {
  if (image == null || path == null || image == "" || path == "") {
    throw Exception({"status": false, "error": "Empty value"});
  }

  var path2 = join(path, image);
  final imageFile = File(path2);
  if (imageFile.existsSync()) {
    try {
      var byte = imageFile.readAsBytesSync();

      List<int> genreIdsList = List<int>.from(byte);
      if (genreIdsList.length > middleIndex) {
        genreIdsList.removeRange(middleIndex, middleIndex + byteMiddle.length);
      }
      genreIdsList.removeRange(0, byteFront.length);
      genreIdsList.removeRange(
          genreIdsList.length - byteBack.length, genreIdsList.length - 1);

      return {"status": true, "data": Uint8List.fromList(genreIdsList)};
    } catch (e) {
      throw Exception({"status": false, "error": e});
    }
  } else {
    throw Exception({"status": false, "error": getLocale("Image not found")});
  }
}

dynamic generateImageByte(imageByte) {
  List<int> image = List.from(byteFront)
    ..addAll(imageByte)
    ..addAll(byteBack);
  if (image.length > middleIndex) {
    image.insertAll(middleIndex, byteMiddle);
  }
  return image;
}

Future<dynamic> addInWatermark(image) async {
  var imageByte = await rootBundle.load("assets/images/watermark.png");
  Uint8List imageUint8List = imageByte.buffer
      .asUint8List(imageByte.offsetInBytes, imageByte.lengthInBytes);
  List<int> imageListInt = imageUint8List.cast<int>();
  img.Image image2 = img.decodeImage(imageListInt)!;

  int? height = (image.height / 3).toInt();
  int? width = (image.width / 5).toInt();
  if (image.height > image.width) {
    height = (image.height / 2.5).toInt();
    width = 20;
  }

  return img.copyInto(image, image2, dstX: width, dstY: height);
}

Future<dynamic> resizeImage(image) async {
  img.Image finalImage;
  var size = [720, 480];
  if (image.width > image.height) {
    finalImage = img.copyResize(image,
        width: size[0],
        height: size[1],
        interpolation: img.Interpolation.average);
  } else {
    finalImage = img.copyResize(image,
        width: size[1],
        height: size[0],
        interpolation: img.Interpolation.average);
  }

  return finalImage;
}

String? json2xml(obj, {multiple = true}) {
  if (obj is! Map) return null;
  try {
    var xml = '';
    for (var prop in obj.keys) {
      xml += "<$prop>";
      if (obj[prop] is List) {
        for (var array in obj[prop]) {
          if (multiple == false) {
            xml += json2xml(array)!;
          } else {
            xml += "<Row>";
            xml += json2xml(array)!;
            xml += "</Row>";
          }
        }
      } else if (obj[prop] is Map) {
        xml += json2xml(obj[prop])!;
      } else {
        xml += obj[prop] is int ? obj[prop].toString() : obj[prop];
      }
      xml += "</$prop>";
    }
    return xml;
  } catch (e) {
    return "";
  }
}

//only apply format {'key': [{'key': 'value'}]} for now
dynamic xml2json(string) {
  try {
    if (string is! String || string == "") return null;
    var obj = {};
    dynamic firstLayer =
        string.substring(string.indexOf("<") + 1, string.indexOf(">"));
    string = string.substring(
        string.indexOf("<$firstLayer>") + firstLayer.length + 2 as int,
        string.indexOf("</$firstLayer>"));
    dynamic row = [];
    var inObj = {};
    while (true) {
      if (string.indexOf("Row") > -1) {
        row.add(string.substring(
            string.indexOf("<Row>") + 5, string.indexOf("</Row>")));
        string = string.substring(string.indexOf("</Row>") + 6);
      } else {
        break;
      }
    }
    for (var i = 0; i < row.length; i++) {
      var count = "</".allMatches(row[i]).length;
      for (var e = 0; e < count; e++) {
        var key =
            row[i].substring(row[i].indexOf("<") + 1, row[i].indexOf(">"));
        var value = row[i].substring(row[i].indexOf("<$key>") + key.length + 2,
            row[i].indexOf("</$key>"));
        row[i] = row[i].substring(row[i].indexOf("</$key>") + key.length + 3);
        inObj[key] = value;
      }
      row[i] = json.decode(json.encode(inObj));
      inObj = {};
    }
    obj[firstLayer] = row;
    return obj;
  } catch (e) {
    return null;
  }
}

// Get Master Lookup Data
String getMLNameFromValue(
    String callValue, int typeId, List<dynamic> mainMasterLookupData) {
  String name = '';
  for (var element in mainMasterLookupData) {
    MasterLookup x = element;
    if (x.typeId == typeId && x.callValue == callValue) {
      name = x.name!;
    }
  }

  return name;
}

void handleBlockCountryInfo(List<String> blockedCountry, BuildContext context,
    {String? warning}) {
  List<String> blockCountryName = [];

  if (blockedCountry.isNotEmpty) {
    var masterLookup = BlocProvider.of<MasterLookupBloc>(context).state;

    if (masterLookup is MasterLookupLoaded) {
      List lookupData = masterLookup.masterLookupList;
      // Once get that data, need to loop in master lookup
      // To get full name of the country
      for (var country in blockedCountry) {
        var name = getMLNameFromValue(country, 12, lookupData);
        if (name != '') {
          blockCountryName.add("- $name");
        } else {
          blockCountryName.add("- $country");
        }
      }
    }

    return showAlertDialog(
        context,
        warning == '0'
            ? getLocale(
                'Note: These nationalities are not allowed to buy from this plan:')
            : getLocale(
                'Sorry. These nationalities are not allowed to buy from this plan:'),
        blockCountryName.join('\n'));
  }
}

dynamic convertProductPlan(var productPlanType) {
  if (productPlanType is String) {
    if (productPlanType.toLowerCase().contains('investment')) {
      return ProductPlanType.investmentLink;
    } else {
      return ProductPlanType.traditional;
    }
  } else {
    if (productPlanType == ProductPlanType.investmentLink) {
      return 'Investment Link';
    } else {
      return 'Traditional';
    }
  }
}

bool quotationValid(Quotation quotation, int index) {
  if (quotation.listOfQuotation!.isEmpty ||
      quotation.listOfQuotation![index]!.status == "2" ||
      quotation.listOfQuotation![index]!.premAmt == "" ||
      quotation.listOfQuotation![index]!.totalPremium == null) {
    return true;
  } else {
    return false;
  }
}

Future<String?> getAccessControl() async {
  try {
    String? access;
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    await ServicingAPI().accessControl(agent.accountCode!).then((res) {
      if (res != null && res["status"] != null && res["status"]) {
        if (res != null &&
            res["data"] != null &&
            res["data"]["ModuleBinary"] != null) {
          access = res["data"]["ModuleBinary"];
        }
      }
    });
    return access;
  } catch (e) {
    rethrow;
  }
}

String checkAccess(String moduleBinary, String moduleCode) {
  String result;
  result = (int.parse(moduleBinary[0]) & int.parse(moduleCode[0])).toString();
  result = result +
      (int.parse(moduleBinary[1]) & int.parse(moduleCode[1])).toString();
  return result;
}
