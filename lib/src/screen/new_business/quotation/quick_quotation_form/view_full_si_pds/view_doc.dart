import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class ViewDoc extends StatefulWidget {
  @required
  final QuickQuotation? quickQuotation;
  @required
  final String? doctype;

  const ViewDoc({Key? key, this.quickQuotation, this.doctype})
      : super(key: key);

  @override
  ViewDocState createState() => ViewDocState();
}

class ViewDocState extends State<ViewDoc> {
  @override
  void initState() {
    super.initState();
  }

  Future<File> writeFile() async {
    try {
      if (widget.quickQuotation!.quotationHistoryID != null) {
        final docPath = await getTemporaryDirectory();
        final docFile = File(
            '${docPath.path}/${widget.quickQuotation!.productPlanName}${widget.doctype}-${widget.quickQuotation!.quotationHistoryID}.pdf');
        var obj = {
          "Method": "GET",
          "Param": {
            "QuotationHistoryID":
                widget.quickQuotation!.quotationHistoryID.toString(),
            "DocType": widget.doctype
          }
        };
        log(jsonEncode(obj));
        await NewBusinessAPI().quotation(obj).then((value) async {
          if (value != null && value["Base64"] != null) {
            var bytes = base64Decode(value["Base64"]);
            await docFile.writeAsBytes(bytes.buffer.asUint8List());
          }
        });
        return docFile;
      } else {
        final docFile = File('');
        return docFile;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget failedToLoad() {
      return Center(
          child: Container(
              padding: EdgeInsets.all(gFontSize),
              constraints: BoxConstraints(
                  minWidth: gFontSize * 20,
                  maxWidth: gFontSize * 20,
                  maxHeight: gFontSize * 6),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: greyBorderColor),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(getLocale("Failed to load document(s)"),
                  textAlign: TextAlign.center, style: bFontWN())));
    }

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: FutureBuilder<File>(
            future: writeFile(),
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.path != "" && snapshot.data!.existsSync()) {
                  return PdfView(path: snapshot.data!.path);
                } else {
                  return failedToLoad();
                }
              }
              if (snapshot.hasError) {
                return failedToLoad();
              } else {
                return buildLoading();
              }
            }));
  }
}
