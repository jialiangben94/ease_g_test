import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/view_medical_requirement_letter.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GeneralColumn extends StatelessWidget {
  final AppointmentRequest data;
  const GeneralColumn(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Visibility(
          visible: !data.client!.isPO!,
          child: Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(getLocale("Policy Owner", entity: true),
                    style: bFontWN().copyWith(color: greyTextColor)),
                const SizedBox(height: 5),
                Text(data.client!.poName != null ? data.client!.poName! : "",
                    style: bFontW5())
              ]))),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Proposal date"),
            style: bFontWN().copyWith(color: greyTextColor)),
        const SizedBox(height: 5),
        Text(
            data.requestDate != null
                ? DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(data.requestDate!))
                    .toString()
                : DateFormat('dd MMM yyyy').format(DateTime.now()),
            style: bFontW5())
      ])),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Product Name"),
            style: bFontWN().copyWith(color: greyTextColor)),
        const SizedBox(height: 5),
        Text(data.productName != null ? data.productName! : "SecureLink",
            style: bFontW5())
      ])),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("${getLocale("Proposal No")}.",
            style: bFontWN().copyWith(color: greyTextColor)),
        const SizedBox(height: 5),
        Text(data.ssProposalNo != null ? data.ssProposalNo! : "-",
            style: bFontW5())
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Medical Requirement Letter"),
            style: bFontWN().copyWith(color: greyTextColor)),
        const SizedBox(height: 5),
        InkWell(
            onTap: () async {
              await Navigator.of(context).push(createRoute(
                  ViewMedicalRequirementLetter(
                      proposalMEId: data.proposalMEId ?? "1")));

              //ADD ID TO ALREADY READ IN SHARED pref
              await saveReadIds(data.propNo);
              await analyticsSendEvent("view_medical_letter", {
                "button_name": "View Medical Letter",
                "propNo": data.propNo
              });
            },
            child: Row(children: [
              const Image(
                  width: 15,
                  height: 20,
                  image: AssetImage('assets/images/medical_letter_icon.png')),
              const SizedBox(width: 5),
              Text(getLocale("View"),
                  style: bFontWN().copyWith(color: cyanColor)),
              Icon(Icons.adaptive.arrow_forward, color: cyanColor, size: 12)
            ]))
      ])
    ]);
  }
}
