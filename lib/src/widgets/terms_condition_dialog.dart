import 'package:ease/src/data/tnc_statement_data.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

Widget tncTitleContainer(String tncTitle) {
  return Container(
      decoration: BoxDecoration(
          color: lightHoneyColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12.0),
          child: Text(tncTitle, style: t2FontW5())));
}

Widget agreeButton(double width, onPressed) {
  return Container(
      width: width,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300]!,
                spreadRadius: 0.05,
                blurRadius: 1,
                // changes position of shadow
                offset: const Offset(0, -1))
          ],
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            SizedBox(
                width: 160,
                child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(honeyColor),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(15)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(honeyColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: BorderSide(color: honeyColor)))),
                    onPressed: onPressed,
                    child: Text(getLocale("I agree"), style: t2FontWN())))
          ])));
}

dynamic showTncDialog(BuildContext context, onagree) {
  return showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      barrierDismissible: false,
      barrierLabel: "Dialog", // label for barrier
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(builder: (context, setState) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;

          return Scaffold(
              backgroundColor: Colors.transparent,
              body: SizedBox.expand(
                  child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Stack(children: [
                        Center(
                            child: SizedBox(
                                width: width * (width > height ? 0.7 : 0.8),
                                height: height * 0.85,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0.0, horizontal: 0),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          tncTitleContainer(tncTitle),
                                          Expanded(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20.0,
                                                          right: 20,
                                                          top: 16),
                                                  child: SingleChildScrollView(
                                                      child: Column(children: [
                                                    Html(data: termsOfUse)
                                                  ])))),
                                          agreeButton(width, () async {
                                            onagree();
                                          })
                                        ]))))
                      ]))));
        });
      });
}
