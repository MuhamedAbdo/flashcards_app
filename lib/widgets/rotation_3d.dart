import 'package:flutter/material.dart';

class Rotation3D extends StatelessWidget {
  final Animation<double> animation;
  final bool isFront;
  final Widget child;
  final bool shouldFlipText;

  const Rotation3D({
    super.key,
    required this.animation,
    required this.isFront,
    required this.child,
    this.shouldFlipText = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double value = isFront ? animation.value : 1.0 - animation.value;
        final isHalfway = value > 0.5;

        var transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(value * -3.14);

        // تصحيح اتجاه النص أثناء الدوران
        Widget content = child!;
        if (shouldFlipText && isHalfway) {
          content = Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: Alignment.center,
            child: content,
          );
        }

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: content,
        );
      },
      child: child,
    );
  }

  static void applySwipeRotation(
      AnimationController controller, double dragValue) {
    double newValue = (dragValue / 300).clamp(0.0, 1.0);
    controller.value = newValue;
  }
}
