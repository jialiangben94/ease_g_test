import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final dynamic obj;
  final dynamic info;
  final String mainTitle;
  final String subTitle;
  final bool disableDelete;
  final bool disableEdit;
  final Function() onDeleteTap;
  final Function() onEditTap;
  final double? width;

  const InfoCard(
      {Key? key,
      this.obj,
      this.subTitle = "",
      this.mainTitle = "",
      this.info,
      this.disableDelete = false,
      this.disableEdit = false,
      this.width,
      required this.onEditTap,
      required this.onDeleteTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    dynamic nobj = obj ?? {};
    String mmainTitle = nobj["mainTitle"] ?? mainTitle;
    String ssubTitle = nobj["subTitle"] ?? mmainTitle;
    dynamic iinfo = nobj["info"] ?? info;
    bool ddisableDelete = nobj["disableDelete"] ?? disableDelete;
    bool ddisableEdit = nobj["disableEdit"] ?? disableEdit;
    double wwidth = nobj["width"] ?? width ?? gFontSize * 20;

    if (iinfo == null || (iinfo is! Map && iinfo is! List)) {
      throw ("InfoCard param info is only allow Map/List");
    }

    if (iinfo is Map) iinfo = [iinfo];
    var deleteButton = !ddisableDelete
        ? Align(
            alignment: Alignment.topRight,
            child: InkWell(
                onTap: onDeleteTap,
                child: Icon(Icons.close, size: gFontSize * 1.4)))
        : const SizedBox();

    Widget columnInfo(info, wwidth) {
      List<Widget> infoWid = [];
      List<Widget> array = [];
      info.forEach((i) {
        for (var key in i.keys) {
          if (key == "title") continue;
          if (key == "size") continue;
          if (key == "naText") continue;

          array.add(SizedBox(
              width: wwidth * 0.89,
              child: Row(children: [
                Expanded(
                    flex: i["size"]["labelWidth"],
                    child: Text(i[key]["label"],
                        style: bFontWN().copyWith(color: greyTextColor))),
                Expanded(
                    flex: i["size"]["valueWidth"],
                    child: i[key]["value"] is String
                        ? Text(i[key]["value"], style: bFontWN())
                        : Transform.scale(
                            scale: 0.9,
                            alignment: Alignment.centerLeft,
                            child: i[key]["value"]))
              ])));
        }

        infoWid.add(Container(
            padding: EdgeInsets.only(bottom: gFontSize * 0.8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              i["title"] != null
                  ? Text(i["title"], style: bFontWN())
                  : Container(),
              SizedBox(height: gFontSize * 0.8),
              ...array
            ])));
      });
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: infoWid));
    }

    var infoContainer =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: gFontSize * 0.7),
      Text(ssubTitle, style: bFontWN().copyWith(color: greyTextColor)),
      Text(mmainTitle, style: t2FontW5()),
      SizedBox(height: gFontSize * 0.2),
      columnInfo(iinfo, wwidth)
    ]);

    var content = Container(
        padding: EdgeInsets.all(gFontSize),
        width: wwidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.2)),
            border: Border.all(color: Colors.grey[400]!)),
        child: Stack(children: [infoContainer, deleteButton]));

    var editContainer =
        !ddisableEdit ? InkWell(onTap: onEditTap, child: content) : content;

    return editContainer;
  }
}
