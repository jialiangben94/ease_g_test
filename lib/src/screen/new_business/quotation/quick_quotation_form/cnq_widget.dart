part of 'create_new_quote.dart';

Widget header() {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getLocale("Create New Quote"),
                  style: sFontWN().copyWith(color: greyTextColor)),
              Row(children: [
                Text(getLocale("Customer's Details"),
                    style: tFontW5().copyWith(fontSize: 30))
              ]),
              Text(
                  getLocale(
                      "Let's get started by filling in the details below."),
                  style: sFontWN().copyWith(color: greyTextColor))
            ]))
      ]));
}

Widget name(TextEditingController nameCont) {
  dynamic validName = validateName(nameCont.text);
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            flex: 4, child: Text(getLocale("Full Name"), style: bFontWN())),
        Expanded(
            flex: 10,
            child: TextFormField(
                controller: nameCont,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('  +')),
                ],
                validator: (value) {
                  dynamic validName = validateName(nameCont.text);
                  if (validName != null) {
                    return "* $validName";
                  } else {
                    return null;
                  }
                },
                cursorColor: Colors.grey,
                textCapitalization: TextCapitalization.words,
                style: textFieldStyle(),
                decoration: textFieldInputDecoration().copyWith(
                    errorText: validName != null ? "* $validName" : null,
                    errorStyle: ssFontWN().copyWith(color: scarletRedColor))))
      ]));
}

Widget errorMessage(bool valid, String errorMsg) {
  return Visibility(
      visible: valid,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 4, child: Container()),
        Expanded(
            flex: 10,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text("* $errorMsg",
                    style: ssFontWN().copyWith(color: scarletRedColor))))
      ]));
}

Widget gender(List<MasterLookup> masterLookup, String? selectedGender, ontap) {
  List<MasterLookup> listOfGender = [];
  for (var element in masterLookup) {
    if (element.typeId == 3) {
      listOfGender.add(element);
    }
  }

  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 4, child: Text(getLocale("Gender"), style: bFontWN())),
          Expanded(
              flex: 10,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                for (int x = 0; x < listOfGender.length; x++)
                  Expanded(
                      child: GestureDetector(
                          onTap: () {
                            ontap(listOfGender[x].name);
                          },
                          child: Container(
                              height: commonTextFieldHeight,
                              margin: EdgeInsets.only(right: x == 0 ? 20 : 0),
                              decoration: textFieldBoxDecoration().copyWith(
                                  border: Border.all(
                                      width:
                                          selectedGender == listOfGender[x].name
                                              ? 2
                                              : 1,
                                      color:
                                          selectedGender == listOfGender[x].name
                                              ? cyanColor
                                              : greyBorderTFColor)),
                              child: Center(
                                  child: Text(listOfGender[x].name!,
                                      style: textFieldStyle().copyWith(
                                          color: selectedGender ==
                                                  listOfGender[x].name
                                              ? cyanColor
                                              : Colors.black))))))
              ]))
        ]),
        errorMessage(
            selectedGender == null, getLocale("Please choose one gender"))
      ]));
}

dynamic validateDOB(
    Person? person, String? selectedBuyingFor, bool isPolicyOwner) {
  var validDOB = {"isValid": true, "message": ""};
  if (person != null && person.age != null) {
    if (person.age! > 98) {
      validDOB["isValid"] = false;
      validDOB["message"] =
          getLocale("Maximum entry age is 99 age next birthday");
    } else {
      if (selectedBuyingFor == BuyingFor.self.toStr) {
        if (person.clientType == "2") {
          if (person.age! < 10) {
            validDOB["isValid"] = false;
            validDOB["message"] =
                "${getLocale("A")} ${getLocale("Policy Owner", entity: true)} ${getLocale("is required for this application as you have not attained the age of 10")}";
          }
        }
      } else {
        if (person.clientType == "1") {
          if (person.age! < 16) {
            validDOB["isValid"] = false;
            validDOB["message"] =
                "${getLocale("A")} ${getLocale("Policy Owner", entity: true)} ${getLocale("must be at least 17 age next birthday")}";
          }
        } else {
          if (selectedBuyingFor == BuyingFor.children.toStr) {
            DateTime dob;
            if (person.dob!.contains("-")) {
              dob = DateTime.parse(person.dob!);
            } else {
              dob = DateFormat('dd.M.yyyy').parse(person.dob!);
            }
            int dayage = getAgeInDays(dob);
            if (person.age! > 16 && !isPolicyOwner) {
              validDOB["isValid"] = false;
              validDOB["message"] =
                  "${getLocale("Please submit the application with you as the")} ${getLocale("Policy Owner", entity: true)}";
            } else if (dayage < 14) {
              validDOB["isValid"] = false;
              validDOB["message"] =
                  getLocale("Minimum entry age is 14 days old");
            }
          } else {
            if (person.age! < 16) {
              validDOB["isValid"] = false;
              validDOB["message"] =
                  "${getLocale("A")} ${getLocale("Life Insured", entity: true)} ${getLocale("must be at least 17 age next birthday")}";
            }
          }
        }
      }
    }
  } else {
    validDOB["isValid"] = false;
    validDOB["message"] = getLocale("Please enter your date of birth");
  }
  return validDOB;
}

Widget dob(
    Person person, String? selectedBuyingFor, bool isPolicyOwner, ontap) {
  DateTime? dob;
  int age = 0;
  dynamic validDOB = validateDOB(person, selectedBuyingFor, isPolicyOwner);
  if (person.dob != null) {
    if (person.dob!.contains("-")) {
      dob = DateTime.parse(person.dob!);
    } else {
      dob = DateFormat('dd.M.yyyy').parse(person.dob!);
    }
    age = person.age! + 1;
  }

  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              flex: 4,
              child: Text(getLocale("Date of Birth"), style: bFontWN())),
          Expanded(
              flex: 10,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: ontap,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: greyBorderTFColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Text(
                                    dob != null
                                        ? DateFormat("dd")
                                            .format(dob)
                                            .toString()
                                        : "",
                                    style: bFontW5())))),
                    const SizedBox(width: 20),
                    Expanded(
                        child: GestureDetector(
                            onTap: ontap,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: greyBorderTFColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Text(
                                    dob != null
                                        ? DateFormat("MM")
                                            .format(dob)
                                            .toString()
                                        : "",
                                    style: bFontW5())))),
                    const SizedBox(width: 20),
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: ontap,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: greyBorderTFColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Text(
                                    dob != null
                                        ? DateFormat("y").format(dob).toString()
                                        : "",
                                    style: bFontW5())))),
                    const SizedBox(width: 20),
                    Expanded(
                        child:
                            Text("${getLocale("ANB")}: $age", style: bFontWN()))
                  ]))
        ]),
        errorMessage(!validDOB["isValid"], validDOB["message"])
      ]));
}

dynamic validateOcc(Occupation? occupation, bool? isJuvenile) {
  var validOcc = {"isValid": true, "message": ""};
  if (occupation != null) {
    if (occupation.occupationCode == "JUV001" &&
        isJuvenile != null &&
        !isJuvenile) {
      validOcc["isValid"] = false;
      validOcc["message"] = getLocale(
          "Invalid age range for selected occupation. Please choose different occupation");
    }
  } else {
    validOcc["isValid"] = false;
    validOcc["message"] = getLocale("Please choose one occupation");
  }
  return validOcc;
}

Widget occupation(Occupation? selectedOcc, isJuvenile, ontap,
    {bool? updateOcc}) {
  dynamic validOcc = validateOcc(selectedOcc, isJuvenile);

  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              flex: 4, child: Text(getLocale("Occupation"), style: bFontWN())),
          Expanded(
              flex: 10,
              child: GestureDetector(
                  onTap: () {
                    ontap();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: commonTextFieldHeight,
                      decoration: textFieldBoxDecoration().copyWith(
                          border: Border.all(color: greyBorderTFColor)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                selectedOcc != null
                                    ? selectedOcc.occupationName!
                                    : getLocale("No occupation selected"),
                                style: textFieldStyle().copyWith(
                                    color: selectedOcc != null
                                        ? Colors.black
                                        : Colors.grey)),
                            const Icon(Icons.keyboard_arrow_down)
                          ]))))
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 4, child: Container()),
          Expanded(
              flex: 10,
              child: Visibility(
                  visible: updateOcc ?? false,
                  child: errorMessage(
                      updateOcc ?? false,
                      getLocale(
                          "*Make sure you update customer latest occupation for more accurate classification"))))
        ]),
        errorMessage(!validOcc["isValid"], validOcc["message"])
      ]));
}

Widget smoking(bool? smoking, ontap) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              flex: 4, child: Text(getLocale("Smoking"), style: bFontWN())),
          Expanded(
              flex: 10,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          ontap(true);
                        },
                        child: Container(
                            height: commonTextFieldHeight,
                            decoration: textFieldBoxDecoration().copyWith(
                                border: Border.all(
                                    width: smoking != null && smoking ? 2 : 1,
                                    color: smoking != null && smoking
                                        ? cyanColor
                                        : greyBorderTFColor)),
                            child: Center(
                                child: Text(getLocale("Yes"),
                                    style: textFieldStyle().copyWith(
                                        color: smoking != null && smoking
                                            ? cyanColor
                                            : Colors.black)))))),
                const SizedBox(width: 20),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          ontap(false);
                        },
                        child: Container(
                            height: commonTextFieldHeight,
                            decoration: textFieldBoxDecoration().copyWith(
                                border: Border.all(
                                    width: smoking != null && !smoking ? 2 : 1,
                                    color: smoking != null && !smoking
                                        ? cyanColor
                                        : greyBorderTFColor)),
                            child: Center(
                                child: Text(getLocale("No"),
                                    style: textFieldStyle().copyWith(
                                        color: smoking != null && !smoking
                                            ? cyanColor
                                            : Colors.black))))))
              ]))
        ]),
        errorMessage(smoking == null, getLocale("Please choose one"))
      ]));
}
