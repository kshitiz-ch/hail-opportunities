import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/partner_referral_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ReferralDeeplinkScreen extends StatelessWidget {
  ReferralDeeplinkScreen() {
    if (!Get.isRegistered<PartnerReferralController>()) {
      Get.put<PartnerReferralController>(PartnerReferralController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Partner Referral'),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          // make sure agent details are fetched
          if (controller.advisorOverviewState == NetworkState.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.advisorOverviewState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Error fetching agent details',
                onPressed: () {
                  controller.getAdvisorOverview();
                },
              ),
            );
          }
          final isNonEmployee = !isEmployeeLoggedIn();
          final showReferralFeature = isNonEmployee &&
              controller.isKycDone &&
              controller.isEmpanelmentCompleted;
          if (showReferralFeature) {
            return _buildBody(context);
          } else {
            return Center(
              child: EmptyScreen(
                message: 'Feature Not avaialble',
                textStyle: context.headlineMedium
                    ?.copyWith(color: ColorConstants.black),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<PartnerReferralController>(
      id: 'referral-code',
      builder: (controller) {
        if (controller.partnerReferralInfoResponse.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.partnerReferralInfoResponse.isError) {
          return Center(
            child: RetryWidget(
              controller.partnerReferralInfoResponse.message,
              onPressed: () {
                controller.getPartnerReferralInfo();
              },
            ),
          );
        }
        if (controller.referralCode.isNullOrEmpty) {
          return Center(child: EmptyScreen(message: 'No Referral Code Found'));
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Invite Partners & Earn Rewards',
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
                child: Text(
                  'Invite friends to sign up as mutual fund distributors on Wealthy and unlock rewards as they complete each milestone',
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                  ),
                ),
              ),
              _buildReferralCode(context, controller.referralCode!),
              SizedBox(height: 22),
              _buildRewardsSection(context),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Looking for details? ',
                      style: context.headlineSmall?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                    ClickableText(
                      text: 'Check FAQs and T&C here',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      onClick: () {
                        AutoRouter.of(context)
                            .push(ReferralRewardsFaqTermsRoute());
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _buildSummarySection(context, controller),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferralCode(BuildContext context, String code) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: ColorConstants.secondaryBorderColor,
        strokeWidth: 3.0,
        dashPattern: [3, 3], // 10px dash, 5px space
      ),
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(color: ColorConstants.secondaryButtonColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  code,
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CommonUI.buildProfileDataSeperator(
                // height: 40,
                width: 1,
                color: ColorConstants.secondaryBorderColor,
              ),
            ),
            ClickableText(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.copy,
                  size: 20,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
              text: 'Copy',
              fontSize: 14,
              onClick: () {
                copyData(data: code);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    final rewardsData = [
      {
        'title': 'Base empanelment',
        'subtitle': 'Pay fees within 30 days of Signup',
        'amount': '₹2,500'
      },
      {
        'title': 'Equity Sales',
        'subtitle': '1 Cr sales in 240 Days',
        'amount': '₹5,500'
      },
      {
        'title': 'SIP Book',
        'subtitle': '10 L SIPs in 240 Days',
        'amount': '₹5,500'
      },
      {
        'title': 'Insurance Premium',
        'subtitle': '2 L Premium in 240 Days',
        'amount': '₹5,500'
      },
    ];
    final textStyle =
        context.titleLarge?.copyWith(color: ColorConstants.tertiaryBlack);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Earn up to ₹19,000 per referral!',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 16),
          child: Text(
            'You earn rewards as your referrals hit key milestones.',
            style: textStyle,
          ),
        ),
        ...List.generate(
          rewardsData.length,
          (index) {
            final reward = rewardsData[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: ColorConstants.greenAccentColor),
                      ),
                      child: Icon(
                        Icons.check,
                        color: ColorConstants.greenAccentColor,
                        size: 12,
                      ),
                    ),
                    if (index != rewardsData.length - 1)
                      Container(
                        height: 40,
                        width: 1.5,
                        color: Color(0xffE0E6EF),
                      )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CommonUI.buildColumnTextInfo(
                      gap: 6,
                      title: reward['title'] ?? '',
                      subtitle: reward['subtitle'] ?? '',
                      titleStyle: textStyle?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.black,
                      ),
                      subtitleStyle: textStyle,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Get ',
                    style: textStyle,
                    children: [
                      TextSpan(
                        text: reward['amount'] ?? '',
                        style: textStyle?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummarySection(
      BuildContext context, PartnerReferralController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CommonUI.buildColumnTextInfo(
            title: 'Total Rewards ',
            subtitle: '₹19,000 /Referral',
            titleStyle: context.headlineSmall
                ?.copyWith(color: ColorConstants.tertiaryBlack),
            subtitleStyle: context.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 20),
        SizedBox(
          width: 144,
          child: ActionButton(
            height: 56,
            text: 'Refer Now',
            margin: EdgeInsets.zero,
            onPressed: () {
              final text =
                  "Hi 👋\nI've been using a great platform to manage my wealth management business. It has made portfolio tracking and client reporting extremely easy. And I think you'll find it very useful too 💼\nUse my referral code ${controller.referralCode} or sign up directly here:\n${controller.referralUrl}";
              shareText(text);
            },
          ),
        ),
      ],
    );
  }
}
