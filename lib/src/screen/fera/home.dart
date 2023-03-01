import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeraHome extends StatefulWidget {
  final String mainUrl;
  const FeraHome({Key? key, required this.mainUrl}) : super(key: key);

  @override
  FeraHomeState createState() => FeraHomeState();
}

class FeraHomeState extends State<FeraHome> {
  String? token;

  final GlobalKey webViewKey = GlobalKey();
  late WebViewController _controller;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString(spkToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return token != null
        ? Scaffold(
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
                title: GestureDetector(
                    onTap: () async {
                      await _controller.loadUrl(widget.mainUrl,
                          headers: {"Authorization": "Bearer $token"});
                    },
                    child: Text(getLocale("FERA"),
                        style: const TextStyle(color: Colors.black)))),
            body: WebView(
                navigationDelegate: (NavigationRequest request) async {
                  var isAuth = request.url.toLowerCase().contains("authcode");

                  if (request.url == widget.mainUrl || isAuth) {
                    return NavigationDecision.navigate;
                  } else {
                    if (await canLaunchUrl(Uri.parse(request.url))) {
                      await launchUrl(Uri.parse(request.url),
                          mode: LaunchMode.inAppWebView);
                      return NavigationDecision.prevent;
                    } else if (request.url.contains("data:image") ||
                        request.url.contains("base64")) {
                      var encodedStr =
                          request.url.replaceAll("data:image/png;base64,", "");
                      Uint8List bytes = base64.decode(encodedStr);
                      String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      File file = File(
                          "$dir/QRCode${DateTime.now().millisecondsSinceEpoch}.png");
                      await file.writeAsBytes(bytes);
                      GallerySaver.saveImage(file.path).then((path) {
                        showSnackBarSuccess("Image successfully saved!");
                      });
                      return NavigationDecision.prevent;
                    } else {
                      showSnackBarError(getLocale(
                          "Unexpected error occurs. We are unable to open the link."));
                      return NavigationDecision.prevent;
                    }
                  }
                },
                onWebViewCreated: (WebViewController c) async {
                  setState(() {
                    _controller = c;
                    _controller.loadUrl(widget.mainUrl,
                        headers: {"Authorization": "Bearer $token"});
                  });
                },
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: widget.mainUrl))
        : Scaffold(
            appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                title: Text(getLocale("Agent Recruitment"),
                    style: const TextStyle(color: Colors.black))),
            body: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(honeyColor)),
                  const SizedBox(height: 10),
                  Text(getLocale("Reloading.."))
                ])));
  }
}
