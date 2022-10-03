import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../helpers/flutter.dart';

class ShapeBackground extends StatelessWidget {
  const ShapeBackground({
    super.key,
    this.backGroundColor = const Color.fromARGB(255, 11, 56, 108),
    this.shapeColor = const Color.fromARGB(255, 5, 46, 106),
    required this.children,
  });

  final Color backGroundColor;
  final Color shapeColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          left: 0,
          child: Container(
            color: backGroundColor,
            width: context.width,
            height: context.height,
          ),
        ),
        Positioned(
          left: -context.width / 3,
          top: -context.width / 4,
          child: ClipOval(
            child: Container(
              height: context.width / 1.5,
              width: context.width / 1.2,
              color: shapeColor,
            ),
          ),
        ),
        Positioned(
          right: -context.width / 5,
          bottom: -context.height / 3,
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Container(
              height: context.height / 1.5,
              width: context.width / 1.2,
              color: shapeColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
