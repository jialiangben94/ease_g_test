import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:intl/intl.dart';

//TEMP WORKAROUND
class AutoPopulate {
  dynamic inputList;
  AutoPopulate({this.inputList});

  bool isValidDate(String input) {
    final date = DateTime.parse(input);
    final originalFormatString = toOriginalFormatString(date);
    return input == originalFormatString;
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  void genderChanged(obj, key, callback, {index, context}) {
    var gender = getObjectByKey(inputList, "gender");
    var salutation = getObjectByKey(inputList, "salutation");
    if (gender != null &&
        gender["value"] != null &&
        gender["value"] is String) {
      if (salutation != null && salutation["value"] != null) {
        var index = salutation["options"]
            .indexWhere((option) => option["value"] == salutation["value"]);
        if (index > -1) {
          if (salutation["options"][index]["remark"] !=
                  gender["value"][0].toUpperCase() &&
              salutation["options"][index]["remark"] != "E") {
            if (context != null) {
              showSnackBarError(
                  "Please select others salutation as gender not matched!");
              salutation["options"] = getMasterlookup(
                  type: "Salutation",
                  remark: ["E", gender["value"][0].toUpperCase()]);
              salutation["value"] = "";
            }
          } else {
            salutation["options"] = getMasterlookup(
                type: "Salutation",
                remark: ["E", gender["value"][0].toUpperCase()]);
          }
        }
      }

      var nric = getObjectByKey(inputList, "nric");
      var mypr = getObjectByKey(inputList, "mypr");
      if (nric != null && nric["value"].length == 12) {
        if ((int.parse(nric["value"][11]) % 2) == 0) {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Female") {
            gender["notice"] =
                "* ${getLocale("Please make sure the gender selected match with the New IC(myKad / myKid) you provided")}";
          } else {
            gender.remove("notice");
          }
        } else {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Male") {
            gender["notice"] =
                "* ${getLocale("Please make sure the gender selected match with the New IC(myKad / myKid) you provided")}";
          } else {
            gender.remove("notice");
          }
        }
      }
      if (mypr != null && mypr["value"].length == 12) {
        if ((int.parse(mypr["value"][11]) % 2) == 0) {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Female") {
            gender["notice"] =
                "* ${getLocale("Please make sure the gender selected match with the New IC(myKad / myKid) you provided")}";
          } else {
            gender.remove("notice");
          }
        } else {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Male") {
            gender["notice"] =
                "* ${getLocale("Please make sure the gender selected match with the New IC(myKad / myKid) you provided")}";
          } else {
            gender.remove("notice");
          }
        }
      }
    }
  }

  void autoPopulate(obj, key, callback, {index, context}) {
    try {
      if (key == "gender") {
        genderChanged(obj, key, callback, index: index, context: context);
        callback(key);
        return;
      }

      if (key == "postcode") {
        obj["city"]["type"] = "option1";
        obj["city"].remove("error");
        obj["state"]["type"] = "option1";
        obj["state"].remove("error");
        obj["postcode"]["type"] = "number";
        obj["postcode"]["maxLength"] = 5;
        if (!isNumeric(obj["postcode"]["value"])) {
          obj["postcode"]["value"] = "";
        }
        if (obj["postcode"]["value"].length == 5) {
          var ee = getCityByPostcode(obj["postcode"]["value"]);
          if (obj["state"] != null && obj["city"] != null && ee != null) {
            obj["state"]["value"] = ee["state"];
            obj["city"]["value"] = ee["city"];
          }
        }
        callback(key);
        return;
      }

      if (key == "mailingcountry" || key == "mailingpostcode") {
        if (obj["mailingcountry"]["value"] != "MYS") {
          obj["mailingpostcode"]["maxLength"] = 10;
          obj["mailingpostcode"]["type"] = "text";
          obj["mailingcity"]["type"] = "text";
          obj["mailingcity"].remove("error");
          obj["mailingstate"]["type"] = "text";
          obj["mailingstate"].remove("error");
        } else {
          obj["mailingcity"]["type"] = "option1";
          obj["mailingcity"].remove("error");
          obj["mailingstate"]["type"] = "option1";
          obj["mailingstate"].remove("error");
          obj["mailingpostcode"]["type"] = "number";
          obj["mailingpostcode"]["maxLength"] = 5;
          if (!isNumeric(obj["mailingpostcode"]["value"])) {
            obj["mailingpostcode"]["value"] = "";
          }
          if (obj["mailingpostcode"]["value"].length == 5) {
            var ee = getCityByPostcode(obj["mailingpostcode"]["value"]);
            if (obj["mailingstate"] != null &&
                obj["mailingcity"] != null &&
                ee != null) {
              obj["mailingstate"]["value"] = ee["state"];
              obj["mailingcity"]["value"] = ee["city"];
            }
          }
        }
        callback(key);
        return;
      }

      if (key == "nric" || key == "mypr") {
        var identitytype = getObjectByKey(inputList, "identitytype");
        String? error = validateID(key, obj[key], identitytype["clientType"]);
        if (error != null) {
          obj[key]["error"] = error;
          var dob = getObjectByKey(inputList, "dob");
          var gender = getObjectByKey(inputList, "gender");
          if (dob != null) {
            dob["value"] = "";
          }
          if (gender != null) {
            gender["value"] = "";
          }

          callback(key);
          return;
        } else {
          obj[key].remove("error");

          var dob = getObjectByKey(inputList, "dob");
          // print("i found dob as  = " + dob.toString());
          if (dob == null) {
            callback(key);
            return;
          }
          if (obj[key]["value"].isNotEmpty && obj[key]["value"].length == 12) {
            var year = obj[key]["value"].substring(0, 2);
            var day = obj[key]["value"].substring(4, 6);
            var month = obj[key]["value"].substring(2, 4);

            //TEMP WORKAROUND AS DateFormat not support for 2 digit as now
            if (int.parse(year) > 50) {
              year = "19$year";
            } else {
              year = "20$year";
            }
            var date = day + "/" + month + "/" + year;
            if (!isValidDate(year + month + day)) {
              obj[key]["error"] = "Invalid IC format";
              callback(key);
              return;
            }

            dob["value"] = DateFormat('dd/MM/yyyy', 'en_US')
                .parse(date)
                .microsecondsSinceEpoch;

            var gender = getObjectByKey(inputList, "gender");
            if (gender == null) {
              callback(key);
              return;
            }
            if ((int.parse(obj[key]["value"][11]) % 2) == 0) {
              gender["value"] = "Female";
              genderChanged(obj, "gender", callback,
                  index: index, context: context);
            } else {
              gender["value"] = "Male";
              genderChanged(obj, "gender", callback,
                  index: index, context: context);
            }

            if (obj["oldic"] != null) {
              if (int.parse(year) < 1977) {
                obj["oldic"]["enabled"] = true;
                obj["oldic"]["required"] = true;
              } else {
                obj["oldic"]["enabled"] = false;
                obj["oldic"]["required"] = false;
              }
            }
          }
          callback(key);
          return;
        }
      }

      if (key == "oldic" ||
          key == "birthcert" ||
          key == "passport" ||
          key == "policeic" ||
          key == "armyic") {
        var identitytype = getObjectByKey(inputList, "identitytype");
        String? error = validateID(key, obj[key], identitytype["clientType"]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "name") {
        String? error = validateName(obj[key]["value"], minLength: 5);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "usTaxId") {
        if (obj[key]["value"].isEmpty || obj[key]["value"].length < 9) {
          obj[key]["error"] = "Please enter a valid US Tax ID";
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "hometel" || key == "officetel") {
        String? error = validHomeTel(obj[key]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "mobileno") {
        String? error = validPhoneNo(obj[key]["value"]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "email") {
        String? error = validEmail(obj[key]["value"], checkAgentEmail: true);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
        callback(key);
        return;
      }

      if (key == "occupationDisplay") {
        var dob = getObjectByKey(inputList, "dob");
        if (dob["value"] != null && dob["value"] is! String) {
          var validOcc = validateOcc(dob["value"], obj[key]["value"]);
          if (!validOcc["isValid"]) {
            obj[key]["error"] = validOcc["message"];
          } else {
            obj[key].remove("error");
          }
        }
      }

      if (key == "bankname" || key == "bankaccounttype" || key == "accountno") {
        var regex = validateAccNo(obj);
        if (!regex["isValid"]) {
          obj["accountno"]["error"] = regex["message"];
        } else {
          obj["accountno"].remove("error");
        }
        callback(key);
        return;
      }
    } catch (e) {
      rethrow;
    }
  }
}
