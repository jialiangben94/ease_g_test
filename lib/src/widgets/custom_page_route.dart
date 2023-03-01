import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget? widget;

  CustomPageRoute({this.widget})
      : super(
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              animation =
                  CurvedAnimation(parent: animation, curve: Curves.easeIn);

              return ScaleTransition(
                  alignment: Alignment.topCenter,
                  scale: animation,
                  child: child);
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return widget!;
            });
}
