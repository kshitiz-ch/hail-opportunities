import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/authentication/models/agent_referral_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientOnboardingBottomsheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: SizeConfig().screenHeight * 0.8),
      child: GetBuilder<CommonController>(
        id: 'agent-referral-data',
        builder: (controller) {
          if (controller.agentReferralResponse.isLoading) {
            return SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.agentReferralResponse.isError ||
              controller.agentReferralModel == null) {
            return SizedBox(
              height: 400,
              child: Center(
                child: RetryWidget(
                  'Error getting partner referral data',
                  onPressed: () {
                    controller.getAgentReferralData();
                  },
                ),
              ),
            );
          }
          final onboardingLink =
              controller.agentReferralModel!.referralUrl ?? '';
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Share this link with clients to join wealthy ',
                            maxLines: 2,
                            style: context.headlineMedium?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        CommonUI.bottomsheetCloseIcon(context)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _buildOnboardingLink(context, onboardingLink),
                    ),
                    _buildOnboardingStats(
                        context, controller.agentReferralModel!),
                    SizedBox(height: 24),
                    Expanded(
                      child: _buildClientOnboardingStatus(context, controller),
                    ),
                    SizedBox(height: 70),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ActionButton(
                  text: 'Share Onboarding link',
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  textStyle: context.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.white,
                    fontSize: 16,
                  ),
                  onPressed: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "referral_link_share",
                      screen: 'clients',
                      screenLocation: 'clients',
                    );

                    shareClientInviteLink(onboardingLink);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOnboardingLink(BuildContext context, String onboardingLink) {
    return Card(
      color: ColorConstants.white,
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xffD9D9D9)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                onboardingLink,
                style: context.headlineSmall
                    ?.copyWith(color: ColorConstants.black),
              ),
            ),
          ),
          CommonUI.buildProfileDataSeperator(
            color: Color(0xffD9D9D9),
            height: 40,
            width: 1,
          ),
          Center(
            child: InkWell(
              onTap: () async {
                MixPanelAnalytics.trackWithAgentId(
                  "referral_link_copy",
                  screen: 'clients',
                  screenLocation: 'clients',
                );

                await copyData(data: onboardingLink);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy,
                      color: ColorConstants.primaryAppColor,
                      size: 24,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Copy',
                      style: context.headlineSmall?.copyWith(
                        color: ColorConstants.primaryAppColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingStats(
      BuildContext context, AgentReferralModel agentReferralModel) {
    Widget _buildStatCard({
      required String image,
      required String label,
      required String value,
    }) {
      return Container(
        decoration: BoxDecoration(border: Border.all(color: Color(0xffF2F2F2))),
        padding: EdgeInsets.only(left: 14),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(image, width: 24, height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              value,
              style: context.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
            ),
          ],
        ),
      );
    }

    // Statistics Cards
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onboarding Statistics',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        GridView.count(
          padding: EdgeInsets.only(top: 16),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 4,
          children: [
            _buildStatCard(
              image: AllImages().totalClickIcon,
              label: 'Total Clicks',
              value: (agentReferralModel.totalClicks ?? 0).toString(),
            ),
            _buildStatCard(
              image: AllImages().uniqueClickIcon,
              label: 'Unique Clicks',
              value: (agentReferralModel.totalUniqueClicks ?? 0).toString(),
            ),
            _buildStatCard(
              image: AllImages().totalSignupIcon,
              label: 'Total Signups',
              value: (agentReferralModel.totalSignups ?? 0).toString(),
            ),
            _buildStatCard(
              image: AllImages().totalTransactIcon,
              label: 'Transacted',
              value: WealthyAmount.currencyFormat(
                  (agentReferralModel.totalTransacted ?? 0), 2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClientOnboardingStatus(
    BuildContext context,
    CommonController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Onboarding Status',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: controller.agentReferralModel!.referredUsers.isNullOrEmpty
              ? EmptyScreen(message: 'No clients onboarded')
              : _buildOnboardedClientList(
                  controller.agentReferralModel!.referredUsers!,
                  context,
                ),
        )
      ],
    );
  }

  Widget _buildOnboardedClientList(
    List<ReferredUsers> referredClients,
    BuildContext context,
  ) {
    Widget _buildVerifiedUI() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: ColorConstants.greenAccentColor.withOpacity(0.1),
        ),
        padding: EdgeInsets.all(5),
        child: Text(
          'Verified',
          style: context.headlineSmall
              ?.copyWith(color: ColorConstants.greenAccentColor),
        ),
      );
    }

    final style =
        context.headlineSmall?.copyWith(color: ColorConstants.tertiaryBlack);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(child: Text('Name', style: style)),
            SizedBox(width: 10),
            Expanded(child: Text('Mobile Number', style: style)),
            SizedBox(width: 10),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text('Status', style: style),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: referredClients.length,
            itemBuilder: (context, index) {
              final isVerified =
                  referredClients[index].stage?.toUpperCase() == 'V';
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      referredClients[index].userName ?? 'NA',
                      style: style?.copyWith(color: ColorConstants.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      referredClients[index].userPhone ?? 'NA',
                      style: style?.copyWith(color: ColorConstants.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: isVerified
                          ? _buildVerifiedUI()
                          : Text(
                              'Signup',
                              style:
                                  style?.copyWith(color: ColorConstants.black),
                            ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: 16),
          ),
        ),
      ],
    );
  }
}
