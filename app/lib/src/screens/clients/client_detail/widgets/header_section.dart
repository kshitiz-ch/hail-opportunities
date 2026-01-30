import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_contact_details.dart';
import 'package:app/src/screens/clients/client_detail/widgets/onboarding_status_section.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderSection extends StatelessWidget {
  TextStyle? textStyle;
  final controller = Get.find<ClientDetailController>();

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.copyWith(color: ColorConstants.black);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
      child: Column(
        children: [
          OnboardingStatusSection(),
          ClientContactDetails(client: controller.client),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<ClientDetailController>(
                id: 'account-details',
                builder: (controller) {
                  if (controller.clientMfProfileResponse.state ==
                      NetworkState.loading) {
                    return Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  return ClickableText(
                    text: 'View Profile Details',
                    onClick: () async {
                      if (controller.clientMfProfileResponse.state ==
                          NetworkState.loading) {
                        return;
                      }

                      if (controller.clientMfProfileResponse.state ==
                          NetworkState.loaded) {
                        AutoRouter.of(context).push(
                            ClientProfileRoute(client: controller.client!));
                      } else {
                        await controller.getClientProfileDetails();

                        if (controller.clientMfProfileResponse.state ==
                            NetworkState.loaded) {
                          AutoRouter.of(context).push(
                              ClientProfileRoute(client: controller.client!));
                        } else {
                          showToast(
                              text:
                                  'Failed to load profile details. Please Try again');
                        }
                      }
                    },
                  );
                },
              ),
              ClickableText(
                text: '+ Add Family',
                onClick: () {
                  final clientDetailController =
                      Get.find<ClientDetailController>();
                  AutoRouter.of(context).push(
                    ClientFamilyDetailRoute(
                        client: clientDetailController.client),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClientDetail(BuildContext context) {
    return Row(
      children: [
        CommonClientUI.nameAvatar(context, controller.client?.name, radius: 21),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MarqueeWidget(
                child: Text(
                  controller.client?.name?.toTitleCase() ?? '',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  CommonClientUI.buildRowTextInfo(
                    title: 'CRN',
                    subtitle: controller.client?.crn ?? '-',
                    titleStyle: textStyle!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                    subtitleStyle: textStyle!,
                    onTap: () async {
                      MixPanelAnalytics.trackWithAgentId(
                        "crn_copy",
                        screen: 'user_profile',
                        screenLocation: 'user_profile',
                      );
                      await copyData(data: controller.client!.crn);
                      showToast(text: 'CRN copied');
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CommonUI.buildProfileDataSeperator(
                      height: 16,
                      width: 1,
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                  CommonClientUI.buildRowTextInfo(
                    title: 'Account Type',
                    subtitle: getPanUsageDescription(
                        controller.client?.panUsageType ?? '-'),
                    titleStyle: textStyle!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                    subtitleStyle: textStyle!,
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
