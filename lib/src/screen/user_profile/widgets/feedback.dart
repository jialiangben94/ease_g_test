import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/three_size_dot.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  FeedbackState createState() => FeedbackState();
}

class FeedbackState extends State<FeedbackPage> {
  dynamic inputList = {
    "feedback": {
      "label": "Message",
      "maxLines": 20,
      "type": "text",
      "enabled": true,
      "value": "",
      "size": {"textWidth": 80, "fieldWidth": 120, "emptyWidth": 0},
      "required": true,
      "column": true,
      "sentence": true
    }
  };

  @override
  void initState() {
    super.initState();
  }

  void submittingFeedback() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ThreeSizeDot(
                            color_1: honeyColor,
                            color_2: honeyColor,
                            color_3: honeyColor),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text(getLocale("Submitting your feedback"),
                                style: t2FontWB()))
                      ])));
        });
  }

  void sendComplete(bool complete) {
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
                  child: Column(children: [
                    const SizedBox(height: 36),
                    complete
                        ? const Image(
                            width: 90,
                            height: 90,
                            image:
                                AssetImage('assets/images/submitted_icon.png'))
                        : Icon(Icons.cancel_outlined,
                            size: 60, color: scarletRedColor),
                    Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                            complete
                                ? getLocale("Sent!")
                                : getLocale("Failed to submit feedback"),
                            style: t2FontWB()))
                  ])));
        });
  }

  void submitFeedback(String message) async {
    submittingFeedback();
    await ServicingAPI().submitFeedback(message).then((res) {
      Navigator.of(context).pop();
      if (res != null) {
        if (res["IsSuccess"]) {
          sendComplete(true);
          // Navigate user to Home
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop();
          });
          Future.delayed(const Duration(seconds: 4), () {
            Navigator.of(context).pop();
          });
        } else {
          sendComplete(false);
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop();
          });
        }
      } else {
        sendComplete(false);
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
      }
    }).catchError((onError) {
      Navigator.of(context).pop();
      sendComplete(false);
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          normalAppBar(context, "Leave Feedback"),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gFontSize * 2),
                  child: Column(children: [
                    Expanded(
                        child: EaseAppTextField(
                            obj: inputList["feedback"],
                            onChanged: (val) {
                              setState(() {
                                inputList["feedback"]["value"] = val;
                              });
                            })),
                    Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: honeyColor),
                            onPressed: () {
                              submitFeedback(inputList["feedback"]["value"]);
                            },
                            child:
                                Text(getLocale("Submit"), style: t2FontWB())))
                  ])))
        ]));
  }
}
