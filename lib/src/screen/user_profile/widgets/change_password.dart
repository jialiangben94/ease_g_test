import 'dart:convert';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';

import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  final Function _editPassword;
  const ChangePassword(this._editPassword, {Key? key}) : super(key: key);
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newPassword2 = TextEditingController();

  final focusCurrentP = FocusNode();
  final focusNewP1 = FocusNode();
  final focusNewP2 = FocusNode();

  bool isUpdating = false;
  String _passwordStrength = "";

  void changePassword() async {
    var pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

    await ServicingAPI()
        .changePassword(
            agent.accountCode, currentPassword.text, newPassword.text)
        .then((res) {
      if (res != null) {
        if (res["Message"] == "Change password successful") {
          // Show success message.
          showSnackBarSuccess(res['Message']);

          // Navigate user to Home
          Future.delayed(const Duration(seconds: 2), () {
            currentPassword.clear();
            newPassword.clear();
            newPassword2.clear();
            widget._editPassword();
          });
        } else {
          showSnackBarError("Error: ${res['Message']}");
        }
      } else {
        showSnackBarError("Error: Failed to change password");
      }
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          isUpdating = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.only(left: 60),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(getLocale("Current Password"), style: bFontWN())),
              TextFormField(
                  controller: currentPassword,
                  obscureText: true,
                  cursorColor: Colors.grey,
                  decoration: textFieldInputDecoration(),
                  textInputAction: TextInputAction.next,
                  focusNode: focusCurrentP,
                  onTap: () {
                    FocusScope.of(context).requestFocus(focusCurrentP);
                  },
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNewP1);
                  },
                  validator: (value) {
                    return validatePassword(value!);
                  }),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(getLocale("New Password"), style: bFontWN())),
              TextFormField(
                  controller: newPassword,
                  obscureText: true,
                  cursorColor: Colors.grey,
                  decoration: textFieldInputDecoration(),
                  focusNode: focusNewP1,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                  onChanged: (value) {
                    double strength = estimatePasswordStrength(value);
                    if (strength < 0.3) {
                      setState(() {
                        _passwordStrength = 'Weak password';
                      });
                    } else if (strength < 0.7) {
                      setState(() {
                        _passwordStrength = 'Strong password';
                      });
                    } else {
                      setState(() {
                        _passwordStrength = 'Very strong password';
                      });
                    }
                  },
                  validator: (value) {
                    RegExp regExpLowercase = RegExp(r'^(?=.*?[a-z])');
                    RegExp regExpUppercase = RegExp(r'^(?=.*?[A-Z])');
                    RegExp regExpSpecialCharacter =
                        RegExp(r'^(?=.*?[#?!@$%^&*-])');
                    RegExp regExpNumber = RegExp(r'^(?=.*?[0-9])');

                    if (value!.isEmpty) {
                      return getLocale('Please enter new password');
                    }
                    if (value.length < 8) {
                      return getLocale(
                          'Password must be more than 8 character');
                    }
                    if (!regExpLowercase.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a lower case');
                    } else if (!regExpUppercase.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least an upper case');
                    } else if (!regExpSpecialCharacter.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a special character');
                    } else if (!regExpNumber.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a number');
                    }
                    if (value != newPassword2.text) return 'Not match';
                    return null;
                  }),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child:
                      Text(getLocale("Retype New Password"), style: bFontWN())),
              TextFormField(
                  controller: newPassword2,
                  cursorColor: Colors.grey,
                  obscureText: true,
                  decoration: textFieldInputDecoration(),
                  textInputAction: TextInputAction.done,
                  focusNode: focusNewP2,
                  onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                  validator: (value) {
                    RegExp regExpLowercase = RegExp(r'^(?=.*?[a-z])');
                    RegExp regExpUppercase = RegExp(r'^(?=.*?[A-Z])');
                    RegExp regExpSpecialCharacter =
                        RegExp(r'^(?=.*?[#?!@$%^&*-])');
                    RegExp regExpNumber = RegExp(r'^(?=.*?[0-9])');

                    if (value!.isEmpty) {
                      return getLocale('Please enter new password');
                    }
                    if (value.length < 8) {
                      return getLocale(
                          'Password must be more than 8 character');
                    }
                    if (!regExpLowercase.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a lower case');
                    } else if (!regExpUppercase.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least an upper case');
                    } else if (!regExpSpecialCharacter.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a special character');
                    } else if (!regExpNumber.hasMatch(value)) {
                      return getLocale(
                          'Password must contains at least a number');
                    }
                    if (value != newPassword.text) {
                      return getLocale('Not match');
                    }
                    return null;
                  }),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child:
                      Text(getLocale("Password Strength"), style: bFontWN())),
              Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(_passwordStrength,
                      style: bFontW5().copyWith(
                          color: _passwordStrength == "Weak password"
                              ? Colors.orange
                              : _passwordStrength == "Strong password"
                                  ? Colors.lightGreen
                                  : _passwordStrength == "Very strong password"
                                      ? Colors.green
                                      : Colors.black))),
              Row(children: [
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          isUpdating = true;
                        });
                        changePassword();
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: cyanColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    // color: cyanColor,
                    // padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(5.0)),
                    child: isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)))
                        : Text(getLocale("Save"),
                            style: bFontW5().apply(color: Colors.white)))
              ])
            ])));
  }
}
