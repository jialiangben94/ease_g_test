import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_device/safe_device.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  final String? message;
  const SplashScreen({Key? key, this.message}) : super(key: key);
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notify();
    });
  }

  void notify() async {
    if (widget.message != null && widget.message != "") {
      await notifyUser(context, widget.message);
    } else {
      if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;

        var version = "${iosInfo.systemVersion}.0";
        var vversion = version.split(".");
        var mainVersion = int.parse(vversion[0]);

        if (iosInfo.model != "iPad") {
          if (!mounted) {}
          await notifyUser(context,
              getLocale("Unfortunately, this app is only compatible for iPad"));
        } else if (mainVersion < 12) {
          if (!mounted) {}
          await notifyUser(
              context,
              getLocale(
                  "Unfortunately, this app is only compatible for iOS version 12 and higher"));
        } else {
          await SafeDevice.isJailBroken.then((isJailBroken) async {
            if (isJailBroken) {
              await notifyUser(
                  context,
                  getLocale(
                      "This app cannot be used because you are using a jailbroken device"));
            }
          });
        }
      } else {
        await SafeDevice.isJailBroken.then((isJailBroken) async {
          if (isJailBroken) {
            await notifyUser(
                context,
                getLocale(
                    "This app cannot be used because you are using a jailbroken device"));
          }
        });
      }
    }
  }

  Future<void> notifyUser(BuildContext context, String? message) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(getLocale('Unable to run app')),
              content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(message!)),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // exit(0);
                    },
                    child: const Text('OK'))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(color: Colors.white, child: buildLoading()));
  }
}

class NewVersion extends StatefulWidget {
  final String? message;
  const NewVersion({Key? key, this.message}) : super(key: key);
  @override
  NewVersionState createState() => NewVersionState();
}

class NewVersionState extends State<NewVersion> {
  String? urlDownload;
  @override
  void initState() {
    super.initState();
    fetchDownloadUrl();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notify();
    });
  }

  fetchDownloadUrl() async {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 30),
      minimumFetchInterval: const Duration(minutes: 5),
    ));
    await remoteConfig.fetchAndActivate();
    urlDownload = remoteConfig.getString('download_url');
  }

  void notify() async {
    if (widget.message != null && widget.message != "") {
      await newVersionDialog(context, widget.message);
    }
  }

  Future newVersionDialog(BuildContext context, String? message) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SystemPadding(
              child: Center(
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: screenHeight * 0.38),
                      child: SizedBox(
                          width: screenWidth * 0.45,
                          height: screenHeight * 0.4,
                          child: AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: gFontSize * 2,
                                  vertical: gFontSize * 0.5),
                              title: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: gFontSize * 0.7,
                                      vertical: gFontSize * 0.5),
                                  child: Text(
                                      getLocale("New Version Available"),
                                      style: t1FontWN())),
                              content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(message ?? "",
                                            style: bFontWN())),
                                    Container(
                                        height: 60,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: TextButton(
                                            style: TextButton.styleFrom(
                                                backgroundColor: honeyColor),
                                            onPressed: () {
                                              _launchURL();
                                            },
                                            child: Text(
                                                getLocale('Download Now'),
                                                style: t2FontWB())))
                                  ]))))));
        });
  }

  _launchURL() async {
    if (await canLaunchUrl(Uri.parse(urlDownload!))) {
      await launchUrl(Uri.parse(urlDownload!)).then((value) => exit(0));
    } else {
      throw '${getLocale("Could not launch")} $urlDownload!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(color: Colors.white, child: buildLoading()));
  }
}
