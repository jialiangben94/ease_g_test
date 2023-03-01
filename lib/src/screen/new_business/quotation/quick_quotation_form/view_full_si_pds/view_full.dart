import 'dart:async';
import 'dart:io';

import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/view_full_si_pds/view_doc.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

enum ChooseDocument { si, pds, ffs, il }

class ViewFullDoc extends StatefulWidget {
  final Quotation? quotation;
  final QuickQuotation? quickQuotation;
  const ViewFullDoc(this.quotation, this.quickQuotation, {Key? key})
      : super(key: key);

  @override
  ViewFullDocState createState() => ViewFullDocState();
}

class ViewFullDocState extends State<ViewFullDoc> {
  Quotation? quotation;
  QuickQuotation? quickQuotation;
  bool downloading = false;
  ChooseDocument? selectedDoc;

  @override
  void initState() {
    selectedDoc = ChooseDocument.si;
    quotation = widget.quotation;
    quickQuotation = widget.quickQuotation;
    super.initState();
  }

  Future<File> getDoc() async {
    String? fileName;
    final docPath = await getTemporaryDirectory();
    if (selectedDoc == ChooseDocument.si) {
      fileName =
          "${quickQuotation!.productPlanName}SI-${quickQuotation!.quotationHistoryID}.pdf";
    } else if (selectedDoc == ChooseDocument.pds) {
      fileName =
          "${quickQuotation!.productPlanName}PDS-${quickQuotation!.quotationHistoryID}.pdf";
    } else if (selectedDoc == ChooseDocument.ffs) {
      fileName =
          "${quickQuotation!.productPlanName}FFS-${quickQuotation!.quotationHistoryID}.pdf";
    } else if (selectedDoc == ChooseDocument.il) {
      fileName =
          "${quickQuotation!.productPlanName}IL-${quickQuotation!.quotationHistoryID}.pdf";
    }
    final docFile = File('${docPath.path}/$fileName');
    return docFile;
  }

  Future<void> sendEmail(List<String> exFileName) async {
    // String platformResponse;

    var clientName = quotation?.policyOwner?.name ?? '';
    var prodName = quickQuotation?.productPlanName;
    var agentName = '';
    var userprofile = BlocProvider.of<UserProfileBloc>(context);
    var agentState = userprofile.state;
    if (agentState is UserProfileLoaded) {
      agentName = agentState.agent?.fullName ?? '';
    } else {
      agentName = 'Your Agent';
    }

    final MailOptions mailOptions = MailOptions(
      body: '''
      <b>Dear Customer,</b>
      <br>

      
      <p>Thank you for you confidence in our plan and services. I am pleased to be of service to you.</p>
      
      <p>Please find here a detailed copy of my proposal for your $prodName attached to this email.</p>
      
      <p>Should you have any questions, concerns or require further discussion regarding this quote,
      please reply back to me via this email. I will gladly assist you.</p>
      
      <p>Sincerely</p>
      <p>$agentName</p>
      ''',
      subject: 'Sales Illustration for $prodName - $clientName',
      recipients: [],
      isHTML: true,
      attachments: exFileName,
    );

    try {
      await FlutterMailer.send(mailOptions);
    } catch (e) {
      if (e is PlatformException) {
        if (e.message == 'default mail app not available') {
          showAlertDialog(context, 'Error. No default mailing app found.',
              'Please set up mail app in this device first.\n\n Go Settings > Mail > Accounts > Add Accounts');
        } else {
          showAlertDialog(context, 'Error', e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: quickQuotation!.productPlanCode! != "PCTA01" &&
                quickQuotation!.productPlanCode! != "PCWA01" &&
                quickQuotation!.productPlanCode! != "PCEE01" &&
                quickQuotation!.productPlanCode! != "PCEL01"
            ? 4
            : 2,
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(65),
                child: Stack(children: [
                  Container(
                      height: 65,
                      color: honeyColor,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.adaptive.arrow_back,
                                    color: Colors.black, size: 30),
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12)),
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16.0, top: 14),
                                  child: TextButton(
                                      onPressed: () async {
                                        final docPath =
                                            await getTemporaryDirectory();

                                        List<String> exfileName = [
                                          '${docPath.path}/${quickQuotation!.productPlanName}SI-${quickQuotation?.quotationHistoryID}.pdf',
                                          '${docPath.path}/${quickQuotation!.productPlanName}PDS-${quickQuotation?.quotationHistoryID}.pdf',
                                          '${docPath.path}/${quickQuotation!.productPlanName}FFS-${quickQuotation?.quotationHistoryID}.pdf',
                                          '${docPath.path}/${quickQuotation!.productPlanName}IL-${quickQuotation?.quotationHistoryID}.pdf'
                                        ];

                                        if (quickQuotation!.productPlanCode! == "PCTA01" ||
                                            quickQuotation!.productPlanCode! ==
                                                "PCWA01" ||
                                            quickQuotation!.productPlanCode! ==
                                                "PCEE01" ||
                                            quickQuotation!.productPlanCode! ==
                                                "PCEL01") {
                                          exfileName.removeAt(2);
                                          exfileName.removeLast();
                                        }

                                        var x = 1;

                                        for (var element in exfileName) {
                                          var file = File(element);
                                          if (file.existsSync()) {
                                            x = x * 1;
                                          } else {
                                            x = x * 0;
                                          }
                                        }

                                        if (x == 1) {
                                          await sendEmail(exfileName);
                                        } else {
                                          if (!mounted) {}
                                          showAlertDialog(
                                              context,
                                              getLocale('Sorry'),
                                              getLocale(
                                                  'Please view all of the document first before sharing it'));
                                        }
                                      },
                                      child: Text(getLocale('Share'),
                                          style: sFontWB()
                                              .copyWith(fontSize: 18)))),
                            ])
                          ])),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: TabBar(
                        indicatorColor: Colors.black,
                        indicatorWeight: 4,
                        labelColor: Colors.black,
                        labelStyle: t2FontWN(),
                        isScrollable: true,
                        onTap: (index) {
                          setState(() {
                            if (index == 0) {
                              selectedDoc = ChooseDocument.si;
                            } else if (index == 1) {
                              selectedDoc = ChooseDocument.pds;
                            } else if (index == 2) {
                              selectedDoc = ChooseDocument.ffs;
                            } else if (index == 3) {
                              selectedDoc = ChooseDocument.il;
                            }
                          });
                        },
                        tabs: quickQuotation!.productPlanCode! != "PCTA01" &&
                                quickQuotation!.productPlanCode! != "PCWA01" &&
                                quickQuotation!.productPlanCode! != "PCEE01" &&
                                quickQuotation!.productPlanCode! != "PCEL01"
                            ? const [
                                Tab(text: "SI/MI"),
                                Tab(text: "PDS"),
                                Tab(text: "FFS"),
                                Tab(text: "IL GUIDE")
                              ]
                            : const [Tab(text: "SI/MI"), Tab(text: "PDS")],
                      )),
                ])),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: quickQuotation!.productPlanCode! != "PCTA01" &&
                        quickQuotation!.productPlanCode! != "PCWA01" &&
                        quickQuotation!.productPlanCode! != "PCEE01" &&
                        quickQuotation!.productPlanCode! != "PCEL01"
                    ? [
                        ViewDoc(quickQuotation: quickQuotation, doctype: "SI"),
                        ViewDoc(quickQuotation: quickQuotation, doctype: "PDS"),
                        ViewDoc(quickQuotation: quickQuotation, doctype: "FFS"),
                        ViewDoc(quickQuotation: quickQuotation, doctype: "IL")
                      ]
                    : [
                        ViewDoc(quickQuotation: quickQuotation, doctype: "SI"),
                        ViewDoc(quickQuotation: quickQuotation, doctype: "PDS")
                      ])));
  }
}
