//import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math show sin, pi;

class ThreeSizeDot extends StatefulWidget {
  const ThreeSizeDot(
      {Key? key,
      this.shape = BoxShape.circle,
      this.duration = const Duration(milliseconds: 1000),
      this.size = 8.0,
      this.color_1,
      this.color_2,
      this.color_3,
      this.padding = const EdgeInsets.all(4)})
      : super(key: key);

  final BoxShape shape;
  final Duration duration;
  final double size;
  final Color? color_1;
  final Color? color_2;
  final Color? color_3;
  final EdgeInsetsGeometry padding;

  @override
  ThreeSizeDotState createState() => ThreeSizeDotState();
}

class ThreeSizeDotState extends State<ThreeSizeDot>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation_1;
  late Animation<double> animation_2;
  late Animation<double> animation_3;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    animation_1 = DelayTween(begin: 0.0, end: 1.0, delay: 0.0)
        .animate(animationController);
    animation_2 = DelayTween(begin: 0.0, end: 1.0, delay: 0.2)
        .animate(animationController);
    animation_3 = DelayTween(begin: 0.0, end: 1.0, delay: 0.4)
        .animate(animationController);
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ScaleTransition(
          scale: animation_1,
          child: Padding(
              padding: widget.padding,
              child: Dot(
                  shape: widget.shape,
                  size: widget.size,
                  color: widget.color_1 ??
                      Theme.of(context).colorScheme.onPrimary))),
      ScaleTransition(
          scale: animation_2,
          child: Padding(
              padding: widget.padding,
              child: Dot(
                  shape: widget.shape,
                  size: widget.size,
                  color: widget.color_2 ??
                      Theme.of(context).colorScheme.onPrimary))),
      ScaleTransition(
          scale: animation_3,
          child: Padding(
              padding: widget.padding,
              child: Dot(
                  shape: widget.shape,
                  size: widget.size,
                  color: widget.color_3 ??
                      Theme.of(context).colorScheme.onPrimary)))
    ]);
  }
}

class Dot extends StatelessWidget {
  final BoxShape? shape;
  final double? size;
  final Color? color;

  const Dot({Key? key, this.shape, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: shape!)));
  }
}

class DelayTween extends Tween<double> {
  DelayTween({double? begin, double? end, this.delay})
      : super(begin: begin, end: end);

  final double? delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay!) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class DrawTriangle extends CustomPainter {
  late Paint _paint;

  DrawTriangle() {
    _paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// showFlushBar(BuildContext context, String message) {
//   return Flushbar(
//     title: "Sorry",
//     duration: Duration(seconds: 2),
//     messageText: Text(
//       message,
//       style: TextStyle(color: Colors.white),
//     ),
//     backgroundColor: honeyColor,
//     boxShadows: [
//       BoxShadow(
//         color: Colors.grey,
//         offset: Offset(0.0, 2.0),
//         blurRadius: 3.0,
//       )
//     ],
//   )..show(context);
// }
