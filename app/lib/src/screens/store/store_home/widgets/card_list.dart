import 'package:flutter/material.dart';

class CardList extends StatelessWidget {
  /// Defines the height of this Widget.
  final double height;

  final int? itemCount;

  /// The fraction of the viewport that card should occupy.
  /// Defaults to 1.0, which means the card fills the viewport in the scrolling direction.
  final double viewportFraction;

  final IndexedWidgetBuilder itemBuilder;

  const CardList({
    Key? key,
    this.height = 200,
    this.itemCount,
    this.viewportFraction = 1.0,
    required this.itemBuilder,
  })  : assert(itemCount == null || itemCount >= 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 13.0),
        controller: PageController(viewportFraction: viewportFraction),
        physics: PageScrollPhysics(),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
