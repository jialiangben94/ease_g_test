import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class AgentDetails extends StatefulWidget {
  final Agent agent;
  const AgentDetails(this.agent, {Key? key}) : super(key: key);
  @override
  AgentDetailsState createState() => AgentDetailsState();
}

class AgentDetailsState extends State<AgentDetails> {
  TextEditingController contactNo = TextEditingController();
  TextEditingController homeAddressOne = TextEditingController();
  TextEditingController homeAddressTwo = TextEditingController();
  TextEditingController homeAddressThree = TextEditingController();
  TextEditingController officeAddressOne = TextEditingController();
  TextEditingController officeAddressTwo = TextEditingController();
  TextEditingController officeAddressThree = TextEditingController();

  int x = 0;

  late Agent agents;
  var phone = "";

  bool? editcontactNo;
  bool? isContactLoading;
  bool? isAddressLoading;
  bool? editaddress;
  bool? editOfficeAddress;

  @override
  void initState() {
    super.initState();
    agents = widget.agent;
    contactNo.text = widget.agent.mobilePhone!;
    isContactLoading = false;
    isAddressLoading = false;
    editcontactNo = false;
    editaddress = false;
    editOfficeAddress = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  BoxDecoration textFieldBoxDecoration() {
    return BoxDecoration(
        border: Border.all(color: greyBorderTFColor),
        borderRadius: const BorderRadius.all(Radius.circular(5)));
  }

  InputDecoration textFieldInputDecoration() {
    return InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: greyBorderTFColor, width: 1.0)));
  }

  Widget singleRow(String title, String desc) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(flex: 1, child: Text(title, style: bFontWN())),
          Expanded(flex: 2, child: Text(desc, style: bFontWN()))
        ]));
  }

  Column rowaddress(List<Address> address) {
    // Sort office address first
    address.sort((a, b) =>
        int.parse(b.addressType!).compareTo(int.parse(a.addressType!)));
    return Column(
      children: address.map((data) {
        if (data.addressType == "1") {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 1,
                    child: Text(
                        data.addressType == "1"
                            ? getLocale("Home Address")
                            : getLocale("Office Address"),
                        style: bFontWN())),
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("${data.adr1},", style: bFontWN())),
                          Visibility(
                              visible: (data.adr2 != null && data.adr2 != ""),
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child:
                                      Text("${data.adr2},", style: bFontWN()))),
                          Visibility(
                              visible: (data.adr3 != null && data.adr3 != ""),
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child:
                                      Text("${data.adr3},", style: bFontWN()))),
                          Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child:
                                  Text("${data.postcode},", style: bFontWN())),
                          Visibility(
                              visible: (data.city != null && data.city != ""),
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child:
                                      Text("${data.city},", style: bFontWN()))),
                          Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("${data.state},", style: bFontWN())),
                          Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("${data.country}", style: bFontWN()))
                        ]))
              ]));
        } else {
          return Container();
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? branchName = "";
    String? emailAddress = "";
    String? gadName = "";
    if (agents.branchName != null) branchName = agents.branchName;
    if (agents.emailAddress != null) emailAddress = agents.emailAddress;

    int i = 0;
    while (i < agents.managers!.length) {
      if (agents.managers![i].fullName != agents.fullName) {
        gadName = agents.managers![i].fullName;
        i = agents.managers!.length;
      } else {
        i++;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      singleRow(getLocale("Agent's Code"), agents.accountCode!),
      Visibility(
          visible: agents.branchName != null,
          child: singleRow(getLocale("Branch/Region"), branchName!)),
      singleRow(getLocale("Mobile No."), agents.mobilePhone!),
      Visibility(
          visible: (agents.emailAddress != null),
          child: singleRow(getLocale("Email Address"), emailAddress!)),
      rowaddress(agents.userAddress!),
      Visibility(
          visible: gadName != "",
          child: singleRow(getLocale("GAD Name"), gadName!))
    ]);
  }
}
