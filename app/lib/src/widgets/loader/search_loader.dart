import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchLoader extends StatelessWidget {
  const SearchLoader({
    Key? key,
    this.text,
  }) : super(key: key);

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 42.0,
            backgroundColor: ColorConstants.secondaryAppColor,
            child: Icon(CupertinoIcons.search,
                size: 48.0, color: ColorConstants.primaryAppColor),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            text ?? 'Search for your favourite products',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryGrey,
                ),
          )
        ],
      ),
    );
  }
}
