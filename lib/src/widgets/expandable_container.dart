import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  final Widget? child;
  final bool? expanded;
  final int duration;
  final Function(bool value)? onAnimationCompleted;

  const ExpandableContainer(
      {Key? key,
      this.expanded = false,
      this.child,
      this.duration = 500,
      this.onAnimationCompleted})
      : super(key: key);

  @override
  ExpandableContainerState createState() => ExpandableContainerState();
}

class ExpandableContainerState extends State<ExpandableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    animation =
        CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);
    expandController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed ||
          status == AnimationStatus.completed) {
        if (widget.onAnimationCompleted != null) {
          widget.onAnimationCompleted!(true);
        }
      }
    });
  }

  void _runExpandCheck() {
    if (widget.expanded!) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: -1, sizeFactor: animation, child: widget.child);
  }
}
