import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KYCDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        final bool shouldDoKyc =
            isKycPending(controller.advisorOverview!.agent!.kycStatus);
        final kycStatus =
            getKYCStatusText(controller.advisorOverview!.agent!.kycStatus)
                .toTitleCase();
        return shouldDoKyc
            ? _buildShouldDoKyc(
                context: context,
                kycStatus: kycStatus,
                profileController: controller)
            : _buildCompletedKYC(
                context: context,
                kycStatus: kycStatus,
                pan: controller.advisorOverview!.agent!.panNumber,
              );
      },
    );
  }

  void completeKYC(BuildContext context, ProfileController? profileController) {
    // AutoRouter.of(context).push(
    //   CompleteKycRoute(
    //     fromScreen: 'profile',
    //   ),
    // );
    AutoRouter.of(context).push(ProfileUpdateRoute());
  }

  Widget _buildCompletedKYC({
    required String kycStatus,
    required BuildContext context,
    String? pan,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CommonUI.buildColumnTextInfo(
            gap: 6,
            title: 'KYC Status',
            subtitle: kycStatus,
            titleStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
            subtitleStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: ColorConstants.greenAccentColor,
                    ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: CircleAvatar(
              radius: 8,
              backgroundColor: ColorConstants.greenAccentColor.withOpacity(0.2),
              child: Icon(
                Icons.check,
                size: 8,
                color: ColorConstants.greenAccentColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: CommonUI.buildColumnTextInfo(
              gap: 6,
              subtitle: pan ?? notAvailableText,
              title: 'PAN',
              titleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.black,
                      ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShouldDoKyc({
    required BuildContext context,
    required String kycStatus,
    ProfileController? profileController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.lightRedColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonUI.buildColumnTextInfo(
                  gap: 4,
                  title: 'KYC Status',
                  subtitle: kycStatus,
                  titleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                  subtitleStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.errorColor,
                      ),
                ),
                // ClickableText(
                //   text: 'Complete Now',
                //   fontSize: 14,
                //   fontWeight: FontWeight.w700,
                //   onClick: () {
                //     completeKYC(context, profileController);
                //   },
                // )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10),
            child: Text(
              'If you have an ARN, use PAN to which ARN is issued.',
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
