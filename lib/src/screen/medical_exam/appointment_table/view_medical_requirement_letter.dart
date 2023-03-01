import 'dart:convert';
import 'dart:io';

import 'package:ease/src/bloc/medical_exam/medical_letter/medical_letter_bloc.dart';
import 'package:ease/src/data/medical_exam_model/medical_letter.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:share_extend/share_extend.dart';

import '../../../util/function.dart';

class ViewMedicalRequirementLetter extends StatefulWidget {
  final String? proposalMEId;
  const ViewMedicalRequirementLetter({Key? key, this.proposalMEId})
      : super(key: key);

  @override
  ViewMedicalRequirementLetterState createState() =>
      ViewMedicalRequirementLetterState();
}

class ViewMedicalRequirementLetterState
    extends State<ViewMedicalRequirementLetter> {
  late String path;
  bool _progressDone = false;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("View Medical Letter", "MedicalCheckAppointment");
    _progressDone = false;
    BlocProvider.of<MedicalLetterBloc>(context)
        .add(GetMedicalLetterPath(widget.proposalMEId));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<File> writeFile(MedicalLetter medicalLetter) async {
    final output = await getTemporaryDirectory();
    String path =
        "${output.path}/${medicalLetter.fileName}.${medicalLetter.fileExtension!.toLowerCase()}";

    final file = File(path);
    var bytes = base64Decode(medicalLetter.base64!.replaceAll('\n', ''));
    await file.writeAsBytes(bytes.buffer.asUint8List());

    return file;
  }

  @override
  Widget build(BuildContext context) {
    Column buildViewListOfMedicalLetter(MedicalLetterPathLoaded state) {
      List<MedicalLetter> listOfML = state.listOfMedicalLetter;
      return Column(children: [
        const SizedBox(height: 6),
        for (int i = 0; i < listOfML.length; i++)
          GestureDetector(
              onTap: () {
                analyticsSendEvent("change_medical_letter", {
                  "button_name": "Medical Requirement ${(i + 1)}",
                  "proposalMEId": widget.proposalMEId
                });
                BlocProvider.of<MedicalLetterBloc>(context)
                    .add(LoadMedicalLetter(listOfML, listOfML[i]));
              },
              child: Container(
                  color: listOfML[i].documentId == state.selectedML.documentId
                      ? lightCyanColor
                      : Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${getLocale("Medical Requirement")} ${(i + 1)}",
                            // overflow: TextOverflow.ellipsis,
                            style: bFontW5().copyWith(
                                color: listOfML[i].documentId ==
                                        state.selectedML.documentId
                                    ? cyanColor
                                    : Colors.black)),
                        Text(
                            DateFormat("d MMMM y")
                                .format(DateTime.parse(
                                    listOfML[i].createdDateTime!))
                                .toString(),
                            style: bFontWN())
                      ])))
      ]);
    }

    Column buildPDF(MedicalLetterPathLoaded state) {
      List<MedicalLetter> listOfML = state.listOfMedicalLetter;

      return Column(children: [
        for (int i = 0; i < listOfML.length; i++)
          listOfML[i].documentId == state.selectedML.documentId
              ? FutureBuilder<File>(
                  future: writeFile(listOfML[i]),
                  builder:
                      (BuildContext context, AsyncSnapshot<File> snapshot) {
                    if (snapshot.hasData) {
                      path = snapshot.data!.path;
                      return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.9074,
                          child: PdfView(path: snapshot.data!.path));
                    } else {
                      return Container();
                    }
                  })
              : Container()
      ]);
    }

    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(75),
                child: AppBar(
                    backgroundColor: honeyColor,
                    automaticallyImplyLeading: false,
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.adaptive.arrow_back,
                                  color: Colors.black, size: 24),
                              padding: const EdgeInsets.only(top: 12)),
                          Expanded(
                              child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                      getLocale("Medical Requirement Letter"),
                                      style:
                                          sFontW5().apply(fontSizeDelta: 4)))),
                          BlocBuilder<MedicalLetterBloc, MedicalLetterState>(
                              builder: (context, state) {
                            return _progressDone == true
                                ? TextButton(
                                    onPressed: () {
                                      ShareExtend.share(path, 'file',
                                          sharePositionOrigin: Rect.fromCenter(
                                              center: Offset(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.94,
                                                  10),
                                              width: 100,
                                              height: 100));
                                    },
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Text(getLocale("Share"),
                                            style: t2FontWB())))
                                : Container();
                          })
                        ]))),
            body: BlocBuilder<MedicalLetterBloc, MedicalLetterState>(
                builder: (context, state) {
              return state is MedicalLetterPathLoaded
                  ? Row(children: [
                      Expanded(child: buildViewListOfMedicalLetter(state)),
                      Expanded(flex: 4, child: buildPDF(state))
                    ])
                  : buildLoading();
            })));
  }
}
