import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/widgets/partner_name_update_bottomsheet.dart';
import 'package:app/src/screens/profile/widgets/profile_verify_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileEmailDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (controller) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!controller.hasLimitedAccess)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildTile(
                context: context,
                field: 'Name as per PAN',
                value: controller.advisorOverview?.agent?.kycStatus ==
                        AgentKycStatus.APPROVED
                    ? controller.advisorOverview!.agent!.name
                    : 'NA',
                isVerificationPending: false,
                onChange: controller.advisorOverview?.agent
                            ?.isFirstTransactionCompleted !=
                        true
                    ? () {
                        if (controller.advisorOverview?.agent?.kycStatus !=
                            AgentKycStatus.APPROVED) {
                          showToast(
                            text: "Please complete KYC first",
                          );
                          return;
                        }

                        if (controller.advisorOverview?.agent
                                ?.isFirstTransactionCompleted ??
                            false) {
                          showToast(
                            text:
                                "Sorry You Can't Change your name after first transaction",
                          );
                          return;
                        }

                        CommonUI.showBottomSheet(
                          context,
                          child: PartnerNameUpdateBottomSheet(),
                        );
                      }
                    : null,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: _buildTile(
              context: context,
              field: 'Your Phone Number',
              value: controller.advisorOverview!.agent!.phoneNumber!,
              isVerificationPending: controller
                      .advisorOverview!.agent!.phoneNumber.isNotNullOrEmpty &&
                  !controller.advisorOverview!.agent!.isPhoneVerified,
              updateFieldName: 'phone_number',
              onChange: () {
                MixPanelAnalytics.trackWithAgentId(
                  "edit_phone_number",
                  screen: 'partner_profile',
                  screenLocation: 'partner_profile',
                );
                updateProfileData(
                  context: context,
                  updateField: 'phone_number',
                  profileController: controller,
                );
              },
            ),
          ),
          _buildTile(
            context: context,
            field: 'Your email ID',
            value: controller.advisorOverview?.agent?.email ?? notAvailableText,
            updateFieldName: 'email',
            isVerificationPending:
                controller.advisorOverview!.agent!.email.isNotNullOrEmpty &&
                    !controller.advisorOverview!.agent!.isEmailVerified,
            onChange: () {
              MixPanelAnalytics.trackWithAgentId(
                "edit_email",
                screen: 'partner_profile',
                screenLocation: 'partner_profile',
              );
              if (controller.advisorOverview!.agent!.email.isNullOrEmpty) {
                AutoRouter.of(context).push(PartnerEmailAddRoute());
              } else {
                updateProfileData(
                  context: context,
                  updateField: 'email',
                  profileController: controller,
                );
              }
            },
          )
        ],
      );
    });
  }

  Widget _buildTile({
    required String field,
    required String? value,
    bool isVerificationPending = false,
    Function? onChange,
    String? updateFieldName,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              gap: 6,
              title: field,
              subtitle: value ?? notAvailableText,
              titleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        color: ColorConstants.black,
                      ),
              subtitleMaxLength: 5,
              optionalWidget: isVerificationPending
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: ColorConstants.white,
                            backgroundImage: AssetImage(AllImages().errorIcon),
                          ),
                          Text(
                            '  Verification pending',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  color: ColorConstants.errorColor,
                                ),
                          )
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          // if (onChange != null)
          //   ClickableText(
          //     text: value.isNullOrEmpty ? 'Add' : 'Edit',
          //     fontWeight: FontWeight.w700,
          //     fontSize: 14,
          //     onClick: onChange,
          //   ),
          if (isVerificationPending)
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 15,
                  color: ColorConstants.primaryAppColor,
                ),
                ProfileVerifyButton(
                  fieldName: updateFieldName,
                  fieldValue: value,
                ),
              ],
            )
        ],
      ),
    );
  }

  void updateProfileData({
    BuildContext? context,
    String? updateField,
    ProfileController? profileController,
  }) async {
    if (updateField != null) {
      final response =
          await profileController!.updatePartnerDetails(updateField);

      if (profileController.updatePartnerState == NetworkState.loaded) {
        if (response['changeRequestUrl'] != null ||
            response['changeRequestUrl'].toString().isNotEmpty) {
          final homeController = Get.isRegistered<HomeController>()
              ? Get.find<HomeController>()
              : Get.put(HomeController());

          if (!isPageAtTopStack(context!, WebViewRoute.name)) {
            try {
              final cookieManager = WebViewCookieManager();
              cookieManager.clearCookies();
            } catch (error) {
              LogUtil.printLog(error);
            }

            AutoRouter.of(context).push(WebViewRoute(
              url: response['changeRequestUrl'],
              onWebViewExit: () {
                AutoRouter.of(context).popUntilRouteWithName(ProfileRoute.name);
                profileController.getAdvisorOverview();
                homeController.getAdvisorOverview();
              },
            ));
          }
        } else {
          showToast(
            context: context,
            text: "Request to update failed please try again",
          );
        }
      } else {
        showToast(
          context: context,
          text: response.message,
        );
      }
    }
  }
}
