import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/screens/proposals/proposal_details/view/credit_card_proposal_detail_screen.dart';
import 'package:flutter/material.dart';

class CommonDetailCard extends StatelessWidget {
  final String cardTitle;
  final Map<String, String> data;

  const CommonDetailCard(
      {Key? key, required this.cardTitle, required this.data})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
            );
    final subtitleTextStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: 12),
          child: Text(
            cardTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20).copyWith(bottom: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
            ),
          ),
          child: buildGridInfoData(
            data: data,
            titleTextStyle: titleTextStyle,
            subtitleTextStyle: subtitleTextStyle,
          ),
        ),
      ],
    );
  }
}
