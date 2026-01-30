import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/src/config/constants/image_constants.dart';

class AIIconWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color? color;
  final bool showBackground;

  const AIIconWidget({
    Key? key,
    required this.onTap,
    this.size = 24.0,
    this.color,
    this.showBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = SvgPicture.asset(
      AllImages().aiAssistantIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );

    if (!showBackground) {
      return GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: iconWidget,
      ),
    );
  }
}
