import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';

const double commonTextFieldHeight = 70;
double dScreenWidth = 1024;
double dScreenHeight = 767;
// double MIN_screenWidth = 784;
// double MIN_screenHeight = 393;
double screenWidth = 1024;
double screenHeight = 768;
double gFontSize = (dScreenWidth + dScreenHeight) * 0.01;

BoxDecoration textFieldBoxDecoration() {
  return BoxDecoration(
      border: Border.all(color: greyBorderTFColor),
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

BoxDecoration textFieldScarletRedBoxDecoration() {
  return BoxDecoration(
      border: Border.all(color: scarletRedColor),
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

InputDecoration textFieldInputDecoration() {
  return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)));
}

InputDecoration disabledTextFieldInputDecoration() {
  return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      filled: true,
      fillColor: silverGreyColor);
}

// var f = (dScreenWidth + dScreenHeight) * 0.010051;
// print("18 f" + f.toString());
// print("16 f" + (f * 0.8889).toString());
// print("14 f" + (f * 0.7778).toString());
// print("20 f" + (f * 1.1111).toString());
// print("24 f" + (f * 1.3333).toString());
// print("30 f" + (f * 1.6666).toString());

//font30
TextStyle tFontBB() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize * 1.6666,
      color: Colors.black,
      fontWeight: FontWeight.bold);
}

TextStyle tFontWN() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize * 1.6666,
      fontWeight: FontWeight.w500,
      color: Colors.black);
}

//font24
TextStyle tFontW5() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize * 1.3333,
      color: Colors.black,
      fontWeight: FontWeight.w500);
}

//font20
TextStyle t1FontWN() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize * 1.1111,
      color: Colors.black,
      fontWeight: FontWeight.normal);
}

TextStyle t1FontW5() {
  return t1FontWN().copyWith(fontWeight: FontWeight.w500);
}

TextStyle t1FontWB() {
  return t1FontWN().copyWith(fontWeight: FontWeight.bold);
}

//font18
TextStyle t2FontWN() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize,
      color: Colors.black,
      fontWeight: FontWeight.normal);
}

TextStyle t2FontW5() {
  return t2FontWN().copyWith(fontWeight: FontWeight.w500);
}

TextStyle t2FontWB() {
  return t2FontWN().copyWith(fontWeight: FontWeight.bold);
}

double font16() {
  return gFontSize * 0.8889;
}

//font16
TextStyle bFontWN() {
  return TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: 'Meta',
      fontSize: font16(),
      color: Colors.black);
}

TextStyle bFontW5() {
  return bFontWN().copyWith(fontWeight: FontWeight.w500);
}

TextStyle bFontWB() {
  return bFontWN().copyWith(fontWeight: FontWeight.bold);
}

//font14
TextStyle sFontWN() {
  return TextStyle(
      fontFamily: 'Meta',
      fontSize: gFontSize * 0.7778,
      color: Colors.black,
      fontWeight: FontWeight.normal);
}

TextStyle sFontW5() {
  return sFontWN().copyWith(fontWeight: FontWeight.w500);
}

TextStyle sFontWB() {
  return sFontWN().copyWith(fontWeight: FontWeight.bold);
}

//font12
TextStyle ssFontWN() {
  return TextStyle(
      fontFamily: 'Meta', fontSize: gFontSize * 0.635, color: greyTextColor);
}

EdgeInsetsGeometry textFieldPaddingBetween() {
  return const EdgeInsets.only(bottom: 10.0, top: 10.0);
}

void calculateFontSize(context) {
  screenWidth = MediaQuery.of(context).size.width;
  screenHeight = MediaQuery.of(context).size.height;
  var swd = screenWidth / dScreenWidth;
  var shd = screenHeight / dScreenHeight;
  gFontSize = ((dScreenWidth * swd) + (dScreenHeight * shd)) * 0.010051;
}
