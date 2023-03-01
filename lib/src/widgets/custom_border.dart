import 'dart:math';

import 'package:flutter/painting.dart';

class CustomBorder extends ShapeBorder {
  final BorderSide? left;
  final BorderSide? right;
  final BorderSide? top;
  final BorderSide? bottom;
  final BorderSide? topLeftCorner;
  final BorderSide? topRightCorner;
  final BorderSide? bottomLeftCorner;
  final BorderSide? bottomRightCorner;

  const CustomBorder(
      {this.left,
      this.right,
      this.top,
      this.bottom,
      this.topLeftCorner,
      this.topRightCorner,
      this.bottomLeftCorner,
      this.bottomRightCorner,
      this.borderRadius = BorderRadius.zero});

  double get biggestWidth => max(
      max(
          max(
              max(
                  max(
                      max(max(top?.width ?? 0.0, right?.width ?? 0.0),
                          bottom?.width ?? 0.0),
                      left?.width ?? 0.0),
                  bottomRightCorner?.width ?? 0.0),
              bottomLeftCorner?.width ?? 0.0),
          topRightCorner?.width ?? 0.0),
      topLeftCorner?.width ?? 0.0);

  /// The radii for each corner.
  final BorderRadius borderRadius;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(biggestWidth);
  }

  @override
  ShapeBorder scale(double t) {
    return CustomBorder(
        top: top?.scale(t),
        left: left?.scale(t),
        bottom: bottom?.scale(t),
        right: bottom?.scale(t),
        topLeftCorner: topLeftCorner?.scale(t),
        topRightCorner: topRightCorner?.scale(t),
        bottomLeftCorner: bottomLeftCorner?.scale(t),
        bottomRightCorner: bottomRightCorner?.scale(t),
        borderRadius: borderRadius * t);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CustomBorder) {
      return CustomBorder(
          top: top == null ? null : BorderSide.lerp(a.top!, top!, t),
          left: left == null ? null : BorderSide.lerp(a.left!, left!, t),
          bottom:
              bottom == null ? null : BorderSide.lerp(a.bottom!, bottom!, t),
          right: right == null ? null : BorderSide.lerp(a.right!, right!, t),
          topLeftCorner: topLeftCorner == null
              ? null
              : BorderSide.lerp(a.topLeftCorner!, topLeftCorner!, t),
          topRightCorner: topRightCorner == null
              ? null
              : BorderSide.lerp(a.topRightCorner!, topRightCorner!, t),
          bottomLeftCorner: bottomLeftCorner == null
              ? null
              : BorderSide.lerp(a.bottomLeftCorner!, bottomLeftCorner!, t),
          bottomRightCorner: bottomRightCorner == null
              ? null
              : BorderSide.lerp(a.bottomRightCorner!, bottomRightCorner!, t),
          borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CustomBorder) {
      return CustomBorder(
          top: top == null ? null : BorderSide.lerp(top!, b.top!, t),
          left: left == null ? null : BorderSide.lerp(left!, b.left!, t),
          bottom:
              bottom == null ? null : BorderSide.lerp(bottom!, b.bottom!, t),
          right: right == null ? null : BorderSide.lerp(right!, b.right!, t),
          topLeftCorner: topLeftCorner == null
              ? null
              : BorderSide.lerp(topLeftCorner!, b.topLeftCorner!, t),
          topRightCorner: topRightCorner == null
              ? null
              : BorderSide.lerp(topRightCorner!, b.topRightCorner!, t),
          bottomLeftCorner: bottomLeftCorner == null
              ? null
              : BorderSide.lerp(bottomLeftCorner!, b.bottomLeftCorner!, t),
          bottomRightCorner: bottomRightCorner == null
              ? null
              : BorderSide.lerp(bottomRightCorner!, b.bottomRightCorner!, t),
          borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!);
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(biggestWidth));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Paint? paint;

    paint = createPaintForBorder(topLeftCorner);
    if (borderRadius.topLeft.x != 0.0 && paint != null) {
      canvas.drawArc(
          rectForCorner(
              topLeftCorner?.width, rect.topLeft, borderRadius.topLeft, 1, 1),
          pi / 2 * 2,
          pi / 2,
          false,
          paint);
    }

    paint = createPaintForBorder(top);
    if (paint != null) {
      canvas.drawLine(
          rect.topLeft +
              Offset(
                  borderRadius.topLeft.x +
                      (borderRadius.topLeft.x == 0
                          ? (left?.width ?? 0.0)
                          : 0.0),
                  (top?.width ?? 0.0) / 2),
          rect.topRight +
              Offset(-borderRadius.topRight.x, (top?.width ?? 0.0) / 2),
          paint);
    }

    paint = createPaintForBorder(topRightCorner);
    if (borderRadius.topRight.x != 0.0 && paint != null) {
      canvas.drawArc(
          rectForCorner(topRightCorner?.width, rect.topRight,
              borderRadius.topRight, -1, 1),
          pi / 2 * 3,
          pi / 2,
          false,
          paint);
    }

    paint = createPaintForBorder(right);
    if (paint != null) {
      canvas.drawLine(
          rect.topRight +
              Offset(
                  -1 * (right?.width ?? 0.0) / 2,
                  borderRadius.topRight.y +
                      (borderRadius.topRight.x == 0
                          ? (top?.width ?? 0.0)
                          : 0.0)),
          rect.bottomRight +
              Offset(
                  -1 * (right?.width ?? 0.0) / 2, -borderRadius.bottomRight.y),
          paint);
    }

    paint = createPaintForBorder(bottomRightCorner);
    if (borderRadius.bottomRight.x != 0.0 && paint != null) {
      canvas.drawArc(
          rectForCorner(bottomRightCorner?.width, rect.bottomRight,
              borderRadius.bottomRight, -1, -1),
          pi / 2 * 0,
          pi / 2,
          false,
          paint);
    }

    paint = createPaintForBorder(bottom);
    if (paint != null) {
      canvas.drawLine(
          rect.bottomRight +
              Offset(
                  -borderRadius.bottomRight.x -
                      (borderRadius.bottomRight.x == 0
                          ? (right?.width ?? 0.0)
                          : 0.0),
                  -1 * (bottom?.width ?? 0.0) / 2),
          rect.bottomLeft +
              Offset(
                  borderRadius.bottomLeft.x, -1 * (bottom?.width ?? 0.0) / 2),
          paint);
    }

    paint = createPaintForBorder(bottomLeftCorner);
    if (borderRadius.bottomLeft.x != 0.0 && paint != null) {
      canvas.drawArc(
          rectForCorner(bottomLeftCorner?.width, rect.bottomLeft,
              borderRadius.bottomLeft, 1, -1),
          pi / 2 * 1,
          pi / 2,
          false,
          paint);
    }

    paint = createPaintForBorder(left);
    if (paint != null) {
      canvas.drawLine(
          rect.bottomLeft +
              Offset(
                  (left?.width ?? 0.0) / 2,
                  -borderRadius.bottomLeft.y -
                      (borderRadius.bottomLeft.x == 0
                          ? (bottom?.width ?? 0.0)
                          : 0.0)),
          rect.topLeft +
              Offset((left?.width ?? 0.0) / 2, borderRadius.topLeft.y),
          paint);
    }
  }

  Rect rectForCorner(
      double? sideWidth, Offset offset, Radius radius, num signX, num signY) {
    sideWidth ??= 0.0;
    double d = sideWidth / 2;
    double borderRadiusX = radius.x - d;
    double borderRadiusY = radius.y - d;
    Rect rect = Rect.fromPoints(
        offset + Offset(signX.sign * d, signY.sign * d),
        offset +
            Offset(signX.sign * d, signY.sign * d) +
            Offset(signX.sign * 2 * borderRadiusX,
                signY.sign * 2 * borderRadiusY));

    return rect;
  }

  Paint? createPaintForBorder(BorderSide? side) {
    if (side == null) return null;

    return Paint()
      ..style = PaintingStyle.stroke
      ..color = side.color
      ..strokeWidth = side.width;
  }
}
