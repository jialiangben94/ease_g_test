import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/loading.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/directory.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:signature/signature.dart';
import 'package:path/path.dart' show join;

class SignatureContainer extends StatefulWidget {
  final String label;
  final Function(String?) callback;
  final String? image;
  
  const SignatureContainer(
      {Key? key, required this.label, required this.callback, this.image})
      : super(key: key);

  @override
  SignatureContainerState createState() => SignatureContainerState();
}

class SignatureContainerState extends State<SignatureContainer> {
  final SignatureController _controller =
      SignatureController(penStrokeWidth: 5, penColor: Colors.black);
  Uint8List? imageByte;
  bool imageLoading = false;
  String? path;
  String? image;
  Timer? timer;  

  @override
  void initState() {
    super.initState();
    image = widget.image;
    // _controller.addListener(() => print("Value changed"));
    getGlobalImageSavePath().then((status) {
      if (status != null && status["path"] != null) {
        path = status["path"];
        if (image != null && image != "") {
          checkImage(image, path).then((status) {
            if (status != null && status["data"] != null) {
              imageByte = status["data"];
            }
            imageLoading = false;
            setState(() {});
          }).catchError((err) {
            imageLoading = false;
            setState(() {});
          });
        } else {
          imageLoading = false;
          setState(() {});
        }
      }
    });    
  }  

  @override
  Widget build(BuildContext context) {
    Widget clearButton() {
      return CustomButton(
          label: getLocale("Clear"),
          secondary: true,
          onPressed: () {
            _controller.clear();
          });
    }

    Widget saveButton() {
      return CustomButton(
          label: getLocale("Save"),
          onPressed: () async {
            var fileName = DateTime.now().toString();
            List<int>? data;
            if (_controller.isNotEmpty) {
              data = await _controller.toPngBytes();
              img.Image image = img.decodeImage(data!)!;
              data = img.encodePng(image);

              List<int> byte = generateImageByte(data);

              await File(join(path!, fileName)).writeAsBytes(byte);
            }
            if (image != null && image != "") {
              final previousImage = File(join(path!, image));
              if (previousImage.existsSync()) {
                await previousImage.delete();
              }
            }
            image = data != null ? fileName : null;
            setState(() {
              imageByte = data as Uint8List?;
            });
            if (!mounted) {}
            timer?.cancel();
            Navigator.of(context).pop();
            widget.callback(image);
          });
    }

    Widget signContainer(Widget child) {
      Widget wid;
      if (child is Signature) {
        wid = child;
      } else if (imageLoading) {
        wid = containerLoading();
      } else if (imageByte != null) {
        wid = Image.memory(imageByte!);
      } else {
        wid = child;
      }

      return Container(
          // constraints: BoxConstraints(
          //     minHeight: gFontSize * 10, minWidth: gFontSize * 10),
          decoration: BoxDecoration(
              border: Border.all(color: lightCyanColor, width: gFontSize * 0.3),
              borderRadius: BorderRadius.circular(gFontSize * 0.5)),
          child: Center(child: wid));
    }

    void show() {          

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {          
          
          bool isReady = false;
              
          return StatefulBuilder(
            builder: (context, setState) {      
                           
              timer = Timer(Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    isReady = true;
                  });
                }                
              });                                         

              return SystemPadding(
                child: Center(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: screenHeight * 0.38),
                        child: SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.9,
                            child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(gFontSize * 0.5))),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 2,
                                    vertical: gFontSize * 0.5),
                                title: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: gFontSize * 0.7,
                                        vertical: gFontSize * 0.5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "${getLocale("Signature")}${widget.label != "" ? " - ${widget.label}" : ""}",
                                              style: t1FontWN()),
                                          InkWell(
                                              onTap: () {
                                                timer?.cancel();
                                                Navigator.of(context).pop();
                                              },
                                              child: Icon(Icons.close,
                                                  size: gFontSize * 2))
                                        ])),
                                content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: signContainer(Signature(
                                        controller: _controller,
                                        height: screenHeight * 0.6,
                                        width: screenWidth * 0.65,
                                        backgroundColor: Colors.transparent,
                                      ))),
                                      Stack(
                                        children: [
                                          Container(
                                              width: screenWidth,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: gFontSize),
                                              child: Row(children: [
                                                Expanded(child: clearButton()),
                                                Container(width: gFontSize * 0.5),
                                                Expanded(child: saveButton())
                                              ])),
                                              isReady && _controller.isNotEmpty 
                                              ?
                                              SizedBox()
                                              :
                                              Positioned.fill(
                                                child: Container(
                                                  color: const Color.fromRGBO(255, 255, 255, 0.5))
                                              )
                                        ],
                                      )
              ]))))));
            },
          );
        },
      );      
    }

    return InkWell(
        onTap: () {
          show();
        },
        child: signContainer(Text(getLocale("Sign here"))));
  }
}