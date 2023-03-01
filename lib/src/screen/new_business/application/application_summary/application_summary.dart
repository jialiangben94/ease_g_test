import 'dart:convert';
import 'dart:developer';

import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_list/application_list_home.dart';
import 'package:ease/src/screen/new_business/application/decision/summary.dart';
import 'package:ease/src/screen/new_business/application/application_summary/proposal_detail.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/product_details.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/required_file_handler.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/vertical_tabs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationSummary extends StatefulWidget {
  final int? quoId;
  final String? qquoId;
  final int? appQuoId;

  const ApplicationSummary({Key? key, this.quoId, this.qquoId, this.appQuoId})
      : super(key: key);
  @override
  ApplicationSummaryState createState() => ApplicationSummaryState();
}

class ApplicationSummaryState extends State<ApplicationSummary>
    with SingleTickerProviderStateMixin {
  dynamic data;

  TabController? tabController;
  int? currentIndex;
  bool hide = false;

  final List<String> summaryTabs = [
    getLocale("Application"),
    getLocale("SI/MI (Quotation)")
  ];

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Application Summary", "ApplicationSummary");
    currentIndex = 0;
    tabController = TabController(vsync: this, length: summaryTabs.length);
    tabController!.addListener(_setActiveTabIndex);
    getAppDetails();
  }

  void _setActiveTabIndex() {
    setState(() {
      currentIndex = tabController!.index;
    });
  }

  @override
  void dispose() {
    tabController!.dispose();

    ApplicationFormData.data = null;
    ApplicationFormData.currentHome = null;
    ApplicationFormData.id = null;
    ApplicationFormData.isAmlaChecking = {};
    if (ApplicationFormData.amlaTimer is Map) {
      for (var i in ApplicationFormData.amlaTimer.keys) {
        ApplicationFormData.amlaTimer[i]?.cancel();
      }
    }
    ApplicationFormData.amlaTimer = {};
    ApplicationFormData.isPaymentChecking = {};
    if (ApplicationFormData.paymentTimer != null &&
        ApplicationFormData.paymentTimer is Map) {
      for (var i in ApplicationFormData.paymentTimer.keys) {
        ApplicationFormData.paymentTimer[i]?.cancel();
      }
    }
    ApplicationFormData.paymentTimer = {};
    ApplicationFormData.tabList = null;
    ApplicationFormData.onTitleClicked = null;
    ApplicationFormData.optionList = null;
    ApplicationFormData.optionType = null;

    super.dispose();
  }

  void getAppDetails() async {
    await readOptionFileAsObj().then((optionList) {
      setState(() {
        ApplicationFormData.optionList = optionList["optionList"];
        ApplicationFormData.optionType = optionList["optionType"];
        ApplicationFormData.translation = optionList["translation"];
        ApplicationFormData.languageId = optionList["languageId"];
      });
    }).catchError((err) {
      Navigator.of(context).pop();
      showAlertDialog2(context, getLocale("Error"),
          getLocale("Master data cannot be loaded."));
    });
    if (widget.appQuoId != null) {
      await initDataSummary(widget.appQuoId as int).then((status) async {
        if (status != null && status["status"] && status["data"] != null) {
          setState(() {
            ApplicationFormData.data = data = status["data"];
            ApplicationFormData.id = widget.appQuoId;
          });
        } else if (status != null && status["msg"] != null) {
          setState(() {
            ApplicationFormData.data = data = status["data"];
            ApplicationFormData.id = widget.appQuoId;
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog2(
              context, getLocale("Error"), getLocale("Record not found."));
        }
      }).catchError((err) {
        Navigator.of(context).pop();
        showAlertDialog2(
            context, getLocale("Error"), getLocale("Record not found."));
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
        showAlertDialog2(
            context, getLocale("Error"), getLocale("Record not found."));
      });
    }
    if (data != null) {
      log(jsonEncode(await getSubmitAppObj(setID: data["SetID"])));
      var temp = json.decode(json.encode(data));

      temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));

      temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));

      temp["policyOwner"] = json.encode(temp["policyOwner"]);
      temp["lifeInsured"] = json.encode(temp["lifeInsured"]);

      temp = Quotation.fromMap(temp);
      if (temp.buyingFor == BuyingFor.self.toStr) {
        temp.lifeInsured.clientType = lookupClientType["poli"];
        temp.policyOwner.clientType = lookupClientType["poli"];
      } else {
        temp.policyOwner.clientType = lookupClientType["policyOwner"];
        temp.lifeInsured.clientType = lookupClientType["lifeInsured"];
      }
      var p = data["listOfQuotation"][0];
      var temp2 = json.decode(json.encode(p));
      temp2 = QuickQuotation.fromMap(temp2);

      var pref = await SharedPreferences.getInstance();
      Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
      String? isGIO;
      var encodeJson = temp.toJsonServer(temp2, "A", agent, isGIO);
      log(jsonEncode(encodeJson));
    }
  }

  Future<dynamic> getPropDetails(data) async {
    dynamic appStatus;
    await NewBusinessAPI().getApplicationStatus(
        [data["application"]["ProposalNo"]]).then((value) {
      data["application"]["ApplicationStatus"] = value["StatusList"][0];
      appStatus = {
        "PropStatus": value["StatusList"][0]["PropStatus"],
        "ApplicationStatus": value["StatusList"][0]["ApplicationStatus"],
        "SubmittedDatetime": value["StatusList"][0]["SubmittedDatetime"],
        "LeaderAckStatus": value["StatusList"][0]["LeaderAckStatus"],
        "LeaderAckDatetime": value["StatusList"][0]["LeaderAckDatetime"],
        "FailSubmitReason": value["StatusList"][0]["FailSubmitReason"],
        "PaymentStatus": value["StatusList"][0]["IsPaymentDone"],
        "Message": value["Message"],
        "IsSuccess": value["IsSuccess"]
      };
    }).catchError((err) {
      appStatus = {"IsSuccess": false};
    });
    return appStatus;
  }

  @override
  Widget build(BuildContext context) {
    Widget applicationSummary() {
      if (data == null) return Container();

      List<Widget> customerList = [];
      if (data["buyingFor"] == BuyingFor.self.toStr) {
        customerList.add(customerDetails(
            data["policyOwner"], getLocale("Policy Owner", entity: true)));
      } else {
        customerList.add(customerDetails(
            data["policyOwner"], getLocale("Policy Owner", entity: true)));
        customerList.add(customerDetails(
            data["lifeInsured"], getLocale("Life Insured", entity: true)));
      }
      if (data["payor"]["whopaying"] != "policyOwner" &&
          data["payor"]["whopaying"] != "lifeInsured") {
        customerList.add(customerDetails(data["payor"], getLocale("Payor")));
      }
      if (data["consentMinor"] != null &&
          data["consentMinor"] &&
          data["guardian"] != null) {
        customerList.add(customerDetails(
            data["guardian"], getLocale("Parent/Legal Guardian")));
      }

      return VerticalTabs(tabsWidth: dScreenWidth * 0.3, titles: [
        getLocale('Customer'),
        getLocale('Financial Need Analysis'),
        getLocale('Disclosure'),
        getLocale('Recommended Products'),
        getLocale('Nomination'),
        getLocale('Questions'),
        getLocale('Decision'),
        getLocale('Identity & Signature'),
        getLocale('Payment')
      ], contents: [
        Column(children: customerList),
        Column(children: [
          protentialArea(data, isSummary: true),
          SizedBox(height: gFontSize),
          investmentPref(data, isSummary: true)
        ]),
        clientChoice(data, isSummary: true),
        recommendedProduct(data, onChange: () {
          currentIndex = 2;
          tabController!.animateTo(1);
        }),
        nomination(data),
        Column(children: [
          policyOwnerHealthQuestion(data),
          lifeInsuredHealthQuestion(data)
        ]),
        decisionSummary(data),
        identitySignatureSummary(data),
        paymentSummary(data)
      ]);
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(children: [
              normalAppBar(context, ""),
              data != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: gFontSize * 3),
                      child: FutureBuilder<dynamic>(
                          future: getPropDetails(data),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              return ProposalDetails(data, snapshot.data);
                            } else {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(
                                            getLocale("Proposal Details"),
                                            style: tFontW5()
                                                .copyWith(color: Colors.black)))
                                  ]));
                            }
                          }))
                  : Container(),
              data != null
                  ? Stack(children: [
                      Positioned(
                          right: 0,
                          bottom: 0,
                          left: 0,
                          child: Container(
                              color: greyDividerColor,
                              height: 1,
                              width: double.infinity)),
                      Padding(
                          padding: EdgeInsets.only(left: gFontSize * 3),
                          child: Align(
                              alignment: Alignment.bottomLeft,
                              child: TabBar(
                                  isScrollable: true,
                                  onTap: (index) {
                                    currentIndex = index;
                                    tabController!.animateTo(index);
                                  },
                                  indicatorColor: Colors.transparent,
                                  tabs: [
                                    for (int i = 0; i < summaryTabs.length; i++)
                                      Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 12, left: 20, right: 20),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 5,
                                                      color: i == currentIndex
                                                          ? honeyColor
                                                          : Colors
                                                              .transparent))),
                                          child: Text(summaryTabs[i],
                                              style: t1FontW5().copyWith(
                                                  color: Colors.black)))
                                  ])))
                    ])
                  : Container(),
              data != null
                  ? Expanded(
                      child: TabBarView(controller: tabController, children: [
                      Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: gFontSize * 2),
                          child: applicationSummary()),
                      SingleChildScrollView(
                          child: ProductInfo(info: data, isSummary: true))
                    ]))
                  : SizedBox(height: dScreenHeight * 0.9, child: buildLoading())
            ])));
  }
}
