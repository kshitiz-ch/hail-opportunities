import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class LinkExpiryText extends StatelessWidget {
  LinkExpiryText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ColorConstants.lightOrangeColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 16, color: ColorConstants.black),
              SizedBox(width: 4),
              Text(
                'Link expires in 24 hours',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              )
            ],
          ),
        ),
      ],
    );
  }
}
