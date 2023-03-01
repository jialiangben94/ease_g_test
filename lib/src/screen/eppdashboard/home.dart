import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EPPDashboard extends StatefulWidget {
  final String mainUrl;
  const EPPDashboard({Key? key, required this.mainUrl}) : super(key: key);

  @override
  EPPDashboardState createState() => EPPDashboardState();
}

class EPPDashboardState extends State<EPPDashboard> {
  final GlobalKey webViewKey = GlobalKey();
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 1,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close))
            ],
            title: const Text("EPP Dashboard",
                style: TextStyle(color: Colors.black))),
        body: WebView(
            onWebViewCreated: (WebViewController c) async {
              setState(() {
                _controller = c;
                _controller.loadUrl(widget.mainUrl);
              });
            },
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.mainUrl));
  }
}
