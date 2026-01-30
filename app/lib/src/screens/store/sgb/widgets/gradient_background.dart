import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pink Circle
        Positioned(
          top: 50,
          left: -180,
          child: Container(
            height: 406,
            width: 406,
            decoration: BoxDecoration(
              color: const Color(0xFFD8318C).withOpacity(.1),
              borderRadius: BorderRadius.circular(400),
            ),
          ),
        ),

        // Blue Circle
        Positioned(
          top: -70,
          right: -260,
          child: Container(
            height: 1000,
            width: 406,
            decoration: BoxDecoration(
              color: const Color(0xFF002C96).withOpacity(.10),
              borderRadius: BorderRadius.circular(400),
            ),
          ),
        ),

        // Blur Filter
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 43.5, sigmaY: 43.5),
            child: Container(),
          ),
        ),

        child
      ],
    );
  }
}
