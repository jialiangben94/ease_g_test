import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/new_quotation_generated/new_quotation_generated.dart';
import 'package:ease/src/screen/new_business/widget/confirm_delete_dialog.dart';
import 'package:ease/src/screen/new_business/widget/quotation_categorization.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class GeneratedQuotation extends StatefulWidget {
  final int? dayValid;
  const GeneratedQuotation({Key? key, this.dayValid}) : super(key: key);
  @override
  GeneratedQuotationState createState() => GeneratedQuotationState();
}

class GeneratedQuotationState extends State<GeneratedQuotation> {
  @override
  void initState() {
    super.initState();
    //Caused flicker
    BlocProvider.of<ProductPlanBloc>(context)
        .add(const FilterProductPlanList());
    BlocProvider.of<ChooseProductBloc>(context).add(SetInitial());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> choiceAction(String choice, Quotation qtn,
      {QuickQuotation? quickQtn}) async {
    if (choice == QtnAction.editQuote) {
      if (quickQtn!.status == "2" || quickQtn.premAmt == "") {
        //Show error bar or something
      } else {
        //GET PLAN DATA
        ProductPlanState data = BlocProvider.of<ProductPlanBloc>(context).state;

        if (data is ProductPlanLoaded) {
          Future.delayed(const Duration(milliseconds: 100), () {
            //EDIT QUOTE
            BlocProvider.of<ChooseProductBloc>(context)
                .add(EditQuotation(quotation: qtn, quickQuotation: quickQtn));
          });

          await Navigator.of(context).pushReplacement(createRoute(
              ChooseProducts(qtn.id, qtn,
                  quickQtnId: quickQtn.quickQuoteId, status: Status.edit)));
        }
      }
    } else if (choice == QtnAction.setQuoteCategory) {
      if (quickQtn!.status == "2" || quickQtn.premAmt == "") {
        //Show error bar or something
      } else {
        setCategory(context, qtn);
      }
    } else if (choice == QtnAction.duplicateQuote) {
      //If quickQtn == 2, meaning it was expired & updated. Just can view now.
      //If premium amount is null, the qtn is incomplete. User just should continue edit current qtn

      if (quickQtn!.status == "2" || quickQtn.premAmt == "") {
        //Show error bar or something
      } else {
        if (qtn.listOfQuotation!.length > 4) {
          showAlertDialog(context, "Oops!",
              'You have created 5 quotations for this customer. If you wish to create another quotation, please delete one of the version or click "Create New Quote" in the home page.');
        } else {
          ProductPlanState data =
              BlocProvider.of<ProductPlanBloc>(context).state;

          if (data is ProductPlanLoaded) {
            Future.delayed(const Duration(milliseconds: 100), () {
              //We leverage on edit quotation
              //But instead of using same quick quotation number
              //We use a new one.
              BlocProvider.of<ChooseProductBloc>(context).add(
                  DuplicateQuotation(
                      quotation: qtn, quickQuotationData: quickQtn));
            });

            await Navigator.of(context).push(createRoute(ChooseProducts(
                qtn.id, qtn,
                quickQtnId: '', status: Status.duplicate)));
          }
        }
      }
    } else if (choice == QtnAction.deleteQuote) {
      await confirmDeleteDialog(context, "quotation").then((value) {
        if (value == ConfirmAction.yes) {
          if (qtn.listOfQuotation!.length < 2) {
            BlocProvider.of<QuotationBloc>(context).add(DeleteQuotation(qtn));
          } else {
            BlocProvider.of<QuotationBloc>(context)
                .add(DeleteQuickQtn(qtn, quickQtn));
          }
        }
      });
      if (!mounted) {}
      BlocProvider.of<QuotationBloc>(context).add(LoadQuotation());
    }
  }

  List<Color> getColor(String? category) {
    if (category == "Follow Up Required") {
      return [orangeRedColor, lightOrangeRedColor];
    } else if (category == "High Potential") {
      return [cyanColor, lightCyanColor];
    } else if (category == "Low Potential") {
      return [darkBrownColor, lightBrownColor];
    } else {
      return [greyTextColor, greyBorderColor];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildQtnTable(List<Quotation> data) {
      Column singleQuotationView(
          {required Person poData,
          required Person liData,
          required Quotation quotation,
          required List<Color> color}) {
        bool shouldDisabled = quotationValid(quotation, 0);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                flex: 5,
                child: Row(children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: color[1],
                      child: Text(poData.name![0].toString(),
                          style: t2FontWB().apply(color: color[0]))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(poData.name!, style: t2FontWB())))
                ])),
            Expanded(
                flex: 5,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(liData.name!, style: t2FontWN()))),
            Expanded(
                flex: 4,
                child: Text(
                    quotation.listOfQuotation!.isNotEmpty
                        ? dateTimetoWithoutTime(
                            quotation.listOfQuotation![0]!.dateTime!)
                        : "",
                    textAlign: TextAlign.center,
                    style: t2FontWN())),
            Expanded(
                flex: 4,
                child: Text(
                    quotation.listOfQuotation!.isNotEmpty &&
                            quotation.listOfQuotation![0]!.productPlanName !=
                                null
                        ? quotation.listOfQuotation![0]!.productPlanName!
                        : "",
                    textAlign: TextAlign.center,
                    style: t2FontWN())),
            Expanded(
                flex: 4,
                child: Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          quotation.listOfQuotation == null ||
                                  quotation.listOfQuotation!.isEmpty ||
                                  quotation.listOfQuotation![0]!.totalPremium ==
                                      null
                              ? "-"
                              : toRM(
                                  quotation.listOfQuotation![0]!.totalPremium,
                                  rm: true),
                          style: t2FontWN()),
                      Text(
                          quotation.listOfQuotation == null ||
                                  quotation.listOfQuotation!.isEmpty ||
                                  quotation.listOfQuotation![0]!.totalPremium ==
                                      null
                              ? ""
                              : isNumeric(quotation
                                      .listOfQuotation![0]!.paymentMode)
                                  ? getLocale(convertPaymentMode(quotation
                                      .listOfQuotation![0]!.paymentMode))
                                  : quotation.listOfQuotation![0]!.paymentMode!
                                      .toLowerCase(),
                          style: sFontWN().copyWith(height: 0.9))
                    ]))),
            Expanded(
                flex: 4,
                child: quotation.listOfQuotation!.isNotEmpty
                    ? FutureBuilder<QuotationStatus>(
                        future: isQuotationActive(
                          context,
                          quotation.listOfQuotation![0]!.productPlanCode,
                          quotation.listOfQuotation![0]!.vpmsVersion,
                          quotation.lifeInsured!.dob!,
                          quotation.lifeInsured!.age!,
                          quotation.listOfQuotation![0]!.status,
                          quotation.listOfQuotation![0]!.totalPremium ?? '-',
                        ),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuotationStatus> snapshot) {
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: snapshot.hasData
                                  ? GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                          snapshot.data ==
                                                  QuotationStatus.active
                                              ? getLocale("Active")
                                              : snapshot.data ==
                                                      QuotationStatus.invalid
                                                  ? getLocale("Invalid")
                                                  : snapshot.data ==
                                                          QuotationStatus
                                                              .incomplete
                                                      ? getLocale("Incomplete")
                                                      : getLocale("Expired"),
                                          textAlign: TextAlign.center,
                                          style: t2FontW5()),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text(getLocale("Checking"),
                                              textAlign: TextAlign.center,
                                              style: bFontWN()),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color?>(
                                                          Colors.grey[500])))
                                        ]));
                        })
                    : Text(getLocale("Incomplete"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500))),
            Expanded(
                flex: 3,
                child: GestureDetector(
                    onTap: () {
                      if (quotation.listOfQuotation != null &&
                          quotation.listOfQuotation!.isNotEmpty &&
                          quotation.listOfQuotation![0]!.totalPremium != null) {
                        analyticsSendEvent("view_quotation", null);
                        BlocProvider.of<ChooseProductBloc>(context).add(
                            ViewGeneratedQuotation(
                                quotation: quotation,
                                quickQuotation: quotation.listOfQuotation![0]));

                        Navigator.of(context).pushReplacement(createRoute(
                            NewQuotationGenerated(
                                qtnId: quotation.id,
                                qtn: quotation,
                                quickQuotation: quotation.listOfQuotation![0],
                                status: Status.view)));
                      } else if (quotation.listOfQuotation!.isNotEmpty &&
                          quotation.listOfQuotation![0]!.totalPremium == null) {
                        analyticsSendEvent("edit_quotation", null);

                        QuickQuotation? quickQtn =
                            quotation.listOfQuotation![0];

                        //GET PLAN DATA

                        ProductPlanState data =
                            BlocProvider.of<ProductPlanBloc>(context).state;

                        if (data is ProductPlanLoaded) {
                          Navigator.of(context).pushReplacement(createRoute(
                              ChooseProducts(quotation.id, quotation,
                                  quickQtnId: quickQtn!.quickQuoteId,
                                  status: Status.edit)));
                          Future.delayed(const Duration(milliseconds: 100), () {
                            //EDIT QUOTE
                            BlocProvider.of<ChooseProductBloc>(context).add(
                                EditQuotation(
                                    quotation: quotation,
                                    quickQuotation: quickQtn));
                          });
                        }
                      } else if (quotation.listOfQuotation!.isEmpty) {
                        analyticsSendEvent("edit_quotation", null);

                        QuotationBlocState data =
                            BlocProvider.of<QuotationBloc>(context).state;
                        if (data is QuotationLoadSuccess) {
                          Navigator.of(context).push(createRoute(ChooseProducts(
                              quotation.id, data.quotations[0],
                              status: Status.edit)));
                        }
                      }
                    },
                    child: Text(
                        quotation.listOfQuotation == null ||
                                quotation.listOfQuotation!.isEmpty ||
                                quotation.listOfQuotation![0]!.totalPremium ==
                                    null
                            ? "${getLocale("Continue")} >"
                            : getLocale("View"),
                        textAlign: TextAlign.center,
                        style: t2FontWN().copyWith(color: cyanColor)))),
            Expanded(
                flex: 1,
                child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (choice) {
                      if (!shouldDisabled || choice == "Delete Quote") {
                        if (quotation.listOfQuotation == null ||
                            quotation.listOfQuotation!.isEmpty) {
                          choiceAction(choice, quotation);
                        } else {
                          choiceAction(choice, quotation,
                              quickQtn: quotation.listOfQuotation == null
                                  ? null
                                  : quotation.listOfQuotation![0]);
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return QtnAction.choices.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(getLocale(choice),
                                style: TextStyle(
                                    color: ((choice == "Duplicate Quote" ||
                                                choice == "Edit Quotation" ||
                                                choice == "Share" ||
                                                choice ==
                                                    "Set Potential Category") &&
                                            shouldDisabled
                                        ? Colors.grey
                                        : Colors.black))));
                      }).toList();
                    }))
          ]),
          Visibility(
              visible: quotation.reminderDate != null,
              child: Text(
                  "* ${getLocale("Reminder set in")} ${countdownReminder(quotation.reminderDate)} ${getLocale("later")}",
                  style: sFontWN().copyWith(color: honeyColor)))
        ]);
      }

      ListView multipleQuotationView(
          {Person? poData,
          Person? liData,
          required Quotation quotation,
          List<Color>? color,
          int? quotationLength}) {
        // Need to use try here, in case quotation is incomplete, version is null
        try {
          quotation.listOfQuotation!.sort((a, b) {
            if (a!.version != null && b!.version != null) {
              return b.version!.compareTo(a.version!);
            }
            return 0;
          }); // Just to sort
        } catch (e) {
          rethrow;
        }

        return ListView.builder(
            itemCount: quotation.listOfQuotation!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, x) {
              bool shouldDisabled = quotationValid(quotation, x);

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          flex: 5,
                          child: Visibility(
                              visible: x == 0,
                              child: Row(children: [
                                CircleAvatar(
                                    radius: 16,
                                    backgroundColor: color![1],
                                    child: Text(poData!.name![0].toString(),
                                        style:
                                            t2FontWB().apply(color: color[0]))),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Text(poData.name!,
                                            style: t2FontWB())))
                              ]))),
                      Expanded(
                          flex: 5,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(liData!.name!, style: t2FontWN()))),
                      Expanded(
                          flex: 4,
                          child: Text(
                              dateTimetoWithoutTime(
                                  quotation.listOfQuotation![x]!.dateTime!),
                              textAlign: TextAlign.center,
                              style: t2FontWN())),
                      Expanded(
                          flex: 4,
                          child: Text(
                              quotation.listOfQuotation![x]!.productPlanName ??
                                  "-",
                              textAlign: TextAlign.center,
                              style: t2FontWN())),
                      // Expanded(
                      //     flex: 4,
                      //     child: Container(
                      //         child: Center(
                      //             child: Column(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //           Text(
                      //               quotation.listOfQuotation[x].totalPremium !=
                      //                       null
                      //                   ? "RM ${toCurrencyString(quotation.listOfQuotation[x].totalPremium)}"
                      //                   : "-",
                      //               style: TextStyle(
                      //                   color: Colors.black, fontSize: 18)),
                      //           Text(
                      //               convertPaymentMode(quotation
                      //                       .listOfQuotation[x].paymentMode)
                      //                   .toLowerCase(),
                      //               style:
                      //                   TextStyle(height: 0.9, color: Colors.black))
                      //         ])))),
                      Expanded(
                          flex: 4,
                          child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    quotation.listOfQuotation == null ||
                                            quotation.listOfQuotation![x]!
                                                    .totalPremium ==
                                                null
                                        ? "-"
                                        : toRM(
                                            quotation.listOfQuotation![x]!
                                                .totalPremium,
                                            rm: true),
                                    style: t2FontWN()),
                                Text(
                                    quotation.listOfQuotation == null ||
                                            quotation.listOfQuotation![x]!
                                                    .totalPremium ==
                                                null
                                        ? ""
                                        : isNumeric(quotation
                                                .listOfQuotation![0]!
                                                .paymentMode)
                                            ? convertPaymentMode(quotation
                                                    .listOfQuotation![x]!
                                                    .paymentMode)
                                                .toLowerCase()
                                            : quotation.listOfQuotation![0]!
                                                .paymentMode!
                                                .toLowerCase(),
                                    style: sFontWN().copyWith(height: 0.9))
                              ]))),
                      Expanded(
                          flex: 4, //3
                          child: quotation.listOfQuotation!.isNotEmpty
                              ? FutureBuilder<QuotationStatus>(
                                  future: isQuotationActive(
                                    context,
                                    quotation
                                        .listOfQuotation![x]!.productPlanCode,
                                    quotation.listOfQuotation![x]!.vpmsVersion,
                                    quotation.lifeInsured!.dob!,
                                    quotation.lifeInsured!.age!,
                                    quotation.listOfQuotation![x]!.status,
                                    quotation.listOfQuotation![x]!
                                            .totalPremium ??
                                        "-",
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuotationStatus> snapshot) {
                                    return AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: snapshot.hasData
                                            ? Text(
                                                snapshot.data ==
                                                        QuotationStatus.active
                                                    ? getLocale("Active")
                                                    : snapshot.data ==
                                                            QuotationStatus
                                                                .invalid
                                                        ? getLocale("Invalid")
                                                        : snapshot.data ==
                                                                QuotationStatus
                                                                    .incomplete
                                                            ? getLocale(
                                                                "Incomplete")
                                                            : getLocale(
                                                                "Expired"),
                                                textAlign: TextAlign.center,
                                                style: t2FontW5())
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Text(getLocale("Checking"),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: bFontWN()),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 10),
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color?>(
                                                                    Colors.grey[
                                                                        500])))
                                                  ]));
                                  })
                              : Text(getLocale("Incomplete"),
                                  textAlign: TextAlign.center,
                                  style: t2FontW5())),
                      Expanded(
                          flex: 3,
                          child: GestureDetector(
                              onTap: () {
                                if (quotation.listOfQuotation != null &&
                                    quotation.listOfQuotation![x]!
                                            .totalPremium !=
                                        null) {
                                  BlocProvider.of<ChooseProductBloc>(context)
                                      .add(ViewGeneratedQuotation(
                                          quotation: quotation,
                                          quickQuotation:
                                              quotation.listOfQuotation![x]));

                                  Navigator.of(context).pushReplacement(
                                      createRoute(NewQuotationGenerated(
                                          qtnId: quotation.id,
                                          qtn: quotation,
                                          quickQuotation:
                                              quotation.listOfQuotation![x],
                                          status: Status.view)));
                                } else if (quotation
                                        .listOfQuotation![x]!.totalPremium ==
                                    null) {
                                  QuickQuotation? quickQtn =
                                      quotation.listOfQuotation![x];
                                  //GET PLAN DATA

                                  ProductPlanState data =
                                      BlocProvider.of<ProductPlanBloc>(context)
                                          .state;

                                  if (data is ProductPlanLoaded) {
                                    Navigator.of(context).pushReplacement(
                                        createRoute(ChooseProducts(
                                            quotation.id, quotation,
                                            quickQtnId: quickQtn!.quickQuoteId,
                                            status: Status.edit)));

                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      //EDIT QUOTE
                                      BlocProvider.of<ChooseProductBloc>(
                                              context)
                                          .add(EditQuotation(
                                              quotation: quotation,
                                              quickQuotation: quickQtn));
                                    });
                                  }
                                }
                                // BlocProvider.of<ChooseProductBloc>(context)
                                //   ..add(ViewGeneratedQuotation(
                                //       quotation: quotation,
                                //       quickQuotation:
                                //           quotation.listOfQuotation[x]));

                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (BuildContext context) =>
                                //             NewQuotationGenerated(
                                //                 qtnId: quotation.id,
                                //                 qtn: quotation,
                                //                 status: Status.edit),
                                //         ));
                              },
                              child: Text(
                                  quotation.listOfQuotation == null ||
                                          quotation.listOfQuotation![x]!
                                                  .totalPremium ==
                                              null
                                      ? "${getLocale("Continue")} >"
                                      : getLocale("View"),
                                  textAlign: TextAlign.center,
                                  style:
                                      t2FontWN().copyWith(color: cyanColor)))),
                      Expanded(
                          flex: 1,
                          child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (choice) {
                                if (!shouldDisabled ||
                                    choice == "Delete Quote") {
                                  choiceAction(choice, quotation,
                                      quickQtn: quotation.listOfQuotation![x]);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return QtnAction.choices.map((String choice) {
                                  return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(getLocale(choice),
                                          style: TextStyle(
                                              color: ((choice ==
                                                              "Duplicate Quote" ||
                                                          choice ==
                                                              "Edit Quotation" ||
                                                          choice == "Share" ||
                                                          choice ==
                                                              "Set Potential Category") &&
                                                      shouldDisabled
                                                  ? Colors.grey
                                                  : Colors.black))));
                                }).toList();
                              }))
                    ]),
                    Visibility(
                        visible: x >= 0 && x < quotationLength! - 1,
                        child: const Divider(thickness: 2)),
                    const SizedBox(height: 5),
                    Visibility(
                        visible: (x == quotationLength! - 1 &&
                            quotation.reminderDate != null),
                        child: Text(
                            "* ${getLocale("Reminder set in")} ${countdownReminder(quotation.reminderDate)} ${getLocale("later")}",
                            style: sFontWN().copyWith(color: honeyColor)))
                  ]);
            });
      }

      return Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 0, bottom: 10),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Text(getLocale("Policy Owner", entity: true),
                              style: sFontWN())),
                      Expanded(
                          flex: 5,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                  getLocale("Life Insured", entity: true),
                                  style: const TextStyle(fontSize: 14)))),
                      Expanded(
                          flex: 4,
                          child: Text(getLocale("Requested Date"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14))),
                      Expanded(
                          flex: 4,
                          child: Text(getLocale("Selected Product"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14))),
                      Expanded(
                          flex: 4,
                          child: Text(getLocale("Premium Amount"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14))),
                      Expanded(
                          flex: 3,
                          child: Text(getLocale("Status"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14))),
                      Expanded(
                          flex: 3,
                          child: Text(getLocale("Action"),
                              textAlign: TextAlign.center, style: sFontWN())),
                      Expanded(flex: 1, child: Text("", style: sFontWN()))
                    ])),
            Expanded(
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, i) {
                      Person poData;
                      var liData = data[i].lifeInsured;

                      if (data[i].buyingFor == BuyingFor.self.toStr ||
                          (data[i].buyingFor == BuyingFor.children.toStr &&
                              data[i].lifeInsured!.age! > 16)) {
                        // poData = data[i].lifeInsured;
                        poData = data[i].policyOwner!;
                      } else {
                        poData = data[i].policyOwner!;
                      }

                      var quotationLength = data[i].listOfQuotation!.length;

                      var color = getColor(data[i].category);

                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3)),
                                    border: Border.all(
                                        color: greyBorderColor, width: 1.5)),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 10.0),
                                    child: data[i].listOfQuotation != null &&
                                            data[i].listOfQuotation!.length > 1
                                        ? multipleQuotationView(
                                            poData: poData == liData
                                                ? liData
                                                : poData,
                                            liData: liData,
                                            quotation: data[i],
                                            color: color,
                                            quotationLength: quotationLength)
                                        :
                                        //THIS IS FOR QTN WITH 1 OR 0 QUICK QUOTATION
                                        singleQuotationView(
                                            poData: poData == liData
                                                ? liData!
                                                : poData,
                                            liData: liData!,
                                            quotation: data[i],
                                            color: color))),
                            const SizedBox(height: 5)
                          ]);
                    }))
          ]));
    }

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
                Text(getLocale("No quotation found"),
                    style: sFontWN().copyWith(color: Colors.grey)),
                const SizedBox(height: 40)
              ]));
    }

    List<Quotation> checkDayValid(List<Quotation> data) {
      for (var quotation in data) {
        List<QuickQuotation?> list = quotation.listOfQuotation!;
        for (var quickQuotation in list) {
          if (getAgeInDays(
                  DateFormat("dd MMM yyyy").parse(quickQuotation!.dateTime!)) >
              widget.dayValid!) {
            // Send Analytics if no action taken
            analyticsSendEvent("nta_quotation", {
              "qtn_id": quotation.id,
              "life_insured_name": quotation.lifeInsured!.name
            });

            BlocProvider.of<QuotationBloc>(context)
                .add(DeleteQuickQtn(quotation, quickQuotation));
          }
        }
      }
      return data;
    }

    Widget buildLoaded(data) {
      var ndata = data;
      if (widget.dayValid != null) {
        ndata = checkDayValid(data);
      }
      return data.length == 0
          ? buildInitialInput(context)
          : buildQtnTable(ndata);
    }

    return Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: BlocBuilder<QuotationBloc, QuotationBlocState>(
            builder: (context, state) {
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: state is QuotationLoadInProgress
                  ? buildLoading()
                  : state is QuotationLoadSuccess
                      ? buildLoaded(state.quotations)
                      : state is QuotationLoadError
                          ? buildError(context, state.message)
                          : buildInitialInput(context));
        }));
  }
}

class QtnAction {
  // static const String share = 'Share';
  static String editQuote = "Edit Quotation";
  static String setQuoteCategory = "Set Potential Category";
  //getLocale("Set Potential Category");
  static String duplicateQuote = "Duplicate Quote";
  static String deleteQuote = "Delete Quote";

  static List<String> choices = <String>[
    // share,
    setQuoteCategory,
    editQuote,
    duplicateQuote,
    deleteQuote
  ];
}
