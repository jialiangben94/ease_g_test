// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/src/bloc/new_business/existing_customer_bloc/existing_customer_bloc.dart';
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/master_lookup.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/occupation_search/occupation_search.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/qtn_form_widget.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/view_current_coverage.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cnq_widget.dart';

enum QuotationFor { newCustomer, existingCustomer }

class CreateNewQuote extends StatefulWidget {
  const CreateNewQuote({Key? key}) : super(key: key);

  @override
  CreateNewQuoteState createState() => CreateNewQuoteState();
}

class CreateNewQuoteState extends State<CreateNewQuote> {
  final GlobalKey<FormState> _createNewQuoteKey = GlobalKey<FormState>();
  QuotationFor? qtnFor;
  bool isConnected = false;
  bool isLoading = false;
  bool isJuvenile = true;
  bool isPolicyOwner = false;

  // If user press back button from choose product, they will return qtn
  Quotation? qtnReturned;
  String? selectedBuyingFor;
  double textFieldHeight = 70.0;
  double textFieldSize = 20.0;

  // life insured
  final TextEditingController _liNameCont = TextEditingController();
  final TextEditingController _poNameCont = TextEditingController();
  final TextEditingController searchCustomerCont = TextEditingController();

  late QuotationBloc _qtnBloc;

  List<DropdownMenuItem<String>> buyingFor = [
    (DropdownMenuItem(
        value: "self", child: Text(getLocale('Himself/herself')))),
    (DropdownMenuItem(value: "children", child: Text(getLocale('Children')))),
    (DropdownMenuItem(value: "spouse", child: Text(getLocale('Spouse'))))
  ];

  Person? selectedExistingCustomer = Person();
  Occupation? existingOcc;
  bool? existingIsSmoker;
  String? _searchCustomerKeyword;

  Person? lifeInsured = Person(clientType: "2");
  Person? policyOwner = Person(clientType: "1");

  List<MasterLookup> masterLookup = [];

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Create New Quote", "CreateNewQuote");
    checkConn();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (this.mounted) {
          setState(() {
            isConnected = true;
          });
        } else {
          if (this.mounted) {
            setState(() {
              isConnected = false;
            });
          }
        }
      }
    });
    qtnFor = QuotationFor.newCustomer;
    selectedBuyingFor = BuyingFor.self.toStr;
    _qtnBloc = BlocProvider.of<QuotationBloc>(context);
  }

  @override
  void dispose() async {
    _liNameCont.dispose();
    _poNameCont.dispose();
    super.dispose();
  }

  void checkConn() async {
    ConnectivityResult conn = await (Connectivity().checkConnectivity());
    setState(() {
      if (conn != ConnectivityResult.none) {
        isConnected = true;
      } else {
        isConnected = false;
      }
    });
  }

  void selectDate(Person person) {
    DateTime? selectedDate;

    if (person.dob != null) {
      // var convertedDate = DateTime.parse(formattedString)
      // if(checkDate
      if (!person.dob!.contains('-')) {
        var convertFormat = DateFormat('dd.MM.yyyy').parse(person.dob!);

        selectedDate = convertFormat;
      } else {
        selectedDate = DateTime.parse(person.dob!);
      }
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          // var jiffy = Jiffy()..subtract(years: 64);
          DateTime initdate = DateTime.now().subtract(const Duration(days: 1));
          initdate = DateTime(
              initdate.year, initdate.month, initdate.day, 0, 0, 0, 0, 0);
          DateTime maxdate = DateTime.now().subtract(const Duration(days: 1));
          maxdate =
              DateTime(maxdate.year, maxdate.month, maxdate.day, 0, 0, 0, 0, 0);
          DateTime mindate =
              DateTime.now().subtract(const Duration(days: 36524));
          mindate =
              DateTime(mindate.year, mindate.month, mindate.day, 0, 0, 0, 0, 0);

          return SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: CupertinoDatePicker(
                  initialDateTime: selectedDate ?? initdate,
                  onDateTimeChanged: (DateTime newdate) {
                    setState(() {
                      person.dob = newdate.toString();
                      person.age = getAge(newdate);
                      person.isJuvenile = getAge(newdate) < 16;

                      if (qtnFor == QuotationFor.existingCustomer) {
                        if (selectedBuyingFor == BuyingFor.self.toStr ||
                            selectedBuyingFor == BuyingFor.children.toStr) {
                          isPolicyOwner = false;
                        }
                      } else {
                        if (person.clientType == "2" &&
                            selectedBuyingFor == BuyingFor.children.toStr) {
                          isPolicyOwner = person.age! >= 16;
                        }
                      }
                    });
                  },
                  minimumDate: mindate,
                  maximumDate: maxdate,
                  minuteInterval: 1,
                  mode: CupertinoDatePickerMode.date));
        });
  }

  void selectOccupation(Person? person) async {
    try {
      final tmpOcc = await Navigator.of(context)
          .push(createRoute(ChooseOccupation(age: person!.age)));

      if (tmpOcc != null) {
        setState(() {
          if (qtnFor == QuotationFor.existingCustomer &&
              person.clientType == null) {
            existingOcc = tmpOcc;
          } else {
            person.occupation = tmpOcc;
          }
        });
      }

      if (qtnFor == QuotationFor.existingCustomer &&
          person.clientType == null &&
          existingOcc!.occupationCode !=
              selectedExistingCustomer!.occupation!.occupationCode) {
        if (!mounted) {}
        showAlertDialog(
            context,
            getLocale("Notice"),
            getLocale(
                "You have updated your occupation details. Please make sure you submit your policy services"));
      }
    } catch (e) {
      rethrow;
    }
  }

  void populateExistingCustomer() {
    if (qtnFor == QuotationFor.existingCustomer) {
      if (selectedExistingCustomer != null) {
        setState(() {
          existingOcc = selectedExistingCustomer!.occupation;
          existingIsSmoker = selectedExistingCustomer!.isSmoker;
          // selectedExistingCustomer.isJuvenile = selectedExistingCustomer.age;
        });
      }
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Future<Person> getExistingCoverage(Person person) async {
    final output = await getTemporaryDirectory();
    String path = "${output.path}/fffdetails.json";
    final file = File(path);

    await NewBusinessAPI().searchLead(person.nric).then((result) async {
      Person newPerson = person;
      if (result['IsSuccess'] && result['FFFDetails'] != null) {
        Uint8List bytes = base64.decode(result['FFFDetails']);
        await file.writeAsBytes(bytes);
        if (file.existsSync()) {
          String contents = await file.readAsString();
          final data = jsonDecode(contents);
          for (int i = 0; i < data.length; i++) {
            // if (_data[i]["CltId"] != null) {
            Person coverage = await Person.fromJsonFFF(data[i]);
            if (coverage.existingCoverage!.isNotEmpty) {
              newPerson.name = coverage.existingCoverage![0].name;
              newPerson.nric = coverage.existingCoverage![0].nric ??
                  coverage.existingCoverage![0].idnum;
              newPerson.dob = coverage.existingCoverage![0].dob;
              newPerson.gender = coverage.existingCoverage![0].gender;
              newPerson.nationality = coverage.existingCoverage![0].nationality;
              newPerson.maritalStatus =
                  coverage.existingCoverage![0].maritalStatus;

              newPerson.existingSavingInvestPlan =
                  coverage.existingSavingInvestPlan;
              newPerson.existingCoverage = coverage.existingCoverage;
              newPerson.existingMedicalPlan = coverage.existingMedicalPlan;
              newPerson.existingRetirement = coverage.existingRetirement;
              newPerson.existingChildEdu = coverage.existingChildEdu;
              newPerson.existingCoverageDisclosure =
                  coverage.existingCoverageDisclosure;
            }
            // }
          }
        }
      }
    });
    return person;
  }

  bool validate() {
    bool liCompleted;
    bool poCompleted;
    if (qtnFor == QuotationFor.existingCustomer) {
      selectedExistingCustomer!.occupation = existingOcc;
      selectedExistingCustomer!.isSmoker = existingIsSmoker;
      if (selectedBuyingFor == BuyingFor.self.toStr) {
        lifeInsured = selectedExistingCustomer;
        lifeInsured!.clientType = "3";
      } else {
        if (!isPolicyOwner) {
          policyOwner = selectedExistingCustomer;
          policyOwner!.clientType = "1";
        }
      }
    }

    liCompleted = lifeInsured!.gender != null &&
        lifeInsured!.dob != null &&
        lifeInsured!.occupation != null &&
        lifeInsured!.isSmoker != null;

    var validLIDOB = validateDOB(lifeInsured, selectedBuyingFor, isPolicyOwner);
    var validLIOcc =
        validateOcc(lifeInsured!.occupation, lifeInsured!.isJuvenile);
    liCompleted = liCompleted && validLIDOB["isValid"] && validLIOcc["isValid"];

    if (selectedBuyingFor == BuyingFor.self.toStr) {
      return liCompleted;
    } else {
      if (isPolicyOwner) {
        return liCompleted;
      } else {
        poCompleted = policyOwner!.gender != null &&
            policyOwner!.dob != null &&
            policyOwner!.occupation != null &&
            policyOwner!.isSmoker != null;

        var validPODOB =
            validateDOB(policyOwner, selectedBuyingFor, isPolicyOwner);
        var validPOOcc =
            validateOcc(policyOwner!.occupation, policyOwner!.isJuvenile);
        poCompleted =
            poCompleted && validPODOB["isValid"] && validPOOcc["isValid"];

        return liCompleted && poCompleted;
      }
    }
  }

  void validateAndSave() async {
    bool otherValidation = validate();
    bool notice = false;
    if (otherValidation) {
      if (selectedBuyingFor == BuyingFor.self.toStr &&
          lifeInsured!.age! > 10 &&
          lifeInsured!.age! < 16) {
        var result = await showAlertDialog3(
            context,
            getLocale("Notification"),
            getLocale(
                "Your application will require consent from your parent/guardian"));
        if (result != null && result) {
          notice = true;
        }
      } else {
        if (selectedBuyingFor == BuyingFor.spouse.toStr &&
            lifeInsured!.gender == policyOwner!.gender) {
          isLoading = false;
          showAlertDialog(
              context,
              "Notification",
              getLocale(
                  "Please check the policy owner and life insured gender info"));
        } else {
          notice = true;
        }
      }
    }
    if (notice &&
        _createNewQuoteKey.currentState!.validate() &&
        otherValidation) {
      if (qtnFor == QuotationFor.existingCustomer) {
        if (selectedBuyingFor == BuyingFor.self.toStr) {
          lifeInsured!.clientType = "3";
          policyOwner = lifeInsured;
        } else {
          lifeInsured!.name = _liNameCont.text;
          if (isPolicyOwner) {
            lifeInsured!.clientType = "3";
            selectedBuyingFor = BuyingFor.self.toStr;
            policyOwner = lifeInsured;
          } else {
            policyOwner!.clientType == "1";
          }
        }
      } else if (qtnFor == QuotationFor.newCustomer) {
        lifeInsured!.name = _liNameCont.text;
        if (selectedBuyingFor == BuyingFor.self.toStr) {
          lifeInsured!.clientType = "3";
          policyOwner = lifeInsured;
        } else {
          if (isPolicyOwner) {
            lifeInsured!.clientType = "3";
            selectedBuyingFor = BuyingFor.self.toStr;
            policyOwner = lifeInsured;
          } else {
            policyOwner!.name = _poNameCont.text;
          }
        }
      }
      if (lifeInsured!.dob!.contains("-")) {
        lifeInsured!.dob = DateFormat('dd.M.yyyy')
            .format(DateTime.parse(lifeInsured!.dob!))
            .toString();
      }
      if (policyOwner!.dob!.contains("-")) {
        policyOwner!.dob = DateFormat('dd.M.yyyy')
            .format(DateTime.parse(policyOwner!.dob!))
            .toString();
      }

      if (qtnReturned != null) {
        //If qntReturned != null = user press back button from choose product.
        //So we will just update the quotation.

        qtnReturned!.lifeInsured = lifeInsured;
        qtnReturned!.policyOwner = policyOwner;
        qtnReturned!.buyingFor = selectedBuyingFor;
        qtnReturned!.listOfQuotation?.clear();
        _qtnBloc.add(UpdateQuotation(qtnReturned));

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            isLoading = false;
          });
          if (qtnFor == QuotationFor.newCustomer) {
            Navigator.of(context)
                .push(
                    createRoute(ChooseProducts(qtnReturned!.id, qtnReturned!)))
                .then((data) {
              if (data != null) {
                setState(() {
                  qtnReturned = data['qtn'];
                  qtnReturned!.id = data['qtnid'];
                  if (selectedBuyingFor == BuyingFor.self.toStr) {
                    lifeInsured!.clientType = "2";
                    policyOwner = Person(clientType: "1");
                  }
                });
              }
            });
          } else if (qtnFor == QuotationFor.existingCustomer) {
            Navigator.of(context)
                .push(createRoute(ViewCoverage(qtnReturned!.id, qtnReturned)));
          }
        });
      } else {
        final pref = await SharedPreferences.getInstance();
        final Agent agent =
            Agent.fromJson(json.decode(pref.getString(spkAgent)!));

        Quotation qtn = Quotation(
            uid: generateQuickQuotationId(),
            buyingFor: selectedBuyingFor,
            agentCode: agent.accountCode,
            lifeInsured: lifeInsured,
            policyOwner: policyOwner);
        _qtnBloc.add(AddQuotation(qtn));
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isChildPolicyOwner() {
    if (lifeInsured!.age != null) {
      if (qtnFor == QuotationFor.newCustomer &&
          selectedBuyingFor == BuyingFor.children.toStr) {
        return lifeInsured!.age! >= 10;
      }
    }
    return false;
  }

  bool showPolicyOwner() {
    if (selectedBuyingFor == BuyingFor.self.toStr) {
      return false;
    } else {
      if (selectedBuyingFor == BuyingFor.children.toStr &&
          lifeInsured!.age != null) {
        if (lifeInsured!.age! < 10) {
          return true;
        } else if (lifeInsured!.age! < 16) {
          return !isPolicyOwner;
        } else {
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget quotationForPicker() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("I'm creating a new quotation for a"), style: bFontWN()),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      qtnFor = QuotationFor.newCustomer;
                    });
                    analyticsSendEvent("quote_for_new_customer",
                        {"button_name": "New Customer"});
                  },
                  child: Container(
                      height: textFieldHeight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              width: qtnFor == QuotationFor.newCustomer ? 2 : 1,
                              color: qtnFor == QuotationFor.newCustomer
                                  ? cyanColor
                                  : Colors.grey[400]!)),
                      child: Center(
                          child: Text(getLocale("New Customer"),
                              style: textFieldStyle().copyWith(
                                  color: qtnFor == QuotationFor.newCustomer
                                      ? cyanColor
                                      : Colors.grey[500])))))),
          const SizedBox(width: 20),
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    if (isConnected) {
                      setState(() {
                        qtnFor = QuotationFor.existingCustomer;
                      });
                      analyticsSendEvent("quote_for_existing_customer",
                          {"button_name": "Existing Customer"});
                    }
                  },
                  child: Container(
                      height: textFieldHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: isConnected ? Colors.white : Colors.grey[200],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              width: qtnFor == QuotationFor.existingCustomer
                                  ? 2
                                  : 1,
                              color: qtnFor == QuotationFor.existingCustomer
                                  ? cyanColor
                                  : Colors.grey[400]!)),
                      child: Stack(children: [
                        Opacity(
                            opacity: isConnected ? 1 : 0.5,
                            child: Align(
                                alignment: Alignment.center,
                                child: Center(
                                    child: Text(getLocale("Existing Customer"),
                                        style: textFieldStyle().copyWith(
                                            color: qtnFor ==
                                                    QuotationFor
                                                        .existingCustomer
                                                ? cyanColor
                                                : Colors.grey[500]))))),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Visibility(
                                visible: !isConnected,
                                child: Text(
                                    getLocale("* Require Internet Connection"),
                                    textAlign: TextAlign.center,
                                    style: bFontWB()
                                        .copyWith(color: scarletRedColor))))
                      ]))))
        ])
      ]);
    }

    Widget buyingForDropdown() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("He/she is buying for"), style: bFontWN()),
            const SizedBox(height: 10),
            Container(
                height: textFieldHeight,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: textFieldBoxDecoration(),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: selectedBuyingFor,
                        style: bFontWN(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: buyingFor,
                        onChanged: (dynamic value) {
                          setState(() {
                            selectedBuyingFor = value;
                          });
                        })))
          ]));
    }

    Widget clientDetails(Person person) {
      String? label;
      if (person.clientType == "1") {
        label = getLocale("Policy Owner", entity: true);
      } else if (person.clientType == "2") {
        label = getLocale("Life Insured", entity: true);
      }

      if (selectedBuyingFor == BuyingFor.self.toStr ||
          person.clientType == "3") {
        label =
            "${getLocale("Special Translation 1 for Details")} ${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)} ${getLocale("Special Translation 2 for Details")}";
      } else {
        if (selectedBuyingFor == BuyingFor.children.toStr &&
            person.clientType == "1") {
          label = "${getLocale("Parent")}/${label!} ${getLocale("Details")}";
        } else {
          label =
              //"${selectedBuyingFor![0].toUpperCase()}${selectedBuyingFor!.substring(1)}/ ${label!}${getLocale("Details")}";
              "${getLocale("Special Translation 1 for Details")} ${getLocale(selectedBuyingFor!)}/${label!} ${getLocale("Special Translation 2 for Details")}";
        }
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Image(
                      width: 30,
                      height: 30,
                      image: AssetImage('assets/images/user_icon2.png'))),
              Text(label, style: t1FontW5())
            ])),
        name(person.clientType == "1" ? _poNameCont : _liNameCont),
        gender(masterLookup, person.gender, (value) {
          setState(() {
            person.gender = value;
          });
        }),
        dob(person, selectedBuyingFor, isPolicyOwner, () {
          selectDate(person);
        }),
        occupation(person.occupation, person.isJuvenile, () {
          selectOccupation(person);
        }),
        smoking(person.isSmoker, (value) {
          setState(() {
            person.isSmoker = value;
          });
        })
      ]);
    }

    Widget isPOSwitch() {
      return Visibility(
          visible: isChildPolicyOwner(),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(
                        "${getLocale("Do you want your child to be the")} ${getLocale("Policy Owner", entity: true)} ${getLocale("of the application?")}",
                        style: bFontWN())),
                CupertinoSwitch(
                    value: isPolicyOwner,
                    onChanged: (bool value) {
                      setState(() {
                        isPolicyOwner = value;
                        if (isPolicyOwner &&
                            lifeInsured!.age! > 10 &&
                            lifeInsured!.age! < 16) {
                          showAlertDialog(
                              context,
                              getLocale("Notification"),
                              getLocale(
                                  "Your application will require consent from your parent/legal guardian"));
                        } else if (!isPolicyOwner && lifeInsured!.age! >= 16) {
                          showAlertDialog(context, getLocale("Notification"),
                              "${getLocale("Please submit the application with you as the")} ${getLocale("Policy Owner", entity: true)}");
                        }
                      });
                    })
              ])));
    }

    Widget newCustomer() {
      return Column(children: [
        buyingForDropdown(),
        clientDetails(lifeInsured!),
        isPOSwitch(),
        const SizedBox(height: 40),
        showPolicyOwner() ? clientDetails(policyOwner!) : Container()
      ]);
    }

    Widget searchCustomer() {
      return Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Search customer"), style: t1FontW5()),
            const SizedBox(height: 16),
            TextFormField(
                controller: searchCustomerCont,
                onFieldSubmitted: (value) {
                  setState(() {
                    _searchCustomerKeyword = value;
                    if (_searchCustomerKeyword!.length > 2) {
                      BlocProvider.of<ExistingCustomerBloc>(context)
                          .add(SearchExistingCustomer(_searchCustomerKeyword));
                    }
                  });
                },
                keyboardType: TextInputType.text,
                cursorColor: Colors.grey,
                textCapitalization: TextCapitalization.words,
                style: textFieldStyle(),
                decoration: textFieldInputDecoration().copyWith(
                    suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        child: CircleAvatar(
                            radius: 24,
                            backgroundColor: honeyColor,
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _searchCustomerKeyword =
                                        searchCustomerCont.text;
                                    if (_searchCustomerKeyword!.length > 2) {
                                      BlocProvider.of<ExistingCustomerBloc>(
                                              context)
                                          .add(SearchExistingCustomer(
                                              _searchCustomerKeyword));
                                    }
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                                icon: const Icon(Icons.search)))),
                    hintText: getLocale("Search by customer name / NRIC no."))),
            Visibility(
                visible: _searchCustomerKeyword != null &&
                    _searchCustomerKeyword!.length < 3,
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                        getLocale("* Please enter more than 3 characters"),
                        style: ssFontWN().copyWith(color: scarletRedColor))))
          ]));
    }

    Widget listOfCustomer(Person person) {
      return GestureDetector(
          onTap: () async {
            if (person.existingCoverage!.isEmpty) {
              Person updated = await getExistingCoverage(person);
              setState(() {
                selectedExistingCustomer = updated;
              });
            } else {
              setState(() {
                selectedExistingCustomer = person;
              });
            }
            populateExistingCustomer();
          },
          child: Container(
              decoration: BoxDecoration(
                  color: (selectedExistingCustomer != null &&
                          selectedExistingCustomer == person)
                      ? creamColor
                      : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 60,
              child: Row(children: [
                CircleAvatar(
                    backgroundColor: lightCyanColor,
                    child: Text(person.name![0],
                        style: t1FontW5().copyWith(color: cyanColor))),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(person.name!, style: t2FontW5()))),
                Text(person.nric!, style: t2FontW5())
              ])));
    }

    Widget customerNameFound() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(getLocale("Customer Name found"), style: bFontWN()),
                BlocBuilder<ExistingCustomerBloc, ExistingCustomerListState>(
                    builder: (context, state) {
                  if (state is ExistingCustomerListInitial) {
                    return buildLoading();
                  } else if (state is ExistingCustomerListLoading) {
                    return buildLoading();
                  } else if (state is ExistingCustomerListLoaded) {
                    return Column(children: [
                      for (var i = 0; i < state.personList.length; i++)
                        listOfCustomer(state.personList[i])
                    ]);
                  } else {
                    selectedExistingCustomer = null;
                    return Container(
                        decoration: BoxDecoration(
                            color: lightPinkColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        margin: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close, color: Colors.red)),
                              Expanded(
                                  child: Text(getLocale("No Customer found"),
                                      style: bFontWN()
                                          .copyWith(color: scarletRedColor)))
                            ]));
                  }
                })
              ]));
    }

    Widget existingCustomerDetails() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Text(
                getLocale(
                    "Do let us know if customer have changes at following data"),
                style: bFontWN())),
        occupation(existingOcc, selectedExistingCustomer!.isJuvenile, () {
          selectOccupation(selectedExistingCustomer);
        }),
        smoking(existingIsSmoker, (value) {
          setState(() {
            existingIsSmoker = value;
          });
          if (existingIsSmoker != selectedExistingCustomer!.isSmoker) {
            showAlertDialog(
                context,
                getLocale("Notice"),
                getLocale(
                    "You have updated your smoking details. Please make sure you submit your policy services"));
          }
        })
      ]);
    }

    Widget existingCustomer() {
      return Column(children: [
        searchCustomer(),
        Visibility(
            visible: _searchCustomerKeyword != null &&
                _searchCustomerKeyword!.length > 2,
            child: customerNameFound()),
        Visibility(
            visible: selectedExistingCustomer != null &&
                selectedExistingCustomer!.nric != null,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              buyingForDropdown(),
              selectedExistingCustomer != null &&
                      selectedExistingCustomer!.nric != null
                  ? existingCustomerDetails()
                  : Container(),
              selectedBuyingFor != BuyingFor.self.toStr
                  ? clientDetails(lifeInsured!)
                  : Container(),
              Visibility(
                  visible: selectedBuyingFor == BuyingFor.spouse.toStr,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                                "Is ${getLocale("Policy Owner", entity: true)}",
                                style: bFontWN())),
                        Expanded(
                            flex: 5,
                            child: Row(children: [
                              CupertinoSwitch(
                                  value: isPolicyOwner,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isPolicyOwner = value;
                                    });
                                  })
                            ]))
                      ])))
            ]))
      ]);
    }

    Widget submitForm() {
      return BlocListener<QuotationBloc, QuotationBlocState>(
          listener: (context, blocState) {
            int? id = 0;

            if (blocState is QuotationAdded) {
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  isLoading = false;
                });
                if (qtnFor == QuotationFor.newCustomer) {
                  id = blocState.qtnId;
                  Navigator.of(context)
                      .push(
                          createRoute(ChooseProducts(id, blocState.quotation)))
                      .then((data) {
                    if (data != null) {
                      setState(() {
                        qtnReturned = data['qtn'];
                        qtnReturned!.id = data['qtnid'];
                        if (selectedBuyingFor == BuyingFor.self.toStr) {
                          lifeInsured!.clientType = "2";
                          policyOwner = Person(clientType: "1");
                        }
                      });
                    }
                  });
                } else if (qtnFor == QuotationFor.existingCustomer) {
                  Navigator.of(context).push(createRoute(
                      ViewCoverage(blocState.qtnId, blocState.quotation)));
                }
              });
            }
            if (blocState is QuotationSingle) {
              //If quotation single, this mean user press return button from choose product
              //So bloc will return the quotation that is already generated, to be updated.

              qtnReturned = blocState.quotation;
            }
          },
          child: Container(
              decoration: textFieldBoxDecoration().copyWith(
                  color: honeyColor, border: Border.all(color: honeyColor)),
              height: 70,
              margin: const EdgeInsets.only(
                  left: 45, right: 45, top: 56, bottom: 25),
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                  // padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  onPressed: () {
                    if (isLoading != true) {
                      //Disable button if button has already been pressed
                      analyticsSendEvent("submit_quotation",
                          {"button_name": "${getLocale("Next")} >"});
                      setState(() {
                        isLoading = true;
                      });
                      validateAndSave();
                    }
                  },
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.scale(
                            scale: 0.8,
                            child: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.adaptive.arrow_back))),
                        isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black))
                            : Row(children: [
                                Text(getLocale("Next"), style: t2FontW5()),
                                Transform.scale(
                                    scale: 0.8,
                                    child: Icon(Icons.adaptive.arrow_forward,
                                        color: Colors.black))
                              ])
                      ]))));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          progressBar(context, 6, 1 / 4),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.adaptive.arrow_back)),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, size: 40))
                  ])),
          Expanded(
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 45),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Column(children: [
                              header(),
                              const SizedBox(height: 30),
                              quotationForPicker(),
                              BlocBuilder<MasterLookupBloc, MasterLookupState>(
                                  builder: (context, state) {
                                if (state is MasterLookupLoaded) {
                                  masterLookup = state.masterLookupList;

                                  if (masterLookup.isEmpty) {
                                    BlocProvider.of<MasterLookupBloc>(context)
                                        .add(const GetMasterLookUpList());
                                  }

                                  return Column(children: [
                                    AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 700),
                                        child: masterLookup.isNotEmpty
                                            ? Form(
                                                key: _createNewQuoteKey,
                                                child: qtnFor ==
                                                        QuotationFor.newCustomer
                                                    ? newCustomer()
                                                    : existingCustomer())
                                            : buildLoading())
                                  ]);
                                } else {
                                  return AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 700),
                                      child: state is MasterLookupInitial
                                          ? buildLoading()
                                          : state is MasterLookupError
                                              ? buildError(
                                                  context, state.message)
                                              : SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.6,
                                                  child: buildLoading()));
                                }
                              })
                            ])),
                        BlocBuilder<MasterLookupBloc, MasterLookupState>(
                            builder: (context, state) {
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 700),
                              child: state is MasterLookupLoaded
                                  ? Visibility(
                                      visible: qtnFor ==
                                              QuotationFor.newCustomer ||
                                          (qtnFor ==
                                                  QuotationFor
                                                      .existingCustomer &&
                                              selectedExistingCustomer !=
                                                  null &&
                                              selectedExistingCustomer!.nric !=
                                                  null),
                                      child: submitForm())
                                  : Container());
                        })
                      ])))
        ]));
  }
}
