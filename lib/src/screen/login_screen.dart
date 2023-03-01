import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ease/src/bloc/network_error.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/service/push_notification.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/network_util.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthenticationRepository? authenticationRepository;

  int failCounter = 0;
  Timer? timer;
  int countdown = 900;

  bool didAuthenticate = false;
  bool isBiometricsAvailable = false;
  bool isLoading = false;
  bool isLoadingReset = false;
  bool isResetPassword = false;
  bool isResetSuccess = false;
  bool obscureText = true;
  bool onClosing = false;

  final TextEditingController _usernameCont = TextEditingController();
  final TextEditingController _passwordCont = TextEditingController();
  final TextEditingController _emailAddressRPCont = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeEmail = FocusNode();

  String method = "Fingerprint";
  List<BiometricType> availableBiometrics = [];
  final LocalAuthentication auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();

  String? version;
  String? buildNumber;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Login Screen", "LoginScreen");
    getVersion();
    checkFailedLoginCounter();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await checkBiometric();
  }

  @override
  void dispose() async {
    _usernameCont.clear();
    _passwordCont.clear();
    super.dispose();
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  void startTimer() async {
    await storage.read(key: fssFailedLoginDT).then((value) {
      setState(() {
        if (value != null && value != "") {
          final datenow = DateTime.now();
          DateTime lastAttemptLoginDT =
              DateTime.fromMicrosecondsSinceEpoch(int.parse(value));
          final difference = datenow.difference(lastAttemptLoginDT).inSeconds;
          if (difference > countdown) {
            countdown = 0;
          } else {
            countdown = countdown - difference;
          }
        }
      });
    });
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer ttimer) {
      if (countdown == 0) {
        setState(() {
          ttimer.cancel();
          failCounter = 0;
          saveToFlutterSecureStorage(
              fssFailedLoginCount, failCounter.toString());
        });
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  Future<void> checkFailedLoginCounter() async {
    await storage.read(key: fssFailedLoginCount).then((value) {
      setState(() {
        if (value != null && value != "") failCounter = int.parse(value);
        // failCounter = 0; // disable block 3 times
      });
    });
    if (failCounter >= 3) startTimer();
  }

  Future<void> checkBiometric() async {
    availableBiometrics = await auth.getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      await storage.read(key: fssLoginDetail).then((value) {
        if (value != null && value != "") {
          setState(() {
            isBiometricsAvailable = true;
          });
        }
      });
    }
    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        method = "Face ID";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        method = "Touch ID";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void registerNotification(String? token, String? agentCode) async {
      String? firebaseKey = await PushNotificationsManager().getToken();
      await MedicalAppointmentAPI()
          .pushNotificationsRegister(token, agentCode, firebaseKey)
          .catchError((error) {
        if (error is AppCustomException) {
          showSnackBarError("${error.message}. Please try again.");
        } else {
          showSnackBarError("$error. Please try again.");
        }
      });
    }

    void handleLogin(
        String? username, String? password, bool isBiometric) async {
      /* 
         1. INIT DATA TO AUTH SERVICE
      *  2. IF NULL, REGISTRATION SUCCESSFUL. => SHOW NEW SCREEN 
      *  3. IF ERROR EXIST, REGISTRATION FAILED. => SHOW ERROR ON FLUSH BAR 
      */

      bool haveConn = await checkConnectivity();
      if (haveConn) {
        if (!isBiometric && _loginFormKey.currentState!.validate() ||
            isBiometric) {
          setState(() {
            isLoading = true;
          });
          try {
            await ServicingAPI()
                .agentAuthentication(username, password)
                .then((data) async {
              if (data != null) {
                if (data["IsSuccess"]) {
                  // Send to firebase analytic
                  await analytics.setUserId(id: username);
                  await analytics.logLogin(
                      loginMethod: didAuthenticate ? "biometric" : "password");

                  await ServicingAPI()
                      .getAgentDetails(data["Token"])
                      .then((dataAgent) {
                    // Add user data to bloc
                    final Agent agent = Agent.fromJson(dataAgent);
                    BlocProvider.of<UserProfileBloc>(context).add(
                        UpdateUserProfile(
                            data["Token"], data["RefreshToken"], agent));

                    // Register Firebase Messaging
                    registerNotification(data["Token"], agent.accountCode);

                    // Show success message.
                    showSnackBarSuccess(getLocale("User logged in"));

                    Future.delayed(const Duration(milliseconds: 3000), () {
                      failCounter = 0;
                      saveToFlutterSecureStorage(
                          fssFailedLoginCount, failCounter.toString());
                      if (mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()));
                      }
                    });
                  }).onError((dynamic error, stackTrace) {
                    setState(() {
                      isLoading = false;
                    });
                    if (error is AppCustomException) {
                      showSnackBarError(
                          "${error.message}. ${getLocale("Please try again")}.");
                    } else {
                      showSnackBarError(
                          "$error. ${getLocale("Please try again")}.");
                    }
                  });
                } else {
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    setState(() {
                      isLoading = false;
                      if (data["Message"] ==
                          getLocale(
                              "Unauthorized Access - Invalid Account Code or Password.")) {
                        failCounter++;
                        saveToFlutterSecureStorage(
                            fssFailedLoginCount, failCounter.toString());
                      }
                    });
                    if (failCounter >= 3) {
                      saveToFlutterSecureStorage(fssFailedLoginDT,
                          DateTime.now().microsecondsSinceEpoch.toString());
                      startTimer();
                    }
                    showSnackBarError(data["Message"]);
                  });
                }
              } else {
                setState(() {
                  isLoading = false;
                });
                showSnackBarError(getLocale(
                    "No response returned from the server. Please try again."));
              }
            }).onError((dynamic error, stackTrace) {
              setState(() {
                isLoading = false;
              });
              if (error is AppCustomException) {
                showSnackBarError(
                    "${error.message}. ${getLocale("Please try again")}.");
              } else {
                showSnackBarError("$error. ${getLocale("Please try again")}.");
              }
            });
          } on NetworkError catch (e) {
            setState(() {
              isLoading = false;
            });
            if (!mounted) {}
            showSnackBarError("$e. ${getLocale("Please try again")}.");
          }
        }
      } else {
        if (!mounted) {}
        showSnackBarError(getLocale("Please check your internet connection"));
      }
    }

    Future<void> localAuth() async {
      try {
        didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to login');
      } on PlatformException catch (e) {
        showSnackBarError(e.message ?? "");
      }
      if (didAuthenticate) {
        await storage.read(key: fssLoginDetail).then((value) {
          LoginDetails loginDetails =
              LoginDetails.fromJson(json.decode(value!));
          handleLogin(loginDetails.username, loginDetails.password, true);
        });
      }
    }

    void handleReset() async {
      bool haveConn = await checkConnectivity();
      if (haveConn) {
        if (_resetPasswordFormKey.currentState!.validate()) {
          setState(() {
            isLoadingReset = true;
          });
          await ServicingAPI()
              .resetPassword(_usernameCont.text, _emailAddressRPCont.text)
              .then((data) {
            setState(() {
              isLoadingReset = false;
              if (data["Message"] == "Process successful") {
                _usernameCont.clear();
                _emailAddressRPCont.clear();
                isResetSuccess = true;
              } else if (data["Message"] == "Process failed") {
                showSnackBarError(  data["Message"]);
              }
            });
          });
        }
      } else {
        if (!mounted) {}
        showSnackBarError( getLocale("Please check your internet connection"));
      }
    }

    Widget backgroundImage() {
      return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Stack(children: [
            Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/background_new.jpg'),
                            fit: BoxFit.fitHeight)))),
            const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.only(top: 50, left: 20),
                    child: SizedBox(
                        height: 50,
                        width: 110,
                        child: Image(
                            image: AssetImage(
                                'assets/images/etiqa_logo_white.png'),
                            fit: BoxFit.contain))))
          ]));
    }

    Widget usernameTF(FocusNode focusNode) {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
              autofillHints: const [AutofillHints.username],
              controller: _usernameCont,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.grey,
              style: bFontWN(),
              decoration: InputDecoration(
                  hintText: getLocale("Username (your agent ID)"),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0))),
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(focusNode),
              validator: (value) {
                return validateUsername(value!);
              }));
    }

    Widget passwordTF() {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
              autofillHints: const [AutofillHints.password],
              obscureText: obscureText,
              controller: _passwordCont,
              textInputAction:
                  failCounter < 3 ? TextInputAction.go : TextInputAction.done,
              focusNode: focusNodePassword,
              cursorColor: Colors.grey,
              style: bFontWN(),
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: obscureText
                          ? const Icon(Icons.visibility_off,
                              color: Colors.black)
                          : const Icon(Icons.visibility, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      }),
                  hintText: getLocale("Password"),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0))),
              onFieldSubmitted: (_) => failCounter < 3
                  ? handleLogin(_usernameCont.text, _passwordCont.text, false)
                  : null,
              validator: (value) {
                return validatePassword(value!);
              }));
    }

    Widget emailAddressTF() {
      return Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
              controller: _emailAddressRPCont,
              focusNode: focusNodeEmail,
              textInputAction: TextInputAction.go,
              cursorColor: Colors.grey,
              style: bFontWN(),
              decoration: InputDecoration(
                  hintText: getLocale("Registered email address"),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0))),
              onFieldSubmitted: (_) => handleReset(),
              validator: (value) {
                return validEmail(value!);
              }));
    }

    Widget loginForm() {
      Duration clockTimer = Duration(seconds: countdown);
      double height = 0;
      if (failCounter == 0) {
        height = MediaQuery.of(context).size.height * 0.12;
      } else if (failCounter == 1 || failCounter == 2) {
        height = MediaQuery.of(context).size.height * 0.08;
      } else if (failCounter >= 3) {
        height = MediaQuery.of(context).size.height * 0.06;
      }

      return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 45),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    /* HEADER */
                    Row(children: [
                      Text("Welcome to",
                          style: tFontW5().copyWith(fontSize: 30)),
                      Text(" EaSE",
                          style: tFontW5()
                              .copyWith(fontSize: 30, color: honeyColor)
                              .apply(fontWeightDelta: 1))
                    ]),
                    const SizedBox(height: 15),
                    /* SUB HEADER */
                    RichText(
                        text: TextSpan(
                            text: 'Etiqa Sales Evolution (EaSE) ',
                            style: bFontW5().copyWith(color: greyTextColor),
                            children: <TextSpan>[
                          TextSpan(
                              text: getLocale(
                                  'serve all our Life agent to provide better service and experience…'),
                              style: bFontWN().copyWith(color: greyTextColor))
                        ])),
                    /* LOGIN FORM */
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Text(getLocale("Login to your account"), style: t2FontW5()),
                    Form(
                        key: _loginFormKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: AutofillGroup(
                                child: Column(children: [
                              usernameTF(focusNodePassword),
                              passwordTF()
                            ])))),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            isResetPassword = true;
                          });
                        },
                        child: Text(getLocale("Forgot password"),
                            style: bFontWN()
                                .copyWith(fontSize: 16, color: cyanColor))),
                    const SizedBox(height: 20),
                    isLoading
                        ? Transform.scale(
                            scale: 0.9,
                            child: SizedBox(
                                height: 59,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${getLocale("LOGGING IN")} ... ",
                                          style: t2FontWB()),
                                      const SizedBox(width: 30),
                                      CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  honeyColor))
                                    ])))
                        : Row(children: [
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: SizedBox(
                                        height: 55,
                                        child: failCounter >= 3
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: lightGreyColor2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: Center(
                                                    child: Text(getLocale("LOGIN"),
                                                        style: t2FontWB().copyWith(
                                                            color:
                                                                greyTextColor))))
                                            : ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        honeyColor),
                                                onPressed: () =>
                                                    handleLogin(_usernameCont.text, _passwordCont.text, false),
                                                child: Text(getLocale("LOGIN"), style: t2FontWB()))))),
                            Visibility(
                                visible: isBiometricsAvailable,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: failCounter >= 3
                                        ? ClipOval(
                                            child: Container(
                                                color: lightGreyColor2,
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Icon(Icons.fingerprint,
                                                    color: lightGreyColor,
                                                    size: 50)))
                                        : GestureDetector(
                                            onTap: () => localAuth(),
                                            child: ClipOval(
                                                child: Container(
                                                    color: honeyColor,
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                        Icons.fingerprint,
                                                        size: 50))))))
                          ]),
                    Visibility(
                        visible: failCounter != 0,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 6),
                            child: Text(
                                failCounter == 1
                                    ? getLocale(
                                        "Login failed. You have 2 more login attempts")
                                    : failCounter == 2
                                        ? getLocale(
                                            "Login failed. You have 1 more login attempt")
                                        : getLocale(
                                            "Oops! You have failed 3 login attempts."),
                                style: sFontWN()
                                    .copyWith(color: scarletRedColor)))),
                    Visibility(
                        visible: failCounter >= 3,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: RichText(
                                text: TextSpan(
                                    text:
                                        '${getLocale("Please try again in")} ',
                                    style: sFontWN()
                                        .copyWith(color: scarletRedColor),
                                    children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          '${clockTimer.inMinutes.remainder(60).toString()}:${(clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')} ',
                                      style: sFontWB()
                                          .copyWith(color: scarletRedColor)),
                                  TextSpan(
                                      text: 'min',
                                      style: sFontWN()
                                          .copyWith(color: scarletRedColor))
                                ])))),
                    SizedBox(height: height),
                    Text("${getLocale("Important Note")}:", style: sFontWN()),
                    const SizedBox(height: 20),
                    Text(
                        getLocale(
                            "Use of this system is restricted to individuals and activities authorized by the management of the Etiqa Insurance & Takaful. Unauthorized use may result in the appropriate disciplinary action and/or legal prosecution."),
                        style: sFontWN().copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 20),
                    Center(
                        child: Text("v$version($buildNumber)",
                            style: bFontWN().copyWith(color: Colors.grey[700])))
                  ]))));
    }

    Widget resetPasswordForm() {
      return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 45),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            isResetPassword = false;
                          });
                        },
                        child: Row(children: [
                          Icon(Icons.adaptive.arrow_back,
                              size: 14, color: cyanColor),
                          const SizedBox(width: 6),
                          Text(getLocale("Back"),
                              style: bFontWN().copyWith(color: cyanColor))
                        ])),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                    Text(getLocale("Forgot Password"),
                        textAlign: TextAlign.start, style: t2FontW5()),
                    const SizedBox(height: 4),
                    Text(
                        getLocale(
                            "Please key in following details for account validation"),
                        textAlign: TextAlign.start,
                        style: bFontWN().copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 10),
                    Form(
                        key: _resetPasswordFormKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              usernameTF(focusNodeEmail),
                              emailAddressTF()
                            ])),
                    const SizedBox(height: 40),
                    isLoadingReset
                        ? Transform.scale(
                            scale: 0.9,
                            child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        honeyColor))))
                        : Padding(
                            padding: const EdgeInsets.all(2),
                            child: SizedBox(
                                height: 55,
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: honeyColor),
                                    onPressed: () => handleReset(),
                                    child: Text(getLocale("Submit"),
                                        style: t2FontWB()))))
                  ]))));
    }

    Widget resetSuccess() {
      return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 50, right: 50, top: 45),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const Image(
                    width: 55,
                    height: 55,
                    image: AssetImage('assets/images/submitted_icon.png')),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                        getLocale(
                            "We sent a temporary password to your email address."),
                        textAlign: TextAlign.center,
                        style: t2FontW5())),
                const SizedBox(height: 30),
                Text(getLocale("Please change your password after login."),
                    textAlign: TextAlign.start,
                    style: bFontWN().copyWith(color: Colors.grey[700])),
                const SizedBox(height: 40),
                Padding(
                    padding: const EdgeInsets.all(2),
                    child: SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: honeyColor),
                            onPressed: () async {
                              setState(() {
                                isResetPassword = false;
                                isResetSuccess = false;
                              });
                            },
                            child:
                                Text(getLocale("LOGIN"), style: t2FontWB()))))
              ])));
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: Row(children: [
          Expanded(flex: 4, child: backgroundImage()),
          Expanded(
              flex: 3,
              child: isResetSuccess
                  ? resetSuccess()
                  : AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child:
                          isResetPassword ? resetPasswordForm() : loginForm()))
        ]));
  }
}
