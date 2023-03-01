import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/full_screen_camera.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/util/directory.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' show join;

class CameraContainer extends StatefulWidget {
  final String label;
  final Function(String filename) callback;
  final String? image;
  const CameraContainer(
      {Key? key, required this.label, required this.callback, this.image})
      : super(key: key);
  @override
  CameraContainerState createState() => CameraContainerState();
}

class CameraContainerState extends State<CameraContainer> {
  Uint8List? imageByte;
  bool imageLoading = false;
  String? path;
  String? image;

  @override
  void initState() {
    super.initState();
    image = widget.image;
    imageLoading = true;
    initImage();
  }

  void initImage() {
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
    Widget emptyImageView(label) {
      Widget child = Text(label, style: bFontWN().copyWith(color: cyanColor));
      if (imageLoading) {
        child = containerLoading();
      }

      return Container(
          decoration: BoxDecoration(
              color: lightGreyColor2,
              border: Border.all(color: greyTextColor, width: gFontSize * 0.1),
              borderRadius: BorderRadius.circular(gFontSize * 0.5)),
          child: Center(child: child));
    }

    Widget imageView() {
      return Container(
          decoration: BoxDecoration(
              color: lightGreyColor2,
              border: Border.all(color: greyTextColor, width: gFontSize * 0.1),
              borderRadius: BorderRadius.circular(gFontSize * 0.5)),
          child: Center(child: Image.memory(imageByte!)));
    }

    Widget snapButton(setState2) {
      return CustomButton(
          label: "Snap",
          secondary: true,
          icon: Icons.camera_alt,
          labelColor: cyanColor,
          onPressed: () async {
            var result = await Navigator.of(context)
                .push(createRoute(const FullScreenCamera()));
            if (result != null &&
                result["status"] != null &&
                result["status"] &&
                result["data"] != null) {
              // print(result["data"]);
              img.Image image = img.decodeImage(result["data"])!;
              image = (await (resizeImage(image))) as img.Image;
              image = (await (addInWatermark(image))) as img.Image;
              var byte = img.encodePng(image);

              // img.Image finalImage =
              //     await img.copyResize(image, width: 640, height: 480);
              // imageByte = await img.encodePng(finalImage);
              // var file = await File(result["path"]);
              // final byte = await file.readAsBytes();
              // final image2 = decodeImage(result["data"]);
              // final image2 = decodeImage(result["data"]);

              // copyInto(mergedImage, image1, blend = false);

              imageByte = byte as Uint8List?;
              // print(imageByte.lengthInBytes);
              setState2(() {});
            }
          });
    }

    Widget browseButton(setState2) {
      return CustomButton(
          label: getLocale("Browse"),
          secondary: true,
          icon: Icons.add_photo_alternate,
          labelColor: cyanColor,
          onPressed: () {
            startLoading(context);
            ImagePicker()
                .pickImage(source: ImageSource.gallery, imageQuality: 100)
                .then((pickedFile) async {
              if (pickedFile != null) {
                var fileExtension = (pickedFile.path.split('.').last);
                if (fileExtension == "png" ||
                    fileExtension == "jpg" ||
                    fileExtension == "jpeg" ||
                    fileExtension == "heic") {
                  // var file = File(pickedFile.path);
                  var byte = await pickedFile.readAsBytes();
                  img.Image image = img.decodeImage(byte)!;

                  image = (await (resizeImage(image))) as img.Image;
                  image = (await (addInWatermark(image))) as img.Image;
                  byte = img.encodePng(image) as Uint8List;
                  // file.delete();

                  // File(pickedFile.path).writeAsBytesSync(byte);

                  imageByte = byte;
                } else {
                  showAlertDialog(
                      context,
                      getLocale("Error"),
                      getLocale(
                          "Sorry, only jpg, png and heic files are allowed."));
                }
                setState2(() {});
                stopLoading();
              } else {
                stopLoading();
              }
            }).catchError((err) {
              stopLoading();
              if (err != null && err.code == "photo_access_denied") {
                showAlertDialog(context, getLocale("Error"),
                    getLocale("User did not allow photo access."));
              }
            });

            //Workaround for the image picker bug
            Future.delayed(const Duration(milliseconds: 2000), () {
              stopLoading();
            });
          });
    }

    Widget saveButton() {
      return CustomButton(
          label: getLocale("Save"),
          onPressed: () async {
            var fileName = DateTime.now().toString();
            List<int> byte = generateImageByte(imageByte);

            await File(join(path!, fileName)).writeAsBytes(byte);
            setState(() {});
            if (fileName != image) {
              if (image != null && image != "") {
                final previousImage = File(join(path!, image));
                if (previousImage.existsSync()) {
                  await previousImage.delete();
                }
              }
              widget.callback(fileName);
              image = fileName;
              if (!mounted) {}
              Navigator.of(context).pop(fileName);
              return;
            }
            if (!mounted) {}
            Navigator.of(context).pop();
          });
    }

    Future<dynamic> show() async {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, StateSetter setState) {
              return SystemPadding(
                  child: Center(
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: screenHeight * 0.38),
                          child: SizedBox(
                              width: screenWidth * 0.8,
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
                                            Text(widget.label,
                                                style: t1FontWN()),
                                            InkWell(
                                                onTap: () {
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
                                            child: imageByte != null
                                                ? imageView()
                                                : emptyImageView(getLocale(
                                                    "Please browse or snap a photo to show it here."))),
                                        Container(
                                            width: screenWidth,
                                            margin: EdgeInsets.symmetric(
                                                vertical: gFontSize),
                                            child: Row(children: [
                                              Expanded(
                                                  flex: 20,
                                                  child:
                                                      browseButton(setState)),
                                              Expanded(
                                                  flex: 20,
                                                  child: snapButton(setState)),
                                              Expanded(
                                                  flex: 35, child: Container()),
                                              Expanded(
                                                  flex: 25,
                                                  child: saveButton()),
                                            ]))
                                      ]))))));
            });
          }).then((img) {
        if (img == null) {
          imageByte = null;
        }
        if (imageByte == null && image != null) {
          initImage();
        }
      });
    }

    return InkWell(
        onTap: () {
          show();
        },
        child: imageByte != null
            ? imageView()
            : emptyImageView(getLocale("View/Snap")));
  }
}
