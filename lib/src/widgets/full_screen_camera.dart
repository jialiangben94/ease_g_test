import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';

class FullScreenCamera extends StatefulWidget {
  final bool frameEnable;
  const FullScreenCamera({Key? key, this.frameEnable = true}) : super(key: key);
  @override
  FullScreenCameraState createState() => FullScreenCameraState();
}

class FullScreenCameraState extends State<FullScreenCamera> {
  CameraController? controller;
  int? turn;
  double? height;
  double? width;
  double? radius;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      if (cameras.isEmpty) {
        showAlertDialog(
            context,
            getLocale("Error"),
            getLocale(
                "No Camera available please allow camera permission on the device!"),
            () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
        return;
      }
      controller = CameraController(cameras[0], ResolutionPreset.high,
          enableAudio: false);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      checkOrientation();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void checkOrientation() async {
    await NativeDeviceOrientationCommunicator()
        .orientation(useSensor: true)
        .then((orientation) {
      switch (orientation) {
        case NativeDeviceOrientation.landscapeLeft:
          controller!.lockCaptureOrientation(DeviceOrientation.landscapeRight);
          turn = 3;
          break;
        case NativeDeviceOrientation.landscapeRight:
          controller!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
          turn = 1;
          break;
        case NativeDeviceOrientation.portraitDown:
          controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
          turn = 0;
          break;
        case NativeDeviceOrientation.portraitUp:
          controller!.lockCaptureOrientation(DeviceOrientation.portraitDown);
          turn = 2;
          break;
        default:
          turn = 2;
          break;
      }
      setState(() {});
    });
  }

  Future<dynamic> cropImage(byte) async {
    if (widget.frameEnable) {
      img.Image finalImage;
      img.Image image = img.decodeImage(byte)!;

      var imageWidth = image.width / screenWidth;
      var imageHeight = image.height / screenHeight;

      var inHeight = (height! * imageHeight).round().toInt();
      var inWidth = (width! * imageWidth).round().toInt();
      var fromX = ((screenWidth * imageWidth - inWidth) / 2).round().toInt();
      var fromY = ((screenHeight * imageHeight - inHeight) / 2).round().toInt();

      finalImage = img.copyCrop(image, fromX, fromY, inWidth, inHeight);
      return img.encodePng(finalImage);
    }
    return byte;
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null ||
        !controller!.value.isInitialized ||
        turn == null) {
      return const Center(child: CircularProgressIndicator());
    }

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    height = gFontSize * 20;
    width = gFontSize * 25;
    radius = gFontSize * 0.5;

    var frame = widget.frameEnable
        ? ClipPath(
            clipper: CameraFrame(height, width, radius),
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.6)))
        : Container();

    var frameBorder = widget.frameEnable
        ? Center(
            child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(radius!)),
                    border: Border.all(
                        color: honeyColor, width: gFontSize * 0.25))))
        : Container();

    return SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(children: [
          // Container(
          //     height: screenHeight,
          //     width: screenWidth,
          //     child: RotatedBox(
          //         quarterTurns: turn, child: CameraPreview(controller))),
          SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: CameraPreview(controller!)),
          frame,
          frameBorder,
          Container(
              margin: EdgeInsets.all(gFontSize * 1.5),
              child: FloatingActionButton(
                  heroTag: "close",
                  backgroundColor: honeyColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.adaptive.arrow_back)))),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: gFontSize * 1.5),
                  child: FloatingActionButton(
                      backgroundColor: honeyColor,
                      heroTag: "snap",
                      onPressed: () async {
                        try {
                          // Ensure that the camera is initialized.
                          // await controller.initialize();

                          // final path = join(
                          //   (await getTemporaryDirectory()).path,
                          //   '${DateTime.now()}.png',
                          // );
                          startLoading(context);
                          var xfile = await controller!.takePicture();

                          var file = File(xfile.path);
                          var byte = await file.readAsBytes();
                          byte = await (cropImage(byte));
                          await file.delete();
                          stopLoading();
                          if (!mounted) {}
                          Navigator.of(context)
                              .pop({"status": true, "data": byte});
                        } catch (e) {
                          Navigator.of(context)
                              .pop({"status": false, "error": e});
                          rethrow;
                        }
                      },
                      child: const Icon(Icons.camera_alt))))
        ]));
  }
}

class CameraFrame extends CustomClipper<Path> {
  double? radius;
  double? height;
  double? width;

  CameraFrame(this.height, this.width, this.radius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH((size.width - width!) / 2, (size.height - height!) / 2,
              width!, height!),
          Radius.circular(radius!)))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
