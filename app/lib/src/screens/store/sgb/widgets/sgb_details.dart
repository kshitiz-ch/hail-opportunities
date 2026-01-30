import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/gradient_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SgbDetails extends StatelessWidget {
  const SgbDetails({Key? key, required this.referralUrl}) : super(key: key);

  final String? referralUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 30).copyWith(top: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          _buildSgbDescription(context),
          _buildSgbCardWithShare(context)
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                AutoRouter.of(context).popForced();
              },
              child: Image.asset(
                AllImages().appBackIcon,
                height: 32,
                width: 32,
              ),
            ),
          ),
          Text(
            'SGB\'s',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _buildSgbDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are SGB\'s?',
          style: Theme.of(context)
              .primaryTextTheme
              .displayMedium!
              .copyWith(fontSize: 15),
        ),
        SizedBox(height: 10),
        Text(
          'Sovereign Gold Bonds, commonly known as SGBs, represent government securities denominated in grams of gold. They offer a compelling and secure alternative to physical gold ownership.',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12,
              color: ColorConstants.tertiaryBlack,
              letterSpacing: 0.5,
              height: 1.6),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSgbCardWithShare(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        border: Border.all(
          color: ColorConstants.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SGB Name
          Text(
            'Sovereign Gold Bonds 2023-24 - Series II',
            style: Theme.of(context)
                .primaryTextTheme
                .displayMedium!
                .copyWith(fontSize: 14),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              // SGB Status
              GradientText(
                'Open',
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    hexToColor("#701FFD"),
                    hexToColor("#FF7262"),
                  ],
                ),
                style: Theme.of(context)
                    .primaryTextTheme
                    .displayMedium!
                    .copyWith(fontSize: 10),
              ),

              // Dot
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                    color: ColorConstants.tertiaryBlack,
                    shape: BoxShape.circle),
              ),

              // SGB Date
              Text(
                '11 Sep -15 Sep',
                style: Theme.of(context)
                    .primaryTextTheme
                    .displayMedium!
                    .copyWith(
                        fontSize: 10, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPricePerGram(context),
              _buildShareButton(context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPricePerGram(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 10, color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 4),
          Text(
            '${WealthyAmount.currencyFormat(5873, 0)} / per gm',
            style: Theme.of(context)
                .primaryTextTheme
                .displayLarge!
                .copyWith(fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (referralUrl.isNullOrEmpty) {
          return showToast(text: 'Failed to share. Please try again');
        }

        String? shareText = getSgbShareText(referralUrl);

        String sgbBannerUrl =
            "https://i.wlycdn.com/articles/c-sgb-promo-pn1.png";

        await shareImage(
          context: context,
          creativeUrl: sgbBannerUrl,
          text: shareText,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
            color: ColorConstants.primaryAppColor,
            borderRadius: BorderRadius.circular(50)),
        child: Text(
          'Share',
          style: Theme.of(context)
              .primaryTextTheme
              .displayLarge!
              .copyWith(fontSize: 12, color: ColorConstants.white),
        ),
      ),
    );
  }
}
