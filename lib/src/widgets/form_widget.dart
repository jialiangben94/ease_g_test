import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

Padding greyFormTitle(String title) {
  return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Text(title, style: t2FontWN().copyWith(color: Colors.grey)));
}

Padding blackFormTitle(String title) {
  return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(title, style: t2FontW5()));
}

Padding normalBlackTitle(String title) {
  return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(title, style: bFontWN()));
}

SizedBox textField(context, TextEditingController controller) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: TextField(
          controller: controller,
          cursorColor: Colors.grey,
          style: t1FontWN(),
          decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0)))));
}

Padding sideTitle(String title, String currentPage, double horizontal,
    double verticalPadding) {
  return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
          color: currentPage == title ? lightCyanColor : Colors.transparent,
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(children: [
                Text(title, style: bFontW5()),
                Visibility(
                    visible: currentPage == title,
                    child: Icon(Icons.adaptive.arrow_forward))
              ]))));
}

Center showProgress(String title) {
  return Center(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, offset: Offset(0.0, 1.0))
                  ]),
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 15.0, bottom: 5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(yellowColor)),
                            const SizedBox(height: 10),
                            Text(title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: "Meta",
                                    fontWeight: FontWeight.w500))
                          ]))))));
}

InputDecoration textFieldInputDecoration() {
  return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cyanColor, width: 1.0)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)));
}
