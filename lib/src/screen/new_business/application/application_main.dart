import 'dart:convert';
import 'dart:async';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/customer/home.dart';
import 'package:ease/src/screen/new_business/application/decision/home.dart';
import 'package:ease/src/screen/new_business/application/declaration/home.dart';
import 'package:ease/src/screen/new_business/application/financial_need/home.dart';
import 'package:ease/src/screen/new_business/application/discussion/home.dart';
import 'package:ease/src/screen/new_business/application/nomination/home.dart';
import 'package:ease/src/screen/new_business/application/nomination/home_benefit.dart';
import 'package:ease/src/screen/new_business/application/payment/home.dart';
import 'package:ease/src/screen/new_business/application/questions/home.dart';
import 'package:ease/src/screen/new_business/application/questions/home_owner.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/home.dart';
import 'package:ease/src/screen/new_business/application/remote/home.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/util/required_file_handler.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/custom_clip.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationForm extends StatefulWidget {
  final int? quoId;
  final String? qquoId;
  final int? appQuoId;

  const ApplicationForm({Key? key, this.quoId, this.qquoId, this.appQuoId})
      : super(key: key);
  @override
  ApplicationFormState createState() => ApplicationFormState();
}

class ApplicationFormState extends State<ApplicationForm> {
  Widget? currentHome;
  dynamic data;
  dynamic tabList;
  var isReady = false;

  @override
  void initState() {
    super.initState();

    tabList = {
      "defaultprogress": 0.145,
      "progress": 0.145,
      "customer": {
        "label": getLocale("Customers"),
        "completed": false,
        "route": AppCustomerHome(callback: (completed, isSave, isInit) {
          checkCompleted("customer", completed, isSave, isInit);
        }),
        "progress": 0.235
      },
      "financial": {
        "label": getLocale("Potential Area of Discussion"),
        "completed": false,
        "route": FinancialHome(callback: (completed, isSave, isInit) {
          checkCompleted("financial", completed, isSave, isInit);
        }),
        "progress": 0.32
      },
      "disclosure": {
        "label": getLocale("Financial Needs Analysis"),
        "completed": false,
        "route": DisclosureHome(callback: (completed, isSave, isInit) {
          checkCompleted("disclosure", completed, isSave, isInit);
        }),
        "progress": 0.41
      },
      "products": {
        "label": getLocale("Recommended Products"),
        "completed": false,
        "route": RecommendedProductsHome(callback: (completed, isSave, isInit) {
          checkCompleted("products", completed, isSave, isInit);
        }),
        "progress": 0.495
      },
      "nomination": {
        "label": getLocale("Nomination & Trust"),
        "completed": false,
        "route": NominationHome(callback: (completed, isSave, isInit) {
          checkCompleted("nomination", completed, isSave, isInit);
        }),
        "progress": 0.585
      },
      "benefitOwner": {
        "label": getLocale("Beneficial Owner"),
        "completed": false,
        "route": BenefitHome(callback: (completed, isSave, isInit) {
          checkCompleted("benefitOwner", completed, isSave, isInit);
        }),
        "progress": 0.585
      },
      "questions": {
        "label":
            "${getLocale("Questions")}\n(${getLocale("Life Insured", entity: true)})",
        "completed": false,
        "route": QuestionsHome(callback: (completed, isSave, isInit) {
          checkCompleted("questions", completed, isSave, isInit);
        }),
        "progress": 0.67
      },
      "questionsPolicyOwner": {
        "label":
            "${getLocale("Questions")}\n(${getLocale("Policy Owner", entity: true)})",
        "completed": false,
        "route": QuestionsHomeOwner(callback: (completed, isSave, isInit) {
          checkCompleted("questionsPolicyOwner", completed, isSave, isInit);
        }),
        "progress": 0.67,
        "enable": false
      },
      "decision": {
        "label": getLocale("Assessment/Decision"),
        "completed": false,
        "route": DecisionHome(callback: (completed, isSave, isInit) {
          checkCompleted("decision", completed, isSave, isInit);
        }),
        "progress": 0.76,
        "enable": true
      },
      "declaration": {
        "label": getLocale("Declaration"),
        "completed": false,
        "route": DeclarationHome(callback: (completed, isSave, isInit) {
          checkCompleted("declaration", completed, isSave, isInit);
        }),
        "progress": 0.845
      },
      "remote": {
        "label": getLocale("Remote"),
        "completed": false,
        "route": RemoteHome(callback: (completed, isSave, isInit) {
          checkCompleted("remote", completed, isSave, isInit);
        }),
        "progress": 0.9,
        "enable": false
      },
      "payment": {
        "label": getLocale("Payment"),
        "completed": false,
        "route": PaymentHome(callback: (completed, isSave, isInit) {
          checkCompleted("payment", completed, isSave, isInit);
        }),
        "progress": 1.0
      }
    };

    getAppDetails();
    ApplicationFormData.onTitleClicked = onTitleClicked;
    ApplicationFormData.tabList = tabList;
  }

  void getAppDetails() {
    readOptionFileAsObj().then((optionList) {
      if (mounted) {
        setState(() {
          ApplicationFormData.optionList = optionList["optionList"];
          ApplicationFormData.optionType = optionList["optionType"];
          ApplicationFormData.translation = optionList["translation"];
          ApplicationFormData.languageId = optionList["languageId"];
        });
      }
    }).catchError((err) {
      Navigator.of(context).pop();
      showAlertDialog2(
          context, "Error", getLocale("Master data cannot be loaded."));
    });

    if (widget.quoId != null && widget.qquoId != null) {
      initDataWithQuoId(widget.quoId, widget.qquoId, tabList).then((status) {
        if (status != null && status["status"] && status["data"] != null) {
          setState(() {
            ApplicationFormData.data = data = status["data"];
            data["appStatus"] = AppStatus.incomplete.toString();
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog2(context, "Error", getLocale("Record not found."));
        }
      }).catchError((err) {
        Navigator.of(context).pop();
        showAlertDialog2(context, "Error", getLocale("Record not found."));
      });
    } else if (widget.appQuoId != null) {
      initData(widget.appQuoId as int, tabList).then((status) {
        if (status != null && status["status"] && status["data"] != null) {
          setState(() {
            ApplicationFormData.data = data = status["data"];
            ApplicationFormData.id = widget.appQuoId;

            if (data["buyingFor"] != BuyingFor.self.toStr) {
              if (data["lifeInsured"] != null &&
                  (data["lifeInsured"]["amlaChecked"] == null ||
                      data["lifeInsured"]["amlaChecked"] == false)) {
                startCheckAmla(data["lifeInsured"], "li", (data, message) {
                  ApplicationFormData.data["lifeInsured"]["amlaPass"] =
                      data["amlaPass"];
                  ApplicationFormData.data["lifeInsured"]["amlaChecked"] =
                      data["amlaChecked"];
                  saveData();
                  if (data["amlaPass"] == false && message != null) {
                    showAlertDialog2(
                        context,
                        getLocale("Oops, there seems to be an issue."),
                        message, () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                          (route) => false);
                    });
                  }
                });
              }
            }

            if (data["policyOwner"] != null &&
                (data["policyOwner"]["amlaChecked"] == null ||
                    data["policyOwner"]["amlaChecked"] == false)) {
              startCheckAmla(data["policyOwner"], "po", (data, message) {
                ApplicationFormData.data["policyOwner"]["amlaPass"] =
                    data["amlaPass"];
                ApplicationFormData.data["policyOwner"]["amlaChecked"] =
                    data["amlaChecked"];
                saveData();
                if (data["amlaPass"] == false && message != null) {
                  showAlertDialog2(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      message, () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                        (route) => false);
                  });
                }
              });
            }
            if (data["recommendedProducts"] != null &&
                data["recommendedProducts"]["TSARMedicalPassed"] != null &&
                !data["recommendedProducts"]["TSARMedicalPassed"]) {
              showAlertDialog2(context, "Oops, there seems to be an issue.",
                  data["recommendedProducts"]["TSARMedicalErrorMsg"], () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (route) => false);
              });
            }
            if (data["TSARMedicalPassed"] != null &&
                !data["TSARMedicalPassed"]) {
              showAlertDialog2(
                  context,
                  getLocale("Oops, there seems to be an issue."),
                  data["TSARMedicalErrorMsg"], () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (route) => false);
              });
            }
          });
        } else if (status != null && status["msg"] != null) {
          Navigator.of(context).pop();
          showAlertDialog2(context, getLocale("Error"), status["msg"]);
        } else {
          Navigator.of(context).pop();
          showAlertDialog2(
              context, getLocale("Error"), getLocale("Record not found."));
        }
      }).catchError((err) {
        Navigator.of(context).pop();
        showAlertDialog2(
            context, getLocale("Error"), getLocale("Record not found."));
      });
    } else if (widget.appQuoId == null &&
        widget.quoId == null &&
        widget.qquoId == null) {
      ApplicationFormData.data = data = {};
      data["appStatus"] = AppStatus.incomplete.toString();
      // startAmlaCheckTimer();
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
        showAlertDialog2(context, getLocale("Error"), "Integration Error.");
      });
    }
  }

  void checkCompleted(tab, completed, isSave, isInit) async {
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    if (ApplicationFormData.data["agentCodes"] == null) {
      ApplicationFormData.data["agentCodes"] = agent.accountCode;
    }
    if (ApplicationFormData.data["agentMobilePhone"] == null) {
      ApplicationFormData.data["agentMobilePhone"] = agent.mobilePhone;
    }
    if (ApplicationFormData.data["agentEmail"] == null) {
      ApplicationFormData.data["agentEmail"] = agent.emailAddress;
    }
    updateRecipientList();
    saveData();

    if (!isInit) {
      setState(() {
        tabList[tab]["completed"] = completed;
        checkAllTabInput(ApplicationFormData.data, tabList);
        if (tab == "customer" || tab == "products" || tab == "declaration") {
          isReady = false;
        }
      });
    }
  }

  void onTitleClicked(obj) async {
    FocusScope.of(context).unfocus();
    bool valid = await validateBeforeRoute(obj, context);
    if (!valid) return;

    setState(() {
      saveData();
      currentHome = obj["route"];
    });
  }

  @override
  void dispose() {
    ApplicationFormData.data = null;
    ApplicationFormData.currentHome = null;
    ApplicationFormData.id = null;
    ApplicationFormData.isAmlaChecking = {};
    if (ApplicationFormData.amlaTimer is Map) {
      for (var i in ApplicationFormData.amlaTimer.keys) {
        ApplicationFormData.amlaTimer[i]?.cancel();
      }
    }
    ApplicationFormData.amlaTimer = {};
    ApplicationFormData.isPaymentChecking = {};
    if (ApplicationFormData.paymentTimer != null &&
        ApplicationFormData.paymentTimer is Map) {
      for (var i in ApplicationFormData.paymentTimer.keys) {
        ApplicationFormData.paymentTimer[i]?.cancel();
      }
    }
    ApplicationFormData.paymentTimer = {};
    ApplicationFormData.tabList = null;
    ApplicationFormData.onTitleClicked = null;
    ApplicationFormData.optionList = null;
    ApplicationFormData.optionType = null;
    super.dispose();
  }

  Future<bool> checkDisplayTab() async {
    if (data != null &&
        data["listOfQuotation"] != null &&
        data["listOfQuotation"][0] != null) {
      var products = await formatProductDetails();

      if (products[0]["ProdCode"] == "PCWA01" ||
          products[0]["ProdCode"] == "PCEE01") {
        if (data["buyingFor"] != "self") {
          tabList["questionsPolicyOwner"]["enable"] = true;
        }
      } else {
        // Checking riders clientype.
        // If have 1, show Policy Owner/Participant questionnaire.
        for (var i = 0; i < products.length; i++) {
          if (products[i]["ClientTypeID"] == "1" ||
              products[i]["ClientTypeID"] == 1) {
            tabList["questionsPolicyOwner"]["enable"] = true;
            break;
          } else {
            tabList["questionsPolicyOwner"]["enable"] = false;
          }
        }
      }
    }

    if (data != null && data["consentMinor"] != null && data["consentMinor"]) {
      tabList["questionsPolicyOwner"]["enable"] = false;
    }

    var validateNT = hideTrustee(data);
    if (validateNT["hideNominee"]) {
      tabList["nomination"]["enable"] = false;
    } else {
      tabList["nomination"]["enable"] = true;
    }
    if (data["remote"] != null &&
        data["remote"]["listOfRecipient"].length > 0) {
      tabList["remote"]["enable"] = true;
    } else {
      tabList["remote"]["enable"] = false;
    }

    if (mounted) {
      setState(() {
        isReady = true;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (data == null ||
        ApplicationFormData.optionList == null ||
        ApplicationFormData.optionType == null) {
      return wholeScreenLoading();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isReady == false && data != null) {
        checkDisplayTab().then((ready) {
          if (tabList["questionsPolicyOwner"]["enable"] == false) {
            data["poquestion"] = null;
          }
          var validateNT = hideTrustee(data);
          if (validateNT["hideNominee"]) {
            data.remove("nomination");
          }
        });
      }
    });

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    var swd = screenWidth / dScreenWidth;
    var shd = screenHeight / dScreenHeight;
    gFontSize = ((dScreenWidth * swd) + (dScreenHeight * shd)) * 0.010051;

    Widget navItem(obj) {
      Widget arrow = Container();
      var textColor = greyTextColor;
      var iconColor = greyDividerColor;
      var checkColor = const Color.fromRGBO(200, 200, 200, 1);
      FontWeight? titleFontWeight;

      if (obj["completed"]) {
        textColor = const Color.fromRGBO(72, 158, 147, 1);
        iconColor = const Color.fromRGBO(72, 158, 147, 1);
        checkColor = Colors.white;
      }

      if (currentHome == obj["route"]) {
        textColor = Colors.black;
        titleFontWeight = FontWeight.bold;
        arrow = ClipShadowPath(
            clipper: TriangleClip(),
            shadow: Shadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(3, 2)),
            child: Container(
                width: gFontSize,
                height: gFontSize * 1.2,
                color: Colors.white));
      }
      return GestureDetector(
        onTap: () => onTitleClicked(obj),
        child: Container(
          height: gFontSize * 4.3, //3.9
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: screenWidth * 0.06,
                  child: CircleAvatar(
                      radius: gFontSize * 0.65,
                      backgroundColor: iconColor,
                      child: Icon(Icons.check,
                          color: checkColor, size: gFontSize * 0.9))),
              Container(
                  width: screenWidth * 0.105,
                  padding: EdgeInsets.only(right: gFontSize * 0.5),
                  child: Text(obj["label"],
                      style: sFontWN().copyWith(
                          color: textColor, fontWeight: titleFontWeight))),
              arrow
            ],
          ),
        ),
      );
    }

    List<Widget> tabsWidget = [];

    for (var key in tabList.keys) {
      if (key.indexOf("progress") > -1) continue;
      if (tabList[key]["enable"] != null && !tabList[key]["enable"]) continue;
      if (!tabList[key]["completed"] && currentHome == null) {
        if (key == "questions") {
          if (data["tsarRes"] == null) {
            currentHome = tabList["benefitOwner"]["route"];
          } else {
            if (data["saLimit"] != null || data["TSARMedicalPassed"] != null) {
              currentHome = tabList["benefitOwner"]["route"];
            } else {
              currentHome = tabList["questions"]["route"];
            }
          }
        } else if (key == "decision" &&
            (data["tsarRes"] == null || data["caseindicator"] == null)) {
          currentHome = tabList["questions"]["route"];
        } else if (key == "payment" && data["application"] == null) {
          currentHome = tabList["decision"]["route"];
        } else {
          currentHome = tabList[key]["route"];
        }
      }

      tabsWidget.add(navItem(tabList[key]));
    }

    Widget progressBar(double height) {
      return Container(
        height: screenHeight * height,
        width: screenWidth * 0.005,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [honeyColor, yellowColor],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                      width: screenWidth * 0.835,
                      height: screenHeight,
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: currentHome))),
              Container(
                  width: screenWidth * 0.165,
                  height: screenHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset: const Offset(3, 0))
                  ])),
              SizedBox(
                  width: screenWidth * 0.192,
                  height: screenHeight,
                  child: SingleChildScrollView(
                      child: Stack(children: [
                    progressBar(tabList["progress"]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: gFontSize,
                                  horizontal: gFontSize * 1.5),
                              child: Text(getLocale("Application"),
                                  style: sFontWB())),
                          SizedBox(height: gFontSize * 1.5),
                          ...tabsWidget
                        ])
                  ]))),
              Positioned(
                right: 0,
                top: 0,
                child: CustomButton(
                  icon: Icons.close,
                  iconSize: gFontSize * 2,
                  buttonColor: Colors.transparent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
