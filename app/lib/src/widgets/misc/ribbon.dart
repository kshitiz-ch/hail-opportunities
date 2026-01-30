import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class RibbonShape extends StatefulWidget {
  RibbonShape({required this.text, this.bgColor});

  final String text;
  final Color? bgColor;

  @override
  RibbonShapeState createState() => RibbonShapeState();
}

class RibbonShapeState extends State<RibbonShape> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ArcClipper(),
      child: FittedBox(
        child: Container(
          padding: EdgeInsets.only(
            left: 6.0,
            right: 15,
            top: 2,
            bottom: 2,
          ),
          color: widget.bgColor ?? ColorConstants.primaryAppColor,
          child: Center(
            child: Text(
              widget.text,
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - 10, size.height / 2);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
