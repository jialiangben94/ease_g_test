import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/payment/application_completed.dart';
import 'package:ease/src/screen/new_business/application/remote/signature_details.dart';
import 'package:ease/src/screen/new_business/application/remote/widget/dialog.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Remote extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;
  final VoidCallback remoteChange;

  const Remote(
      {Key? key,
      this.obj,
      this.info,
      required this.onChanged,
      required this.remoteChange})
      : super(key: key);
  @override
  RemoteState createState() => RemoteState();
}

class RemoteState extends State<Remote> {
  dynamic data;
  bool isLoading = false;
  bool isSendAll = false;
  bool remotePayment = false;
  List<Widget> signatureList = [];
  List<GlobalKey<FormState>> formKeys = [];
  List<TextEditingController> mobileTextCont = [];
  List<TextEditingController> emailTextCont = [];
  List<TextEditingController> selectedMethod = [];

  @override
  void initState() {
    super.initState();
    data = widget.obj;
    buildWidgetListOfRecipient();
  }

  void onChanged(value) {
    widget.onChanged(value);
    buildWidgetListOfRecipient();
  }

  void remoteChange() {
    widget.remoteChange();
    buildWidgetListOfRecipient();
  }

  void buildWidgetListOfRecipient() async {
    signatureList = [];
    setState(() {
      isLoading = true;
      formKeys = [];
    });
    // get remote status
    if (data["isSentRemote"] != null &&
        data["isSentRemote"] &&
        widget.info["SetID"] != null) {
      var obj = {
        "Method": "GET",
        "Param": {"setID": widget.info["SetID"].toString()}
      };

      await NewBusinessAPI().remote(obj).then((res) async {
        if (res["IsSuccess"]) {
          ApplicationFormData.data["remote"]["remoteStatus"] = res;
          data["listOfRecipient"] =
              await updateRemoteStatus(data["listOfRecipient"], res);
          saveData();
        }
      });
    }

    bool completed = true;
    List<dynamic> verifyStatus =
        data["listOfRecipient"].map((value) => value["VerifyStatus"]).toList();

    if (verifyStatus.any((value) => value == "7")) {
      completed = false;
      ApplicationFormData.data["appStatus"] = AppStatus.incomplete.toString();
      ApplicationFormData.data["assessmentDate"] = null;
      ApplicationFormData.data["tsarRes"] = null;
      ApplicationFormData.data["decision"] = null;
      ApplicationFormData.data["application"] = null;
      ApplicationFormData.data["declaration"] = null;
      ApplicationFormData.data["payment"] = null;

      if (ApplicationFormData.data["guardian"] != null) {
        ApplicationFormData.data["guardiansign"] = null;
      }
      if (ApplicationFormData.data["trusteesign"] != null) {
        ApplicationFormData.data["trusteesign"] = null;
      }
      if (ApplicationFormData.data["agent"] != null) {
        ApplicationFormData.data["agent"] = null;
      }
      if (ApplicationFormData.data["witness"] != null) {
        ApplicationFormData.data["witness"]["signature"] = null;
      }
      ApplicationFormData.data["needReassessment"] = true;
      ApplicationFormData.data["applicationDate"] = getTimestamp();
      saveData();
      setState(() {});
    }
    if (verifyStatus.any((value) => value != "5")) {
      completed = false;
    }
    if (completed) {
      var payor = data["listOfRecipient"].firstWhere(
          (remote) => remote["isPayor"] == true,
          orElse: () => null);
      if (payor != null) {
        if (widget.info["payment"] != null &&
            widget.info["payment"]["payment"] != null &&
            (widget.info["payment"]["payment"] == "creditdebit" ||
                widget.info["payment"]["payment"] == "fpx")) {
          if (payor["PaymentStatus"] != "9") {
            completed = false;
          }
        }
      }
    }

    data["listOfRecipient"].forEach((element) {
      formKeys.add(GlobalKey<FormState>());
      mobileTextCont.add(TextEditingController());
      emailTextCont.add(TextEditingController());
      selectedMethod.add(TextEditingController());
      if (element["isPayor"]) {
        if (widget.info["payment"] != null &&
            widget.info["payment"]["payment"] != null &&
            (widget.info["payment"]["payment"] != "creditdebit" ||
                widget.info["payment"]["payment"] != "fpx") &&
            element["VerifyStatus"] == "5") {
          element["PaymentStatus"] = "3";
        }
      }
      if (element["VerifyStatus"] != null && element["VerifyStatus"] != "") {
        element["isResend"] = true;
      } else {
        element["isResend"] = false;
      }
    });

    if (data["isSentRemote"] != null && data["isSentRemote"] && completed) {
      if (!mounted) {}
      loadingDialog(context, getLocale("We are now submitting your proposal"));
      ApplicationFormData.data["applicationDate"] = getTimestamp();
      saveData();
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
            createRoute(ApplicationCompleted(data: ApplicationFormData.data)));
      });
    }

    remotePayment = data["listOfRecipient"]
            .where((item) => item["isPayor"] == true)
            .length !=
        0;

    // Check if all recipient verified
    int totalRecipient =
        data["listOfRecipient"].where((item) => !item["isPayor"]).length;
    int totalConfirmed = data["listOfRecipient"]
        .where((item) => item["VerifyStatus"] == "5")
        .length;
    if (totalRecipient != 0 && totalRecipient != totalConfirmed) {
      data["enablePayor"] = false;
    } else {
      data["enablePayor"] = true;
    }

    for (int i = 0; i < data["listOfRecipient"].length; i++) {
      signatureList.add(SignatureDetails(
          formKeys[i],
          widget.info["SetID"],
          widget.info,
          data["listOfRecipient"][i],
          onChanged,
          remoteChange,
          validateFormkey,
          mobileTextCont[i],
          emailTextCont[i],
          selectedMethod[i]));
    }
    setState(() {
      isLoading = false;
    });
    validateFormkey();
  }

  void validateFormkey() {
    int textfieldEmpty = 0;
    int disabled = 0;
    setState(() {
      for (var element in formKeys) {
        if (element.currentState != null) {
          if (!element.currentState!.validate()) {
            textfieldEmpty = textfieldEmpty + 1;
          }
        } else {
          disabled++;
        }
      }
      if (disabled == formKeys.length) {
        isSendAll = false;
      } else {
        if (textfieldEmpty == 0) {
          isSendAll = true;
        } else {
          isSendAll = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget sendAllButton() {
      return AnimatedContainer(
          width: MediaQuery.of(context).size.width,
          height: isSendAll ? 60 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Visibility(
              visible: isSendAll,
              child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 0))
                  ]),
                  child: TextButton(
                      style: TextButton.styleFrom(backgroundColor: honeyColor),
                      onPressed: () async {
                        if (widget.info["payment"] == null ||
                            widget.info["payment"]["payment"] == null) {
                          showAlertDialog2(
                              context,
                              getLocale("Remote not yet ready"),
                              getLocale(
                                  "Please choose a payment method in the payment page before continue."));
                        } else {
                          List<dynamic> receipientList = [];
                          for (int i = 0;
                              i < data["listOfRecipient"].length;
                              i++) {
                            var receipient = data["listOfRecipient"][i];
                            bool addToReceipient = false;
                            if (!receipient["isPayor"] ||
                                (receipient["isPayor"] &&
                                    data["enablePayor"])) {
                              if (receipient["VerifyStatus"] == null ||
                                  receipient["VerifyStatus"] == "7" ||
                                  receipient["VerifyStatus"] == "6" ||
                                  receipient["VerifyStatus"] == "4") {
                                addToReceipient = true;
                              } else if (receipient["VerifyStatus"] == "1") {
                                if (receipient["datetime"] != null) {
                                  final sentdate =
                                      DateFormat('dd-MM-yyyy HH:mm a')
                                          .parse(receipient["datetime"]);
                                  final date2 = DateTime.now();
                                  final difference =
                                      date2.difference(sentdate).inMinutes;
                                  if (difference >= 5) {
                                    addToReceipient = true;
                                  }
                                }
                              }
                            }
                            if (addToReceipient) {
                              data["listOfRecipient"][i]["method"] =
                                  selectedMethod[i].text;
                              data["listOfRecipient"][i]["recipientMobile"] =
                                  "+60${mobileTextCont[i].text}";
                              data["listOfRecipient"][i]["recipientEmail"] =
                                  emailTextCont[i].text;

                              var newReceipient = {
                                "ClientType": receipient["clientType"],
                                "Name": receipient["name"],
                                "OtherIDType": receipient["identitytype"],
                                "OtherIDNo": receipient["nric"],
                                "Via": selectedMethod[i].text,
                                "ViaDetail": selectedMethod[i].text == "M"
                                    ? emailTextCont[i].text
                                    : mobileTextCont[i].text,
                                "IsSendSignature": true,
                                "IsSendPayment": receipient["isPayor"] &&
                                    (widget.info["payment"]["payment"] ==
                                            "creditdebit" ||
                                        widget.info["payment"]["payment"] ==
                                            "fpx")
                              };
                              receipientList.add(newReceipient);
                            }
                          }

                          loadingDialog(context,
                              getLocale("Sending remote link to recipient"));

                          dynamic tsarObj = await getSubmitAppObj(
                              setID: widget.info["SetID"],
                              includeAgent: true,
                              paymentMethod: widget.info["payment"]["payment"]);
                          tsarObj["isRemote"] = true;

                          var obj = {
                            "Method": "POST",
                            "Body": {
                              "rmtDetail": {
                                "PropNo": "string",
                                "ProposalNo": "string",
                                "Clients": receipientList,
                                "IsReassessment": ApplicationFormData
                                                .data["reassessmentCounter"] !=
                                            null &&
                                        ApplicationFormData
                                            .data["reassessmentCounter"] is int
                                    ? ApplicationFormData
                                                .data["reassessmentCounter"] >
                                            0
                                        ? true
                                        : false
                                    : false
                              },
                              "quoHis": tsarObj
                            }
                          };
                          await NewBusinessAPI().remote(obj).then((res) {
                            if (res != null && res["IsSuccess"]) {
                              Navigator.of(context).pop();
                              remoteComplete(context,
                                  getLocale("The remote link has been sent"));

                              for (var element in receipientList) {
                                var recipient = data["listOfRecipient"]
                                    .firstWhere(
                                        (remote) => (remote["nric"] ==
                                                element["OtherIDNo"] &&
                                            remote["name"] == element["Name"]),
                                        orElse: () => null);

                                if (recipient != null) {
                                  setState(() {
                                    recipient["SetID"] = tsarObj["SetID"];
                                    recipient["status"] = "sent";
                                    recipient["datetime"] =
                                        DateFormat('dd-MM-yyyy hh:mm a')
                                            .format(DateTime.now());
                                    data["SetID"] = tsarObj["SetID"];
                                    data["status"] = "sent";
                                    widget.onChanged(data);
                                  });
                                }
                              }
                            } else {
                              Navigator.of(context).pop();
                              remoteFailed(
                                  context,
                                  getLocale("Failed to send the remote link"),
                                  res["Message"]);
                            }
                          }).catchError((onError) {
                            Navigator.of(context).pop();
                            remoteFailed(
                                context,
                                getLocale("Failed to send the remote link"),
                                onError);
                          });
                          setState(() {});
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(getLocale("Send All"),
                              style: t2FontW5()))))));
    }

    String? propNo = ApplicationFormData.data["remote"] != null &&
            ApplicationFormData.data["remote"]["remoteStatus"] != null &&
            ApplicationFormData.data["remote"]["remoteStatus"]["resSubmit"] !=
                null &&
            ApplicationFormData.data["remote"]["remoteStatus"]["resSubmit"]
                    ["ProposalNo"] !=
                null
        ? ApplicationFormData.data["remote"]["remoteStatus"]["resSubmit"]
            ["ProposalNo"]
        : null;

    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                top: gFontSize * 2,
                                left: gFontSize * 3,
                                right: gFontSize,
                                bottom: gFontSize * 2.5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      remotePayment
                                          ? getLocale(
                                              "Remote Signature & Payment")
                                          : getLocale("Remote Signature"),
                                      style: t1FontW5()),
                                  Text(
                                      getLocale(
                                          "Select the following people to capture their signature for declaration or make payment remotely if necessary"),
                                      style: bFontWN()),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Text(
                                          getLocale(
                                              "Important Notice: Kindly take note that if the submission proposal is still incomplete by 11.59pm today, all the information will be erased. To prevent this from happening, do ensure that you obtain all signatures and payment as soon as possible."),
                                          style: sFontWN())),
                                  Visibility(
                                      visible: propNo != null,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          child: RichText(
                                              text: TextSpan(
                                                  text:
                                                      '${getLocale("Proposal No")}: ',
                                                  style: bFontWN(),
                                                  children: <TextSpan>[
                                                TextSpan(
                                                    text: propNo ?? "",
                                                    style: bFontW5())
                                              ])))),
                                  AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 700),
                                      child: isLoading
                                          ? SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.7,
                                              child: buildLoading())
                                          : Column(children: signatureList))
                                ]))
                      ]))),
          sendAllButton()
        ]));
  }
}
