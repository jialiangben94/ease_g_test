import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

// /*  To add a new data onto the form, you must:

//     1) Add a data model at data/new_business_model/form_model.dart (Data validation)
//     2) Once done, need to add bloc -> state, event and bloc. (All three must edit)
//     3) The form is inside screen/new_business/{}.
//     ... However each textfield is placed inside here for better visibility.
//     4) Once added for both 1 & 2, do remember to add it in quotation data model (new_business_model/quotation.dart)
//     5) Then in customer_details, add it in submitForm function.

//     NOTE:

//     1 & 2 is for form validation.
//     4 & 5 is for sembast configuration

//     We'll see if there's a better way to do this later.

// */

BoxDecoration disabledTextFieldBoxDecoration() {
  return BoxDecoration(
      border: Border.all(color: Colors.red),
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

InputDecoration errorTextFieldInputDecoration() {
  return const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red, width: 1.0)));
}

TextStyle textFieldStyle() {
  return t2FontW5();
}
