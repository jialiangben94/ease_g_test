import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/product_table.dart';
import 'package:ease/src/screen/new_business/application/remote/widget/dialog.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/row_container.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';

class ApplicationCompleted extends StatefulWidget {
  final int? id;
  final String? quotationId;
  final dynamic data;

  const ApplicationCompleted({Key? key, this.id, this.quotationId, this.data})
      : super(key: key);
  @override
  ApplicationCompletedState createState() => ApplicationCompletedState();
}

class ApplicationCompletedState extends State<ApplicationCompleted> {
  dynamic data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Proposal Completed", "ProposalCompleted");
    if (widget.data != null) {
      data = widget.data;
    } else if (widget.id != null) {
      getByID(widget.id as int).then((idData) {
        data = idData["data"];
        setState(() {});
      }).catchError((error) {
        Navigator.of(context).pop();
        showAlertDialog(context, getLocale("Error"),
            getLocale("No available record found."));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog(context, getLocale("Error"),
            getLocale("No available record found."), () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return wholeScreenLoading();
    }

    Widget bottomBar() {
      var obj = [
        {"size": 52},
        {
          "size": 25,
          "value": CustomButton(
              label: getLocale("Back to Home"),
              buttonColor: cyanColor,
              labelColor: Colors.white,
              fontWeight: FontWeight.w500,
              onPressed: () async {
                if (await (confirmExit(context))) {
                  await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                      (route) => false);
                }
              })
        }
      ];

      return RowContainer(
          arrayObj: obj,
          padding: EdgeInsets.symmetric(
              horizontal: gFontSize * 0.8, vertical: gFontSize * 0.5),
          color: honeyColor,
          height: gFontSize * 4);
    }

    Widget header() {
      return Center(
          child: Column(children: [
        Image(
            width: gFontSize * 4,
            height: gFontSize * 4,
            image: const AssetImage('assets/images/submitted_icon.png')),
        Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize),
            child: Text(getLocale("Proposal Completed!"), style: tFontBB())),
        Text(
            getLocale(
                "Thank you for choosing Etiqa as your Life Insurance Protection. We promise to serve you well.",
                entity: true),
            style: t1FontWN().copyWith(color: greyTextColor)),
        Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize * 2),
            child: Text(
                " ${getLocale("An electronic proposal is sent to both")} ${getLocale("Policy Owner", entity: true)} ${getLocale("and")} ${getLocale("Life Insured", entity: true)}${getLocale("'s email address")}.",
                style: t2FontWN().copyWith(color: greyTextColor)))
      ]));
    }

    Widget proposalDetails() {
      var obj = [
        {
          "size": {"labelWidth": 30, "valueWidth": 70},
          "p": {
            "label": getLocale("Proposal No"),
            "value": data["application"] != null &&
                    data["application"]["ProposalNo"] != null
                ? data["application"]["ProposalNo"]
                : "-"
          },
          "n": {
            "label": getLocale("Life Insured's Name", entity: true),
            "value": data["lifeInsured"]["name"]
          },
          "g": {
            "label": getLocale("Gender"),
            "value": getLocale(data["lifeInsured"]["gender"])
          },
          "l": {
            "label": getLocale("Application Last Update Date"),
            "value": getStandardDateFormat()
          }
        }
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Proposal Details"), style: t1FontW5()),
        SizedBox(height: gFontSize),
        CustomColumnTable(arrayObj: obj),
        SizedBox(height: gFontSize * 2)
      ]);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              progressBar(context, gFontSize * 0.5, 1),
              Container(
                  padding: EdgeInsets.all(gFontSize * 3),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header(),
                        proposalDetails(),
                        Text(getLocale("Basic Plan Details"),
                            style: t2FontW5()),
                        SizedBox(height: gFontSize),
                        ProductTable(info: data, isSITable: true)
                      ]))
            ])),
        bottomNavigationBar: bottomBar());
  }
}
