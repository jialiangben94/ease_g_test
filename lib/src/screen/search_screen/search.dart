// import 'package:ease/src/widgets/main_widget.dart';
// import 'package:flutter/material.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   SearchScreenState createState() => SearchScreenState();
// }

// class SearchScreenState extends State<SearchScreen> {
//   @override
//   Widget build(BuildContext context) {
//     void searchData() {}

//     return Scaffold(
//         body: Container(
//             child: SingleChildScrollView(
//                 physics: NeverScrollableScrollPhysics(),
//                 child: Column(children: [
//                   progressBar(context, 6, 1),
//                   SizedBox(height: 20),
//                   Container(
//                       height: 60,
//                       child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Expanded(
//                                 flex: 1,
//                                 child: IconButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                     icon: Icon(Icons.adaptive.arrow_back_ios,
//                                         color: Colors.black, size: 18))),
//                             Expanded(
//                                 flex: 15,
//                                 child: Container(
//                                     child: Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10.0,
//                                             top: 0,
//                                             bottom: 5,
//                                             right: 40),
//                                         child: TextField(
//                                             textInputAction:
//                                                 TextInputAction.next,
//                                             textCapitalization:
//                                                 TextCapitalization.words,
//                                             onChanged: (value) {},
//                                             cursorColor: Colors.grey,
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontFamily: "Meta",
//                                                 fontSize: 20),
//                                             decoration: InputDecoration(
//                                                 hintText:
//                                                     'Search by Customer Name or D.O.B',
//                                                 hintStyle: TextStyle(
//                                                     color: Colors.grey[400],
//                                                     fontSize: 16),
//                                                 suffixIcon: IconButton(
//                                                     icon: Icon(Icons.adaptive.search,
//                                                         size: 30,
//                                                         color: Colors.grey),
//                                                     onPressed: () {
//                                                       searchData();
//                                                     }),
//                                                 focusedBorder: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.all(
//                                                         Radius.circular(10)),
//                                                     borderSide: BorderSide(
//                                                         color: Colors.grey[500]!,
//                                                         width: 0.5)),
//                                                 border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.all(
//                                                             Radius.circular(
//                                                                 10)),
//                                                     borderSide: BorderSide(
//                                                         color: Colors.grey[400]!,
//                                                         width: 0.5)))))))
//                           ])),
//                   SizedBox(height: 5),
//                   Divider(),
//                   SizedBox(height: 5)
//                 ]))));
//   }
// }
