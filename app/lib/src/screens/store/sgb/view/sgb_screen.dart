import 'dart:ui';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/gradient_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../widgets/gradient_background.dart';
import '../widgets/sgb_details.dart';

@RoutePage()
class SgbScreen extends StatelessWidget {
  const SgbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: GetBuilder<DematProposalController>(
        init: DematProposalController(),
        builder: (controller) {
          if (controller.dematDetailsResponse.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.dematDetailsResponse.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Something went wrong. Please try again',
                onPressed: () {
                  controller.getStoreDematDetails();
                },
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SafeArea(
                  child: GradientBackground(
                    child: SgbDetails(
                      referralUrl: controller.dematDetails?.referralUrl,
                    ),
                  ),
                ),
                _buildFeatures(context)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Container(
      color: ColorConstants.white,
      padding:
          EdgeInsets.symmetric(horizontal: 30).copyWith(top: 32, bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Features of\nSGB\'s',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontSize: 23),
              ),
              SvgPicture.asset(
                AllImages().sgbGoldIcon,
                width: 80,
              )
            ],
          ),
          SizedBox(height: 32),
          _buildFeaturePoints(
            context,
            AllImages().sgbVerified,
            'Government backed gold bonds',
          ),
          _buildFeaturePoints(
            context,
            AllImages().sgbInterest,
            '2.5% annual Interest , paid every\n6 months',
          ),
          _buildFeaturePoints(
            context,
            AllImages().sgbTax,
            'Save tax, hold till maturity',
          ),
          _buildFeaturePoints(
            context,
            AllImages().sgbLocked,
            '100% secure & free gold storage',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePoints(BuildContext context, String image, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Image.asset(image, width: 38),
          SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          )
        ],
      ),
    );
  }
}
