import 'dart:io';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/data/new_business_model/master_lookup.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/user_repository/agent_product.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/directory.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/network_util.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const dynamicFieldsFile = "dynamic_fields.json";
const optionListJson = "OptionList.json";
const optionTypeJson = "OptionType.json";
const bankListJson = "bankList.json";
const translationJson = "translation.json";

Future<File> optionListFile() async {
  final status = await getCommonFilePath();
  if (status == null || status["status"] != true || status["path"] == null) {
    throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
  }
  return File(status["path"] + "/" + optionListJson);
}

Future<File> optionTypeFile() async {
  final status = await getCommonFilePath();
  if (status == null || status["status"] != true || status["path"] == null) {
    throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
  }
  return File(status["path"] + "/" + optionTypeJson);
}

Future<File> bankListFile() async {
  final status = await getCommonFilePath();
  if (status == null || status["status"] != true || status["path"] == null) {
    throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
  }
  return File(status["path"] + "/" + bankListJson);
}

Future<File> translationFile() async {
  final status = await getCommonFilePath();
  if (status == null || status["status"] != true || status["path"] == null) {
    throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
  }
  return File(status["path"] + "/" + translationJson);
}

Future<dynamic> readOptionFileAsObj() async {
  try {
    final file = await optionListFile();
    final file2 = await optionTypeFile();
    final file3 = await bankListFile();
    final file4 = await translationFile();

    String read = await file.readAsString();
    String read2 = await file2.readAsString();
    String read3 = await file3.readAsString();
    String read4 = await file4.readAsString();

    List<TranslationLookUp> translationList = [];

    var translations = jsonDecode(read4);
    for (int i = 0; i < translations.length; i++) {
      TranslationLookUp translationLookUp =
          TranslationLookUp.fromMap(translations[i]);
      translationList.add(translationLookUp);
    }

    var data = jsonDecode(read);
    data = data + jsonDecode(read3);
    var data2 = jsonDecode(read2);

    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');

    return {
      "optionList": data,
      "optionType": data2,
      "translation": translationList,
      "languageId": lang == "ms" ? 2 : 1
    };
  } catch (e) {
    handleThrowError(e);
  }
}

Future<void> checkVPMSData(String prodCode, String filename) async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/vpms/$filename.vpm";
  final fileVPMS = File(path);

  if (!fileVPMS.existsSync()) {
    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "VPMSMaster",
        "Mode": "FULL",
        "ProdCode": prodCode,
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    await NewBusinessAPI().masterData(obj).then((response) async {
      if (response != null && response["VpmsMaster"] != null) {
        if (response["VpmsMaster"]["VpmsFileName"] != null) {
          path =
              "${output.path}/vpms/${response["VpmsMaster"]["VpmsFileName"]}";
        }
        final file = await File(path).create(recursive: true);
        if (response["VpmsMaster"]["VpmsFileContent"] != null) {
          var contents =
              base64.decode(response["VpmsMaster"]["VpmsFileContent"]);
          await file.writeAsBytes(contents);
        }
      }
    });
  } else {
    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "VPMSMaster",
        "Mode": "DELTA",
        "ProdCode": prodCode,
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    await NewBusinessAPI().masterData(obj).then((response) async {
      if (response != null && response["VpmsMaster"] != null) {
        if (response["VpmsMaster"]["VpmsFileName"] != null) {
          path =
              "${output.path}/vpms/${response["VpmsMaster"]["VpmsFileName"]}";
        }
        final file = await File(path).create(recursive: true);
        if (response["VpmsMaster"]["VpmsFileContent"] != null) {
          var contents =
              base64.decode(response["VpmsMaster"]["VpmsFileContent"]);
          await file.writeAsBytes(contents);
        }
      }
    });
  }
}

Future<void> downloadMasterData() async {
  try {
    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "Facility",
        "Mode": "FULL",
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    NewBusinessAPI().masterData(obj).then((masterdata) async {
      final file = await optionListFile();
      String decoded = utf8.decode(base64.decode(masterdata["OptionList"]));
      file.writeAsStringSync(decoded);

      final file2 = await optionTypeFile();
      String decoded2 = utf8.decode(base64.decode(masterdata["OptionType"]));
      file2.writeAsStringSync(decoded2);

      final file3 = await bankListFile();
      String decoded3 = utf8.decode(base64.decode(masterdata["BankDetails"]));
      file3.writeAsStringSync(decoded3);

      final file4 = await translationFile();
      String decoded4 = utf8.decode(base64.decode(masterdata["Translation"]));
      file4.writeAsStringSync(decoded4);
    });
  } catch (e) {
    handleThrowError(e);
  }
}

Future<void> updateMasterData() async {
  try {
    final file = await optionListFile();
    final file2 = await optionTypeFile();
    final file3 = await bankListFile();
    final file4 = await translationFile();

    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "Facility",
        "Mode": "DELTA",
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    await NewBusinessAPI().masterData(obj).then((res) async {
      if (file.existsSync()) {
        if (res["OptionListDelta"] != null) {
          List<MasterLookup> currMLUList = await getMasterLookupList();
          List<MasterLookup> toUpdateMLU = [];

          final optionlist = res["OptionListDelta"];
          for (int i = 0; i < optionlist.length; i++) {
            MasterLookup masterLookup = MasterLookup.fromMap(optionlist[i]);
            toUpdateMLU.add(masterLookup);
          }

          for (var element in toUpdateMLU) {
            dynamic newUpdate;
            newUpdate =
                currMLUList.firstWhere((value) => value.id == element.id);
            if (newUpdate != null) {
              for (int i = 0; i < currMLUList.length; i++) {
                if (newUpdate.id == currMLUList[i].id) {
                  currMLUList[i] = element;
                }
              }
            } else {
              currMLUList.add(element);
            }
          }
          file.writeAsStringSync(jsonEncode(currMLUList));
        }
      }

      if (file2.existsSync()) {
        if (res["OptionTypeDelta"] != null) {
          List<MasterLookupType> currMLUTList = await getMasterLookupTypeList();
          List<MasterLookupType> toUpdateMLUT = [];

          final optionlist = res["OptionTypeDelta"];
          for (int i = 0; i < optionlist.length; i++) {
            MasterLookupType masterLookupType =
                MasterLookupType.fromMap(optionlist[i]);
            toUpdateMLUT.add(masterLookupType);
          }

          for (var element in toUpdateMLUT) {
            dynamic newUpdate;
            newUpdate =
                currMLUTList.firstWhere((value) => value.id == element.id);
            if (newUpdate != null) {
              for (int i = 0; i < currMLUTList.length; i++) {
                if (newUpdate.id == currMLUTList[i].id) {
                  currMLUTList[i] = element;
                }
              }
            } else {
              currMLUTList.add(element);
            }
          }
          file2.writeAsStringSync(json.encode(currMLUTList));
        }
      }

      if (file3.existsSync()) {
        if (res["BankDetailDelta"] != null) {
          List<BankLookUp> currBankList = await getBankLookUpList();
          List<BankLookUp> toUpdateBankList = [];

          final banklist = res["BankDetailDelta"];
          for (int i = 0; i < banklist.length; i++) {
            BankLookUp bankLookUp = BankLookUp.fromMap(banklist[i]);
            toUpdateBankList.add(bankLookUp);
          }

          for (var element in toUpdateBankList) {
            dynamic newUpdate;
            newUpdate =
                currBankList.firstWhere((value) => value.id == element.id);
            if (newUpdate != null) {
              for (int i = 0; i < currBankList.length; i++) {
                if (newUpdate.id == currBankList[i].id) {
                  currBankList[i] = element;
                }
              }
            } else {
              currBankList.add(element);
            }
          }
          file3.writeAsStringSync(json.encode(currBankList));
        }
      }

      if (file4.existsSync()) {
        if (res["TranslationDelta"] != null) {
          List<TranslationLookUp> currTranslationList =
              await getTranslationLookUpList();
          List<TranslationLookUp> toUpdateTranslationList = [];

          final translationlist = res["TranslationDelta"];
          for (int i = 0; i < translationlist.length; i++) {
            TranslationLookUp translationLookUp =
                TranslationLookUp.fromMap(translationlist[i]);
            toUpdateTranslationList.add(translationLookUp);
          }

          for (var element in toUpdateTranslationList) {
            dynamic newUpdate;
            newUpdate = currTranslationList
                .firstWhere((value) => value.id == element.id);
            if (newUpdate != null) {
              for (int i = 0; i < currTranslationList.length; i++) {
                if (newUpdate.id == currTranslationList[i].id) {
                  currTranslationList[i] = element;
                }
              }
            } else {
              currTranslationList.add(element);
            }
          }
          file4.writeAsStringSync(json.encode(currTranslationList));
        }
      }

      options = {};
    });
  } catch (e) {
    handleThrowError(e);
  }
}

Future<void> downloadOccupationList() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/occ.json";
  final file = File(path);

  String uuid = await getDeviceUUiD();
  var obj = {
    "Method": "GET",
    "Param": {
      "Type": "Occupation",
      "Mode": "FULL",
      "DeviceId": uuid,
      "AppID": "my.com.etiqa.ease"
    }
  };
  await NewBusinessAPI().masterData(obj).then((value) async {
    var bytes = base64Decode(value["Occupation"]);
    await file.writeAsBytes(bytes.buffer.asUint8List());
  });
}

// new branch name

Future<List<Occupation>> getOccupationList() async {
  List<Occupation> occupationList = [];
  final output = await getTemporaryDirectory();
  String path = "${output.path}/occ.json";
  final file = File(path);
  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      Occupation occ = Occupation.fromJson(data[i]);
      if (!occ.occupationCode!.contains("OTH")) occupationList.add(occ);
    }
  }
  return occupationList;
}

Future<void> updateOccupationList() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/occ.json";
  final file = File(path);

  String uuid = await getDeviceUUiD();
  var obj = {
    "Method": "GET",
    "Param": {
      "Type": "Occupation",
      "Mode": "DELTA",
      "DeviceId": uuid,
      "AppID": "my.com.etiqa.ease"
    }
  };
  await NewBusinessAPI().masterData(obj).then((res) async {
    if (res["OccupationDelta"] != null) {
      List<Occupation> currOccList = await getOccupationList();
      List<Occupation> toUpdateOccList = [];

      final occupations = res["OccupationDelta"];

      for (int i = 0; i < occupations.length; i++) {
        Occupation occupation = Occupation.fromJson(occupations[i]);
        toUpdateOccList.add(occupation);
      }

      for (var element in toUpdateOccList) {
        Occupation newUpdate = currOccList.firstWhere(
            (value) => value.occupationCode == element.occupationCode,
            orElse: () => Occupation());
        if (newUpdate.occupationCode != null) {
          currOccList[currOccList.indexWhere((value) =>
              value.occupationCode == newUpdate.occupationCode)] = element;
        } else {
          currOccList.add(element);
        }
      }
      file.writeAsStringSync(json.encode(currOccList));
    }
  });
}

Future<void> downloadProductSetupPlan() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/product_setup_plan.json";
  final file = File(path);

  String uuid = await getDeviceUUiD();
  var obj = {
    "Method": "GET",
    "Param": {
      "Type": "ProductSetup",
      "Mode": "FULL",
      "ProductType": "1",
      "DeviceId": uuid,
      "AppID": "my.com.etiqa.ease"
    }
  };
  await NewBusinessAPI().masterData(obj).then((value) async {
    var bytes = base64Decode(value["ProductDetails"]);
    await file.writeAsBytes(bytes.buffer.asUint8List());
  });
}

Future<void> updateProductSetupPlan() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/product_setup_plan.json";
  String path2 = "${output.path}/product_setup_plan_delta.json";
  final file = File(path);
  final file2 = File(path2);

  if (file.existsSync()) {
    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "ProductSetup",
        "Mode": "DELTA",
        "ProductType": "1",
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    await NewBusinessAPI().masterData(obj).then((res) async {
      if (res["ProductDetailsDelta"] != null) {
        List<ProductPlan> currPPList =
            await ProductPlanRepositoryImpl().getProductPlanSetup();
        List<ProductPlan> toUpdatePP = [];

        final products = res["ProductDetailsDelta"];

        for (int i = 0; i < products.length; i++) {
          ProductPlan productPlan = ProductPlan.fromMap(products[i]);
          toUpdatePP.add(productPlan);
        }

        if (toUpdatePP.isNotEmpty) {
          file2.writeAsStringSync(json.encode(toUpdatePP));
        }

        for (var element in toUpdatePP) {
          ProductPlan newUpdate = currPPList.firstWhere(
              (value) =>
                  value.productSetup!.prodCode ==
                  element.productSetup!.prodCode,
              orElse: () => ProductPlan());
          if (newUpdate.productSetup != null &&
              newUpdate.productSetup!.prodCode != null) {
            currPPList[currPPList.indexWhere((value) =>
                value.productSetup!.prodCode ==
                newUpdate.productSetup!.prodCode)] = element;
          } else {
            currPPList.add(element);
          }
        }
        file.writeAsStringSync(json.encode(currPPList));
      }
    });
  }
}

Future<void> downloadProductSetupRider() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/product_setup_rider.json";
  final file = File(path);

  String uuid = await getDeviceUUiD();
  var obj = {
    "Method": "GET",
    "Param": {
      "Type": "ProductSetup",
      "Mode": "FULL",
      "ProductType": "2",
      "DeviceId": uuid,
      "AppID": "my.com.etiqa.ease"
    }
  };
  await NewBusinessAPI().masterData(obj).then((value) async {
    var bytes = base64Decode(value["ProductDetails"]);
    await file.writeAsBytes(bytes.buffer.asUint8List());
  });
}

Future<void> updateProductSetupRider() async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/product_setup_rider.json";
  String path2 = "${output.path}/product_setup_rider_delta.json";
  final file = File(path);
  final file2 = File(path2);

  if (file.existsSync()) {
    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "ProductSetup",
        "Mode": "DELTA",
        "ProductType": "2",
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    await NewBusinessAPI().masterData(obj).then((res) async {
      if (res["ProductDetailsDelta"] != null) {
        List<ProductPlan> currRPList =
            await ProductPlanRepositoryImpl().getRiderPlanSetup();
        List<ProductPlan> toUpdatePP = [];

        final products = res["ProductDetailsDelta"];

        for (int i = 0; i < products.length; i++) {
          ProductPlan productPlan = ProductPlan.fromMap(products[i]);
          toUpdatePP.add(productPlan);
        }

        if (toUpdatePP.isNotEmpty) {
          file2.writeAsStringSync(json.encode(toUpdatePP));
        }

        for (var element in toUpdatePP) {
          ProductPlan newUpdate = currRPList.firstWhere(
              (value) =>
                  value.productSetup!.prodCode ==
                  element.productSetup!.prodCode,
              orElse: () => ProductPlan());
          if (newUpdate.productSetup!.prodCode != null) {
            currRPList[currRPList.indexWhere((value) =>
                value.productSetup!.prodCode ==
                newUpdate.productSetup!.prodCode)] = newUpdate;
          } else {
            currRPList.add(element);
          }
        }
        file.writeAsStringSync(json.encode(currRPList));
      }
    });
  }
}

Future<void> downloadAgentDetail(bool download) async {
  final output = await getTemporaryDirectory();
  String path = "${output.path}/agent_product.json";
  final file = File(path);
  var pref = await SharedPreferences.getInstance();
  Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

  if (!file.existsSync()) {
    var agentObj = {
      "Method": "GET",
      "Param": {"Mode": "FULL", "AgentCode": agent.accountCode}
    };
    await NewBusinessAPI().validation(agentObj).then((value) async {
      file.writeAsStringSync(json.encode(value["AgentDetails"]));
    });
  } else {
    if (download) {
      List<AgentProduct> currProductList =
          await ProductPlanRepositoryImpl().getAgentProduct();
      String? prevAgentCode;
      String mode;

      for (var element in currProductList) {
        prevAgentCode = element.agentCode;
      }

      if (prevAgentCode == agent.accountCode) {
        mode = "DELTA";
      } else {
        mode = "FULL";
      }
      var agentObj = {
        "Method": "GET",
        "Param": {"Mode": mode, "AgentCode": agent.accountCode}
      };

      await NewBusinessAPI().validation(agentObj).then((res) async {
        if (res["AgentDetails"] != null) {
          final agentdetails = res["AgentDetails"];
          List<AgentProduct> toUpdateProduct = [];

          for (int i = 0; i < agentdetails.length; i++) {
            AgentProduct agentProduct = AgentProduct.fromMap(agentdetails[i],
                agentCode: agent.accountCode);
            toUpdateProduct.add(agentProduct);
          }

          if (prevAgentCode == agent.accountCode) {
            for (var element in toUpdateProduct) {
              var newUpdate = currProductList.firstWhereOrNull(
                  (value) => value.prodCode == element.prodCode);
              if (newUpdate != null) {
                currProductList[currProductList.indexWhere(
                        (value) => value.prodCode == newUpdate.prodCode)] =
                    newUpdate;
              } else {
                currProductList.add(element);
              }
            }
          } else {
            currProductList = toUpdateProduct;
          }
          file.writeAsStringSync(json.encode(currProductList));
        }
      });
    }
  }
}

Future<dynamic> dynamicFieldsFilePath() async {
  try {
    final status = await getCommonFilePath();
    if (status == null || status["status"] != true || status["path"] == null) {
      throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
    }
    return status["path"] + "/" + dynamicFieldsFile;
  } catch (e) {
    handleThrowError(e);
  }
}

Future<dynamic> readDynamicFieldsFile({validateLocalJson = false}) async {
  try {
    final path = await dynamicFieldsFilePath();
    final fieldsFile = File(path);

    if (!fieldsFile.existsSync()) {
      throw throwErrorFormat(false, AppErrorCode.fileNotFound);
    }
    String read = await fieldsFile.readAsString();
    var data = jsonDecode(read);
    if (validateLocalJson) {
      return {"status": true, "data": data};
    } else {
      //if is from asset local json
      if (data is Map && data["local"] == true && data["data"] != null) {
        return {"status": true, "data": data["data"]};
      } else {
        return {"status": true, "data": data};
      }
    }
  } catch (e) {
    handleThrowError(e);
  }
}

Future<dynamic> downloadDynamicFieldsFile() async {
  try {
    final path = await dynamicFieldsFilePath();
    final fieldsFile = File(path);
    bool hasConn = await checkConnectivity();
    dynamic data;
    List<dynamic>? array = [];
    List modeList = ["FULL", "DELTA"];
    String mode = modeList[0];
    bool fieldsFileExist = fieldsFile.existsSync();

    if (fieldsFileExist) {
      var readData = await readDynamicFieldsFile(validateLocalJson: true);
      if (readData == null ||
          readData["status"] != true ||
          readData["data"] == null) {
        throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
      }

      readData = readData["data"];
      // print(readData);

      //if is from asset local json then init FULL download
      if (readData is Map &&
          readData["local"] == true &&
          readData["data"] != null) {
        //if no internet continue using local json
        if (!hasConn) {
          return {"status": true, "data": readData["data"]};
        }
      }
      // if is not from asset local json then DELTA download
      else {
        mode = modeList[1];
      }
    }

    // print(mode);

    //read asset local json if no internet for first time FULL download.
    if (mode == modeList[0] && !hasConn && !fieldsFileExist) {
      String jsonString =
          await rootBundle.loadString("assets/files/dynamic_fields.json");
      var jsonObj = {};
      jsonObj["data"] = jsonDecode(jsonString);
      jsonObj["local"] = true;

      await fieldsFile.writeAsString(json.encode(jsonObj));
      return {"status": true, "data": jsonObj["data"]};
    }

    String uuid = await getDeviceUUiD();
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "CustomField",
        "Mode": mode,
        "DeviceId": uuid,
        "AppID": "my.com.etiqa.ease"
      }
    };
    data = await NewBusinessAPI().masterData(obj);
    if (data!["CustomFields"] != null) {
      var array = json.decode(utf8.decode(base64.decode(data["CustomFields"])));
      data = {"status": true, "data": array};
    } else if (data["CustomFieldsDelta"] != null) {
      data = {"status": true, "data": data["CustomFieldsDelta"]};
    } else if (data["IsSuccess"]) {
      data = {"status": true, "data": []};
    }

    if (data == null || data["status"] != true) {
      throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
    }

    if (data["data"] is String) {
      data = json.decode(data["data"]);
    } else if (data["data"] is List) {
      data = data["data"];
    }

    if (data is! List) {
      throw throwErrorFormat(false, AppErrorCode.requiredDataNotMatch);
    }

    if (fieldsFile.existsSync()) {
      var status = await readDynamicFieldsFile();
      if (status == null ||
          status["status"] != true ||
          status["data"] == null) {
        throw throwErrorFormat(false, AppErrorCode.statusDataNotFound);
      }
      array = status["data"];
    }

    for (var i = 0; i < data.length; i++) {
      int index = array!.indexWhere((field) => field["Id"] == data[i]["Id"]);
      if (index > -1) {
        array[index] = data[i];
      } else {
        array.add(data[i]);
      }
    }

    await fieldsFile.writeAsString(json.encode(array));
    return {"status": true, "data": array};
  } catch (e) {
    handleThrowError(e);
  }
}
