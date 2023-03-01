import 'dart:convert';
import 'dart:io';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/login_screen.dart';
import 'package:ease/src/screen/user_profile/widgets/agent_details.dart';
import 'package:ease/src/screen/user_profile/widgets/change_password.dart';
import 'package:ease/src/screen/user_profile/widgets/feedback.dart';
import 'package:ease/src/screen/user_profile/widgets/tnc_screen.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserProfile extends StatefulWidget {
  final Agent agent;
  const UserProfile(this.agent, {Key? key}) : super(key: key);
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  bool? editPassword;
  bool isLoading = false;
  bool isEditPhoto = false;
  bool isUploading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  File? _image;
  final picker = ImagePicker();

  String? version;
  String? buildNumber;

  @override
  void initState() {
    super.initState();
    getVersion();
    analyticsSetCurrentScreen("User Profile", "UserProfile");
    editPassword = false;
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void _editPassword() {
    setState(() {
      editPassword = !editPassword!;
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        if (_image != null) isEditPhoto = true;
      }
    });
  }

  Future<void> uploadPhoto() async {
    String base64Image = base64Encode(_image!.readAsBytesSync());
    await ServicingAPI().uploadPhoto(base64Image).then((data) {
      if (data != null) {
        if (data["Message"] == "Process successful") {
          showSnackBarSuccess(
              getLocale('Profile photo have been changed successfully!'));
        } else {
          showSnackBarSuccess(
              getLocale('Error: Failed to update profile photo'));
        }
      } else {
        showSnackBarSuccess(getLocale('Error: Failed to update profile photo'));
      }
    });
  }

  void userLoggedOut(String message) async {
    setState(() {
      isLoading = true;
    });
    bool haveConn = await checkConnectivity();
    if (haveConn) {
      await ServicingAPI().logout();
    }
    Future.delayed(const Duration(seconds: 1), () {
      showSnackBarSuccess(message);
    });
    Future.delayed(const Duration(seconds: 2), () {
      AuthenticationRepository.internal().removeUserProfile();
      setState(() {
        isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    SingleChildScrollView columnOne(Agent agent) {
      return SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(children: [
                  Center(
                      child: CircleAvatar(
                          radius: 110,
                          backgroundColor: lightPinkColor,
                          child: _image != null
                              ? ClipOval(
                                  child: Image.file(_image!,
                                      width: 220,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true))
                              : agent.profilePhoto != null
                                  ? ClipOval(
                                      child: Image.memory(
                                          base64Decode(agent.profilePhoto!),
                                          width: 220,
                                          height: 220,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true))
                                  : Text(agent.fullName![0],
                                      style: tFontWN().apply(
                                          color: scarletRedColor,
                                          fontSizeFactor: 2.6)))),
                  TextButton(
                      onPressed: getImage,
                      child: Text(getLocale("Edit photo"),
                          style: bFontWN().copyWith(color: cyanColor))),
                  Visibility(
                      visible: isEditPhoto,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  setState(() {
                                    isUploading = true;
                                  });
                                  await uploadPhoto().then((value) {
                                    setState(() {
                                      isUploading = false;
                                      isEditPhoto = false;
                                    });
                                  });
                                },
                                child: isUploading
                                    ? SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    honeyColor)))
                                    : Text(getLocale("Save"),
                                        style: bFontWN()
                                            .copyWith(color: cyanColor))),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    isEditPhoto = false;
                                    _image = null;
                                  });
                                },
                                child: Text(getLocale("Cancel"),
                                    style: bFontWN()
                                        .copyWith(color: greyTextColor)))
                          ]))
                ])),
            Center(child: Text(agent.fullName!, style: t2FontWB())),
            SizedBox(height: MediaQuery.of(context).size.height * 0.32),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("EaSE v$version ($buildNumber)", style: bFontWN()))
          ]));
    }

    SingleChildScrollView columnTwo(Agent agent) {
      return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            AgentDetails(agent),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                // padding: EdgeInsets.symmetric(
                //   vertical: editPassword == true ? 20 : MediaQuery.of(context).size.height * 0.15 ),
                child: Column(children: [
                  const Divider(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(createRoute(const TNCScreen()));
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Image(
                                      width: 30,
                                      height: 30,
                                      image: AssetImage(
                                          'assets/images/trustee_consent.png')),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 14),
                                      child: Text(
                                          getLocale(
                                              "Privacy Statements and Terms & Conditions"),
                                          style: bFontWN()))
                                ]),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(createRoute(const TNCScreen()));
                                    },
                                    icon: Icon(Icons.adaptive.arrow_forward))
                              ]))),
                  const Divider(),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Image(
                                  width: 30,
                                  height: 30,
                                  image: AssetImage(
                                      'assets/images/lock_icon.png')),
                              Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Text(getLocale("Change Password"),
                                      style: bFontWN()))
                            ]),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    editPassword = !editPassword!;
                                    // if(editPassword == true){
                                    //   editPassword = false;
                                    // } else {
                                    //   editPassword = true;
                                    // }
                                  });
                                },
                                icon: Icon(editPassword == false
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up))
                          ])),
                  AnimatedContainer(
                      height: editPassword == true
                          ? MediaQuery.of(context).size.height * 0.74
                          : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ChangePassword(_editPassword))),
                  const Divider(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(createRoute(const FeedbackPage()));
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Icon(Icons.comment,
                                      size: 30, color: cyanColor),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 14),
                                      child: Text(getLocale("Feedbacks"),
                                          style: bFontWN()))
                                ]),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          createRoute(const FeedbackPage()));
                                    },
                                    icon: Icon(Icons.adaptive.arrow_forward))
                              ])))
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Visibility(
                  visible: agent.lastAuthenticatedDate != null &&
                      agent.lastAuthenticatedDate != "",
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Center(
                            child: RichText(
                                text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: "${getLocale("Last login time")}: ",
                              style: bFontWN()),
                          TextSpan(
                              text: DateFormat("d MMMM y, HH:mm")
                                  .format(DateTime.parse(
                                      agent.lastAuthenticatedDate != null &&
                                              agent.lastAuthenticatedDate != ""
                                          ? agent.lastAuthenticatedDate!
                                          : DateTime.now().toString()))
                                  .toString(),
                              style: bFontW5())
                        ])))
                      ]))),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: () async {
                    userLoggedOut("Logging out");
                  },
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(color: cyanColor)),
                  // shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(5.0),
                  //     side: BorderSide(color: cyanColor)),
                  // padding: EdgeInsets.symmetric(vertical: 14),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                          "${getLocale("Logging Out")} ... ",
                                          style: bFontW5()
                                              .apply(color: cyanColor))),
                                  SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      cyanColor))))
                                ])
                          : Text(getLocale("Logout"),
                              style: bFontW5().apply(color: cyanColor)))),
              const SizedBox(height: 20)
            ])
          ]));
    }

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          normalAppBar(context, getLocale("My Profile")),
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                Expanded(flex: 2, child: columnOne(widget.agent)),
                Container(color: Colors.grey[200], width: 1),
                Expanded(flex: 3, child: columnTwo(widget.agent))
              ]))
        ]));
  }
}
