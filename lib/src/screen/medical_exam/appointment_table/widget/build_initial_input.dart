import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';

Widget buildInitialInput(BuildContext context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Image(
                width: 140,
                height: 150,
                image: AssetImage('assets/images/no_appt_icon.png')),
            Text(getLocale("No request found"),
                style: sFontWN().copyWith(color: Colors.grey))
          ]));
}

Widget buildError(BuildContext context, String message) {
  return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        const Image(
            width: 140,
            height: 150,
            image: AssetImage('assets/images/no_appt_icon.png')),
        Text(message, style: sFontWN())
      ]));
}
