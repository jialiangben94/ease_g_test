import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  final dynamic obj;
  final List? items;
  final Function(int value)? onSelected;
  final Function()? onCanceled;

  const PopupMenu(
      {Key? key, this.obj, this.items, this.onSelected, this.onCanceled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const IconData icon = Icons.more_vert;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    dynamic objj = obj ?? {};

    List? itemss = objj["items"] ?? items;
    IconData iconn = objj["icon"] ?? icon;
    Function(int value)? onSelectedd = objj["onSelected"] ?? onSelected;
    Function()? onCanceledd = objj["onCanceled"] ?? onCanceled;

    List<PopupMenuEntry<int>> menu = [];

    for (var i = 0; i < itemss!.length; i++) {
      if (itemss[i] is String) {
        menu.add(
            PopupMenuItem(value: i, child: Text(itemss[i], style: bFontWN())));
      } else if (itemss[i] is Widget) {
        menu.add(itemss[i]);
      } else if (itemss[i] is Map) {
        if (itemss[i]["label"] != null && itemss[i]["value"] != null) {
          menu.add(PopupMenuItem(
              value: itemss[i]["value"],
              child: Text(itemss[i]["label"], style: bFontWN())));
        }
      }
    }

    return PopupMenuButton<int>(
        itemBuilder: (context) => menu,
        onCanceled: onCanceledd,
        onSelected: onSelectedd,
        icon: Icon(iconn));
  }
}
