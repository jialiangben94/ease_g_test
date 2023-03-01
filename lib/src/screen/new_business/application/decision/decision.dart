import 'package:ease/src/screen/new_business/application/decision/product_summary_table.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/screen/new_business/application/decision/summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../util/function.dart';

class Decision extends StatefulWidget {
  final dynamic info;
  final Function(dynamic obj) callback;

  const Decision({Key? key, this.info, required this.callback})
      : super(key: key);

  @override
  DecisionState createState() => DecisionState();
}

class DecisionState extends State<Decision> {
  var isLoading = true;
  late String assessmentDate;

  @override
  void initState() {
    super.initState();
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');
    assessmentDate = widget.info["assessmentDate"] != null
        ? "${getLocale("Last assessment date & time")} : ${df.format(DateTime.fromMicrosecondsSinceEpoch(widget.info["assessmentDate"]))}"
        : "";
    var product = widget.info["listOfQuotation"][0];
    String prodCode = product["productPlanCode"];

    if (widget.info["tsarRes"] != null ||
        (prodCode == "PCTA01" ||
            prodCode == "PCWA01" ||
            prodCode == "PCEL01" ||
            prodCode == "PCEE01" ||
            prodCode == "PTJI01" ||
            prodCode == "PTHI01" ||
            prodCode == "PTHI02")) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.callback({"payAmount": product["totalPremium"]}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(gFontSize * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(getLocale("Decision")), Text(assessmentDate)]),
          ProductTable(data: widget.info, tsar: true),
          summaryAllDetails(widget.info)
        ]));
  }
}
