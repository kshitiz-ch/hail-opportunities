import 'package:flutter/material.dart';

class CarouselIndicators extends StatelessWidget {
  const CarouselIndicators(
      {Key? key,
      this.itemsLength,
      this.currentIndex,
      this.primaryColor,
      this.secondaryColor})
      : super(key: key);

  final int? itemsLength;
  final int? currentIndex;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        itemsLength!,
        (itemIndex) {
          Color? color = Colors.transparent;

          if (currentIndex == itemIndex) {
            if (itemsLength! < 1) {
              color = Colors.transparent;
            } else {
              color = primaryColor;
            }
          } else if (itemsLength! < 1) {
            color = Colors.transparent;
          } else {
            color = secondaryColor;
          }

          return Container(
            margin: EdgeInsets.all(3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        },
      ),
    );
  }
}
