import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/remote/verify.dart';
import 'package:ease/src/screen/new_business/application/remote/widget/dialog.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SignatureDetails extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final String? setID;
  final dynamic info;
  final dynamic obj;
  final Function(dynamic obj) onChanged;
  final Function() remoteChange;
  final Function() verify;
  final TextEditingController mobileNumberCont;
  final TextEditingController emailAddressCont;
  final TextEditingController selectedMethod;
  const SignatureDetails(
      this.formkey,
      this.setID,
      this.info,
      this.obj,
      this.onChanged,
      this.remoteChange,
      this.verify,
      this.mobileNumberCont,
      this.emailAddressCont,
      this.selectedMethod,
      {Key? key})
      : super(key: key);
  @override
  SignatureDetailsState createState() => SignatureDetailsState();
}

class SignatureDetailsState extends State<SignatureDetails> {
  TextEditingController disabledCont = TextEditingController();
  dynamic data;

  @override
  void initState() {
    super.initState();
    data = widget.obj;
    widget.selectedMethod.text =
        widget.obj["method"] != null && widget.obj["method"] != ""
            ? widget.obj["method"]
            : "M";
    String mobileno = widget.obj["recipientMobile"];
    if (mobileno.isNotEmpty && mobileno.substring(0, 3) == "+60") {
      widget.mobileNumberCont.text = mobileno.substring(3);
    } else {
      widget.mobileNumberCont.text = mobileno;
    }
    widget.emailAddressCont.text = widget.obj["recipientEmail"];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget selectMethod() {
      return Row(children: [
        GestureDetector(
            onTap: () {
              setState(() {
                widget.selectedMethod.text = "S";
              });
            },
            child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: widget.selectedMethod.text == "S"
                            ? cyanColor
                            : greyBorderColor),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5))),
                child: Center(
                    child: Text(getLocale("Mobile"),
                        style: bFontW5().copyWith(
                            fontWeight: widget.selectedMethod.text == "S"
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: widget.selectedMethod.text == "S"
                                ? cyanColor
                                : Colors.black))))),
        GestureDetector(
            onTap: () {
              setState(() {
                widget.selectedMethod.text = "M";
              });
            },
            child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: widget.selectedMethod.text == "M"
                            ? cyanColor
                            : greyBorderColor),
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                child: Center(
                    child: Text(getLocale("Email"),
                        style: bFontW5().copyWith(
                            fontWeight: widget.selectedMethod.text == "M"
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: widget.selectedMethod.text == "M"
                                ? cyanColor
                                : Colors.black)))))
      ]);
    }

    Widget disabledTextField(String address) {
      disabledCont.text = address;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
              enabled: false,
              controller: disabledCont,
              cursorColor: Colors.grey,
              style: bFontW5(),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: greyBorderTFColor, width: 1.0)),
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: greyBorderTFColor, width: 1.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: greyBorderTFColor, width: 1.0)),
                  filled: true,
                  fillColor: silverGreyColor)));
    }

    Widget mobileNumber() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: widget.mobileNumberCont,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                widget.verify();
              },
              validator: (value) {
                return validPhoneNo(value);
              },
              cursorColor: Colors.grey,
              style: bFontW5(),
              decoration: InputDecoration(
                  prefixText: "+60 ",
                  prefixStyle: bFontW5(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  hintText: '126669898',
                  hintStyle: TextStyle(
                      color: Colors.grey[350], fontWeight: FontWeight.normal),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide:
                          BorderSide(color: Colors.grey, width: 0.5)))));
    }

    Widget emailAddress() {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: widget.emailAddressCont,
              onChanged: (value) {
                widget.verify();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocale(
                      "Please enter your recipient's email address");
                } else if (!RegExp(r""
                        "[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
                  return getLocale("Please enter valid email address");
                }
                return null;
              },
              cursorColor: Colors.grey,
              style: bFontW5(),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  hintText: getLocale('Email address'),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide:
                          BorderSide(color: Colors.grey, width: 0.5)))));
    }

    Widget status() {
      String status;
      if (widget.obj["VerifyStatus"] == "1") {
        status = getLocale("Pending E Signature");
      } else if (widget.obj["VerifyStatus"] == "2") {
        status = getLocale("Pending Verification");
      } else if (widget.obj["VerifyStatus"] == "5") {
        status = getLocale("Confirmed");
      } else if (widget.obj["VerifyStatus"] == "6") {
        status = getLocale("Remote link has expired");
      } else if (widget.obj["VerifyStatus"] == "7") {
        status = getLocale("Rejected by recipient");
      } else if (widget.obj["VerifyStatus"] == "4") {
        status = getLocale("Rejected by you");
      } else {
        status = "-";
      }

      return RichText(
          text: TextSpan(
              text: 'Status : ',
              style: bFontW5(),
              children: <TextSpan>[
            TextSpan(
                text: status,
                style: bFontW5().copyWith(
                    color: widget.obj["VerifyStatus"] == "5"
                        ? cyanColor
                        : widget.obj["VerifyStatus"] == "7" ||
                                widget.obj["VerifyStatus"] == "6" ||
                                widget.obj["VerifyStatus"] == "4"
                            ? scarletRedColor
                            : Colors.black))
          ]));
    }

    Widget statusDetail() {
      String detail = "";
      if (widget.obj["VerifyStatus"] == "1") {
        detail = "Sent on ${widget.obj["datetime"]}";
      } else if (widget.obj["VerifyStatus"] == "2") {
        if (widget.obj["SignatureDatetime"] != null) {
          detail = "Signed on ${widget.obj["SignatureDatetime"]}";
        }
      } else if (widget.obj["VerifyStatus"] == "5") {
        if (widget.obj["SignatureDatetime"] != null) {
          detail = "Verified on ${widget.obj["SignatureDatetime"]}";
        }
      } else if (widget.obj["VerifyStatus"] == "7") {
        detail = "Rejected on ${widget.obj["datetime"]}";
      } else if (widget.obj["VerifyStatus"] == "4") {
        detail = "Rejected on ${widget.obj["datetime"]}";
      } else {
        detail = "";
      }
      return Text(detail, style: bFontWN().copyWith(color: greyTextColor));
    }

    List<Widget> enabledLabelAndTextField(bool isResend) {
      List<Widget> widgets = [];
      widgets = [
        Expanded(
            flex: 2,
            child: Row(children: [
              Text(getLocale("Via"), style: bFontW5()),
              const SizedBox(width: 14),
              selectMethod()
            ])),
        Expanded(
            flex: 3,
            child: widget.obj["isPayor"]
                ? widget.info["remote"] != null &&
                        widget.info["remote"]["enablePayor"] != null
                    ? widget.info["remote"]["enablePayor"]
                        ? widget.selectedMethod.text == "M"
                            ? emailAddress()
                            : mobileNumber()
                        : disabledTextField(widget.selectedMethod.text == "S"
                            ? "+60 ${widget.obj["recipientMobile"]}"
                            : widget.obj["recipientEmail"])
                    : disabledTextField(widget.selectedMethod.text == "S"
                        ? "+60 ${widget.obj["recipientMobile"]}"
                        : widget.obj["recipientEmail"])
                : widget.selectedMethod.text == "M"
                    ? emailAddress()
                    : mobileNumber()),
        Expanded(
            child: SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                        backgroundColor: widget.obj["isPayor"]
                            ? widget.info["remote"] != null &&
                                    widget.info["remote"]["enablePayor"] != null
                                ? widget.info["remote"]["enablePayor"]
                                    ? cyanColor
                                    : lightGreyColor
                                : lightGreyColor
                            : cyanColor),
                    onPressed: () async {
                      if (!widget.obj["isPayor"] ||
                          (widget.obj["isPayor"] &&
                              widget.info["remote"] != null &&
                              widget.info["remote"]["enablePayor"] != null &&
                              widget.info["remote"]["enablePayor"])) {
                        if (widget.formkey.currentState!.validate()) {
                          if (widget.info["payment"] == null ||
                              widget.info["payment"]["payment"] == null) {
                            showAlertDialog2(
                                context,
                                getLocale("Remote not yet ready"),
                                getLocale(
                                    "Please choose a payment method in the payment page before continue."));
                          } else {
                            loadingDialog(context,
                                getLocale("Sending remote link to recipient"));
                            if (widget.selectedMethod.text == "S") {
                              data["method"] = "S";
                            } else {
                              data["method"] = "M";
                            }
                            data["recipientEmail"] =
                                widget.emailAddressCont.text;
                            data["recipientMobile"] =
                                "+60${widget.mobileNumberCont.text}";

                            Map tsarObj = await getSubmitAppObj(
                                setID: widget.setID,
                                includeAgent: true,
                                paymentMethod: widget.info["payment"]
                                    ["payment"]);

                            var newReceipient = {
                              "ClientType": data["clientType"],
                              "ClientID": data["ClientID"],
                              "Name": data["name"],
                              "OtherIDType": int.parse(
                                  identityTypeMap[data["identitytype"]]!),
                              "OtherIDNo": data["nric"],
                              "Via": data["method"],
                              "ViaDetail": data["method"] == "M"
                                  ? data["recipientEmail"]
                                  : data["recipientMobile"],
                              "IsSendSignature": true,
                              "IsSendPayment": data["isPayor"] &&
                                  (widget.info["payment"]["payment"] ==
                                          "creditdebit" ||
                                      widget.info["payment"]["payment"] ==
                                          "fpx")
                            };

                            tsarObj["isRemote"] = true;

                            if (data["isResend"] != null && data["isResend"]) {
                              var obj = {
                                "Method": "PUT",
                                "Body": {
                                  "SetID": widget.setID ?? tsarObj["SetID"],
                                  "ClientID":
                                      remoteClientListID([newReceipient]),
                                  "VerifyStatus": "",
                                  "Remark": "",
                                  "IsResend": true,
                                  "Via": newReceipient["Via"],
                                  "ViaDetail": newReceipient["ViaDetail"]
                                }
                              };
                              await NewBusinessAPI().remote(obj).then((res) {
                                if (res != null && res["IsSuccess"]) {
                                  Navigator.of(context).pop();
                                  remoteComplete(
                                      context,
                                      getLocale(
                                          "The remote link has been sent"));

                                  data["status"] = "sent";
                                  data["datetime"] =
                                      DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(DateTime.now());
                                  data["SetID"] = tsarObj["SetID"];
                                  widget.onChanged(data);
                                } else {
                                  Navigator.of(context).pop();
                                  remoteFailed(
                                      context,
                                      getLocale(
                                          "Failed to send the remote link"),
                                      res["Message"]);
                                }
                              }).catchError((onError) {
                                Navigator.of(context).pop();
                                remoteFailed(
                                    context,
                                    getLocale("Failed to send the remote link"),
                                    onError);
                              });
                            } else {
                              var obj = {
                                "Method": "POST",
                                "Body": {
                                  "rmtDetail": {
                                    "PropNo": "string",
                                    "ProposalNo": "string",
                                    "Clients": [newReceipient],
                                    "IsReassessment": ApplicationFormData.data[
                                                    "reassessmentCounter"] !=
                                                null &&
                                            ApplicationFormData
                                                    .data["reassessmentCounter"]
                                                is int
                                        ? ApplicationFormData.data[
                                                    "reassessmentCounter"] >
                                                0
                                            ? true
                                            : false
                                        : false
                                  },
                                  "quoHis": tsarObj
                                }
                              };

                              // test push
                              await NewBusinessAPI().remote(obj).then((res) {
                                if (res != null && res["IsSuccess"]) {
                                  Navigator.of(context).pop();
                                  remoteComplete(
                                      context,
                                      getLocale(
                                          "The remote link has been sent"));

                                  data["status"] = "sent";
                                  data["datetime"] =
                                      DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(DateTime.now());
                                  data["SetID"] = tsarObj["SetID"];
                                  widget.onChanged(data);
                                } else {
                                  Navigator.of(context).pop();
                                  remoteFailed(
                                      context,
                                      getLocale(
                                          "Failed to send the remote link"),
                                      res["Message"]);
                                }
                              }).catchError((onError) {
                                Navigator.of(context).pop();
                                if (onError is AppCustomException) {
                                  remoteFailed(
                                      context,
                                      getLocale(
                                          "Failed to send the remote link"),
                                      onError.message!);
                                } else {
                                  remoteFailed(
                                      context,
                                      getLocale(
                                          "Failed to send the remote link"),
                                      onError.message);
                                }
                              });
                            }
                          }
                        }
                      }
                    },
                    child: Text(
                        isResend ? getLocale("Send Again") : getLocale("Send"),
                        style: bFontW5().copyWith(color: Colors.white)))))
      ];
      return widgets;
    }

    List<Widget> disabledLabelAndTextField() {
      List<Widget> widgets = [];
      String via;
      String address;
      if (data["method"] == "S") {
        via = getLocale("Mobile");
        address = data["recipientMobile"];
      } else {
        via = getLocale("Email");
        address = data["recipientEmail"];
      }
      widgets = [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text("${getLocale("Via")} $via", style: bFontW5()))),
        Expanded(flex: 3, child: disabledTextField(address))
      ];
      return widgets;
    }

    List<Widget> formWidgetList() {
      List<Widget> widgets = [];
      if (widget.obj["VerifyStatus"] == "1") {
        if (widget.obj["datetime"] != null) {
          final sentdate =
              DateFormat('dd-MM-yyyy hh:mm a').parse(widget.obj["datetime"]);
          final date2 = DateTime.now();
          final difference = date2.difference(sentdate).inMinutes;
          if (difference >= 5) {
            widgets = enabledLabelAndTextField(true);
          } else {
            widgets = disabledLabelAndTextField();
            widgets.add(Expanded(child: Container()));
          }
        }
      } else if (widget.obj["VerifyStatus"] == "2") {
        widgets = disabledLabelAndTextField();
        widgets.add(Expanded(
            child: SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                        backgroundColor: cyanColor),
                    onPressed: () async {
                      var results = await Navigator.of(context)
                          .push(createRoute(Verify(widget.setID!, widget.obj)));
                      if (results != null) {
                        data["status"] = results["status"];
                        data["datetime"] = results["datetime"];
                        if (results["res"] != null) {
                          if (results["status"] == "confirmed") {
                            if (!mounted) {}
                            remoteComplete(
                                context,
                                getLocale(
                                    "The remote signature has been verified"));
                          } else if (results["status"] == "rejectedByAgent") {
                            if (!mounted) {}
                            remoteFailed(
                                context,
                                getLocale(
                                    "The remote signature has been rejected by you"),
                                "");
                          }
                        } else {
                          if (!mounted) {}
                          remoteFailed(
                              context,
                              getLocale(
                                  "Failed to verify the remote signature"),
                              results["res"]["Message"]);
                        }
                        widget.onChanged(data);
                      }
                    },
                    child: Text(getLocale("Verify"),
                        style: bFontW5().copyWith(color: Colors.white))))));
      } else if (widget.obj["VerifyStatus"] == "7" ||
          widget.obj["VerifyStatus"] == "6" ||
          widget.obj["VerifyStatus"] == "4") {
        widgets = enabledLabelAndTextField(true);
      } else if (widget.obj["VerifyStatus"] == "5") {
        widgets = disabledLabelAndTextField();
        widgets.add(Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                    backgroundColor: tealGreenColor,
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 20)))));
      } else if (widget.obj["isPayor"] && widget.obj["PaymentStatus"] == "3") {
        widgets = disabledLabelAndTextField();
        widgets.add(Expanded(child: Container()));
      } else if (widget.obj["isPayor"] && widget.obj["PaymentStatus"] == "7" ||
          widget.obj["PaymentStatus"] == "6" ||
          widget.obj["PaymentStatus"] == "4") {
        widgets = enabledLabelAndTextField(true);
      } else {
        widgets = enabledLabelAndTextField(false);
      }
      return widgets;
    }

    Widget options() {
      return PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (choice) async {
            if (choice == "Resend") {
              loadingDialog(
                  context, getLocale("Sending remote link to recipient"));
              var obj = {
                "Method": "PUT",
                "Body": {
                  "SetID": widget.setID,
                  "ClientID": remoteClientListID([widget.obj]),
                  "VerifyStatus": "",
                  "Remark": "",
                  "IsResend": true,
                  "Via": widget.obj["method"] ?? widget.obj["Via"],
                  "ViaDetail": widget.obj["method"] != null
                      ? widget.obj["method"] == "M"
                          ? widget.obj["recipientEmail"]
                          : widget.obj["recipientMobile"]
                      : widget.obj["ViaDetail"]
                }
              };
              await NewBusinessAPI().remote(obj).then((res) {
                Navigator.of(context).pop();
                data["status"] = "sent";
                data["datetime"] =
                    DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
                widget.onChanged(data);
                remoteComplete(
                    context, getLocale("The remote link has been resent"));
              }).onError((error, stackTrace) {});
            } else if (choice == "Switch to capture here") {
              await confirmSwitch(context).then((value) {
                if (value) {
                  widget.remoteChange();
                }
              });
            }
          },
          itemBuilder: (BuildContext context) {
            List<String> optionList = ["Resend"];
            return optionList.map((String choice) {
              return PopupMenuItem<String>(
                  value: choice, child: Text(choice, style: bFontW5()));
            }).toList();
          });
    }

    bool enableOption = false;
    if (widget.obj["status"] != "" &&
        widget.obj["VerifyStatus"] != "1" &&
        widget.obj["VerifyStatus"] != "5") {
      enableOption = true;
    } else {
      if (widget.obj["VerifyStatus"] == "1") {
        if (widget.obj["datetime"] != null) {
          final sentdate =
              DateFormat('dd-MM-yyyy HH:mm a').parse(widget.obj["datetime"]);
          final date2 = DateTime.now();
          final difference = date2.difference(sentdate).inMinutes;
          if (difference >= 5) {
            enableOption = true;
          }
        }
      }
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        decoration: BoxDecoration(
            color: (widget.obj["VerifyStatus"] == "5")
                ? lightCyanColor
                : Colors.white,
            border: Border.all(width: 1, color: greyBorderTFColor),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Text(widget.obj["role"],
                    style: bFontWN().copyWith(color: greyTextColor))),
            Visibility(visible: enableOption, child: options())
          ]),
          Row(children: [
            Text(widget.obj["name"] ?? "", style: bFontW5()),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(widget.obj["nric"] ?? "", style: bFontWN()))
          ]),
          Container(
              decoration: BoxDecoration(
                  color: widget.obj["VerifyStatus"] == "5"
                      ? Colors.white
                      : darkerCreamColor,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(getLocale("Signature for Declaration"),
                            style: bFontW5())),
                    Expanded(child: status()),
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: statusDetail()))
                  ])),
          Visibility(
              visible: widget.obj["isPayor"],
              child: Container(
                  decoration: BoxDecoration(
                      color: widget.obj["PaymentStatus"] == "9"
                          ? lightCyanColor
                          : darkerCreamColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child:
                                Text(getLocale("Payment"), style: bFontW5())),
                        Expanded(
                            child: RichText(
                                text: TextSpan(
                                    text: '${getLocale("Status")} : ',
                                    style: bFontW5(),
                                    children: <TextSpan>[
                              TextSpan(
                                  text: widget.obj["PaymentStatus"] == "9"
                                      ? getLocale("Paid")
                                      : widget.obj["PaymentStatus"] == "3"
                                          ? getLocale("Pending payment")
                                          : "-",
                                  style: bFontW5().copyWith(
                                      color: widget.obj["PaymentStatus"] == "9"
                                          ? cyanColor
                                          : Colors.black))
                            ]))),
                        Expanded(child: Container())
                      ]))),
          Form(
              key: widget.formkey,
              child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: formWidgetList()))),
          Visibility(
              visible: widget.obj["VerifyStatus"] == "7" &&
                  widget.obj["Remark"] != null,
              child: Container(
                  decoration: BoxDecoration(
                      color: lightPinkColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.close, color: scarletRedColor)),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getLocale("Recipient feedback"),
                                    style: bFontW5()
                                        .copyWith(color: scarletRedColor)),
                                Text(widget.obj["Remark"] ?? "-",
                                    style: bFontWN()
                                        .copyWith(color: scarletRedColor))
                              ])
                        ])
                  ]))),
          Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                  visible: widget.obj["isPayor"] &&
                      widget.info["remote"]["enablePayor"] != null &&
                      !widget.info["remote"]["enablePayor"] &&
                      widget.obj["VerifyStatus"] != "5",
                  child: Text(
                      "* ${getLocale("This link can only be sent out individually once all required signatures are captured")}.",
                      style: sFontWN().copyWith(color: scarletRedColor))))
        ]));
  }
}

// Remote Status
// 1 - Pending E Signature
// 2 - Pending Verification
// 3 - Pending payment
// 4 - Rejected by agent
// 5 - Accepted
// 6 - Expired
// 7 - Rejected by client
// 8 - Cancelled
// 9 - Completed
// 10 - Reassessment