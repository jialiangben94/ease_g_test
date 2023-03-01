import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

enum ConfirmAction { cancel, yes }

Future<ConfirmAction?> confirmDeleteDialog(
    BuildContext context, String object) async {
  return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.45),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        title: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                                '${getLocale("Are you sure you want to delete this")} ${getLocale(object)}${getLocale("Are you sure you want to delete this BM")}?',
                                style: bFontW5().apply(fontSizeFactor: 1.2))),
                        content: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(ConfirmAction.cancel);
                                        },
                                        // padding:
                                        //     EdgeInsets.symmetric(vertical: 16),
                                        child: Text(getLocale('No'),
                                            style: t2FontWB()))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () async {
                                          Navigator.of(context)
                                              .pop(ConfirmAction.yes);
                                        },
                                        style: TextButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            backgroundColor: honeyColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16)),
                                        // shape: RoundedRectangleBorder(
                                        //     borderRadius: BorderRadius.all(
                                        //         Radius.circular(10.0))),
                                        // color: honeyColor,
                                        // padding:
                                        //     EdgeInsets.symmetric(vertical: 16),
                                        child: Text(getLocale('Yes'),
                                            style: t2FontWB())))
                              ])
                            ])))));
      });
}
