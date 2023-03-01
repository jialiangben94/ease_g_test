import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/coverage.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ViewCoverage extends StatefulWidget {
  final int? qtnId;
  final String? quickQtnId;
  final Quotation? qtn;
  final String? status;

  // Status
  // 1 - Duplicating quotation
  // 2 - Edit Quotation

  const ViewCoverage(this.qtnId, this.qtn,
      {Key? key, this.status, this.quickQtnId})
      : super(key: key);
  @override
  ViewCoverageState createState() => ViewCoverageState();
}

class ViewCoverageState extends State<ViewCoverage> {
  double textFieldHeight = 60.0;
  bool isConnected = false;
  bool isLoading = false;
  List<Coverage> purchasedCoverage = [];
  List<Coverage> existingCoverage = [];

  late QuotationBloc _qtnBloc;

  @override
  void initState() {
    checkConn();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        if (result != ConnectivityResult.none) {
          isConnected = true;
        } else {
          isConnected = false;
        }
      });
    });
    populateCoverage();
    super.initState();
    _qtnBloc = BlocProvider.of<QuotationBloc>(context);
    analyticsSetCurrentScreen("View Current Coverage", "ViewCurrentCoverage");
  }

  void checkConn() async {
    ConnectivityResult conn = await (Connectivity().checkConnectivity());
    setState(() {
      if (conn != ConnectivityResult.none) {
        isConnected = true;
      } else {
        isConnected = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void populateCoverage() {
    if (widget.qtn!.lifeInsured!.existingCoverage != null) {
      for (var coverage in widget.qtn!.lifeInsured!.existingCoverage!) {
        if (coverage.policyType == "Plan") {
          purchasedCoverage.add(coverage);
        }
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverage != null) {
      for (var coverage in widget.qtn!.policyOwner!.existingCoverage!) {
        if (coverage.policyType == "Plan") {
          purchasedCoverage.add(coverage);
        }
      }
    }

    if (widget.qtn!.lifeInsured!.existingCoverage != null) {
      for (var coverage in widget.qtn!.lifeInsured!.existingSavingInvestPlan!) {
        existingCoverage.add(coverage);
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverage != null) {
      for (var coverage in widget.qtn!.policyOwner!.existingSavingInvestPlan!) {
        existingCoverage.add(coverage);
      }
    }

    if (widget.qtn!.lifeInsured!.existingCoverage != null) {
      for (var coverage in widget.qtn!.lifeInsured!.existingMedicalPlan!) {
        existingCoverage.add(coverage);
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverage != null) {
      for (var coverage in widget.qtn!.policyOwner!.existingMedicalPlan!) {
        existingCoverage.add(coverage);
      }
    }

    if (widget.qtn!.lifeInsured!.existingCoverage != null) {
      for (var coverage in widget.qtn!.lifeInsured!.existingRetirement!) {
        existingCoverage.add(coverage);
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverage != null) {
      for (var coverage in widget.qtn!.policyOwner!.existingRetirement!) {
        existingCoverage.add(coverage);
      }
    }

    if (widget.qtn!.lifeInsured!.existingCoverage != null) {
      for (var coverage in widget.qtn!.lifeInsured!.existingChildEdu!) {
        existingCoverage.add(coverage);
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverage != null) {
      for (var coverage in widget.qtn!.policyOwner!.existingChildEdu!) {
        existingCoverage.add(coverage);
      }
    }

    if (widget.qtn!.lifeInsured!.existingCoverageDisclosure != null) {
      for (var coverage
          in widget.qtn!.lifeInsured!.existingCoverageDisclosure!) {
        existingCoverage.add(coverage);
      }
    }
    if (widget.qtn!.policyOwner!.existingCoverageDisclosure != null) {
      for (var coverage
          in widget.qtn!.policyOwner!.existingCoverageDisclosure!) {
        existingCoverage.add(coverage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getLocale("Create New Quote"), style: bFontWN()),
                      Row(children: [
                        Text(getLocale("View current coverage"),
                            style: bFontW5().copyWith(fontSize: 30))
                      ])
                    ]))
          ]));
    }

    Widget planDetail(String col1, String? col2) {
      return Visibility(
          visible: col2 != null,
          child: Row(children: [
            Expanded(flex: 3, child: Text(col1, style: bFontWN())),
            Expanded(flex: 2, child: Text(col2 ?? "", style: bFontW5()))
          ]));
    }

    Widget planCard(Coverage coverage) {
      if (coverage.totalPremiumAmt == 0) {
        return Container();
      }
      String? startDate;
      String? maturityDate;

      if (coverage.startDate != null) {
        DateTime? start;
        if (coverage.startDate!.contains("-")) {
          start = DateFormat("dd-MM-yyyy").parse(coverage.startDate!);
        } else {
          start = DateTime.tryParse(coverage.startDate!);
        }
        startDate = DateFormat("d MMMM y").format(start!);
      }

      if (coverage.maturityDate != null) {
        DateTime? start;
        if (coverage.maturityDate!.contains("-")) {
          start = DateFormat("dd-MM-yyyy").parse(coverage.maturityDate!);
        } else {
          start = DateTime.tryParse(coverage.maturityDate!);
        }
        maturityDate = DateFormat("d MMMM y").format(start!);
      }

      return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey[400]!)),
          margin: const EdgeInsets.only(right: 15, bottom: 20),
          padding: const EdgeInsets.all(22),
          width: MediaQuery.of(context).size.width * 0.32,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(coverage.company ?? "-", style: bFontWN()),
            Text(coverage.policyName ?? "-", style: tFontW5()),
            const SizedBox(height: 16),
            planDetail(getLocale("Policy Status"), coverage.policyStatus),
            planDetail(getLocale("Policy Number"), coverage.policyNumber),
            planDetail(getLocale("Type of Plan"), coverage.policyType),
            planDetail(
                getLocale("Plan Lump Sum Maturity"),
                coverage.planlumpsummaturity != null
                    ? toRM(coverage.planlumpsummaturity, rm: true)
                    : null),
            planDetail(
                getLocale("Plan Income Maturity"),
                coverage.planincomematurity != null
                    ? toRM(coverage.planincomematurity, rm: true)
                    : null),
            planDetail(
                getLocale("Sum Insured"),
                coverage.sumInsured != null
                    ? toRM(coverage.sumInsured, rm: true)
                    : null),
            planDetail(getLocale("Total Premium Amount"),
                toRM(coverage.totalPremiumAmt, rm: true)),
            planDetail(getLocale("Start Date"), startDate ?? "-"),
            planDetail(getLocale("Maturity Date"), maturityDate ?? "-"),
            planDetail(getLocale("Additional Benefit"),
                coverage.additionalbenefit ?? "-")
          ]));
    }

    Widget existingPlan(String title, List<Coverage> listOfCoverage) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(title, style: bFontWB())),
        listOfCoverage.isNotEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                    itemCount: listOfCoverage.length,
                    itemBuilder: (context, index) {
                      final item = listOfCoverage[index];
                      return planCard(item);
                    },
                    scrollDirection: Axis.horizontal))
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(getLocale("No coverage found"), style: bFontWN()))
      ]);
    }

    Widget submitForm() {
      return Container(
          decoration: textFieldBoxDecoration().copyWith(
              color: honeyColor, border: Border.all(color: honeyColor)),
          height: 70,
          margin:
              const EdgeInsets.only(left: 45, right: 45, top: 10, bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextButton(
              // padding: EdgeInsets.all(0),
              onPressed: () {
                if (isLoading != true) {
                  //Disable button if button has already been pressed
                  setState(() {
                    isLoading = true;
                  });
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.of(context).push(
                        createRoute(ChooseProducts(widget.qtnId, widget.qtn!)));
                  });
                }
              },
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.scale(
                        scale: 0.8,
                        child: IconButton(
                            onPressed: null,
                            icon: Icon(Icons.adaptive.arrow_back))),
                    isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black))
                        : Row(children: [
                            Text(getLocale("Next"), style: t1FontW5()),
                            Transform.scale(
                                scale: 0.8,
                                child: Icon(Icons.adaptive.arrow_forward,
                                    color: Colors.black))
                          ])
                  ])));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          progressBar(context, 6, 1 / 2),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () async {
                          _qtnBloc.add(FindQuotation(widget.qtn!.uid));
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.adaptive.arrow_back)),
                    IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Home()));
                        },
                        icon: const Icon(Icons.close, size: 40))
                  ])),
          Expanded(
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 45),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  header(),
                                  existingPlan(getLocale("Purchased from you"),
                                      purchasedCoverage),
                                  existingPlan(
                                      getLocale(
                                          "Existing coverage from disclosure of previous purchase"),
                                      existingCoverage)
                                ])),
                      ]))),
          submitForm()
        ]));
  }
}
