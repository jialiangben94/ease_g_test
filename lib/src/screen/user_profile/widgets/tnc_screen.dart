import 'package:ease/src/data/tnc_statement_data.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class TNCScreen extends StatelessWidget {
  const TNCScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          normalAppBar(context, ""),
          Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60.0, vertical: 0),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(getLocale("Terms of Use"),
                                style: t1FontWN())),
                        Html(data: termsOfUse),
                        // Html(data: tncStatement),
                        const SizedBox(height: 20)
                      ]))))
        ]));
  }
}
