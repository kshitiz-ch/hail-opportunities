import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/screens/profile/widgets/refresh_arn_details_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ARNDetail extends StatelessWidget {
  final Function? refreshAgentModel;
  final ProfileController profileController = Get.find<ProfileController>();
  // final PartnerKycController kycController =
  //     Get.isRegistered<PartnerKycController>()
  //         ? Get.find<PartnerKycController>()
  //         : Get.put<PartnerKycController>(PartnerKycController());

  ARNDetail({
    Key? key,
    this.refreshAgentModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arnText = getAgentArn();
    final fieldName =
        'ARN${profileController.advisorOverview?.partnerArn != null && profileController.advisorOverview!.partnerArn!.euin!.isNotEmpty ? ', EUIN' : ''}';

    if (!isArnAttached() &&
        isKycPending(profileController.advisorOverview!.agent!.kycStatus)) {
      return _buildPendingKyc(
        context: context,
        fieldName: fieldName,
      );
    } else {
      return _buildCompletedKyc(
        arnText: arnText,
        context: context,
        fieldName: fieldName,
      );
    }
  }

  Widget _buildCompletedKyc({
    required BuildContext context,
    required String arnText,
    required String fieldName,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonUI.buildColumnTextInfo(
              titleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        color: ColorConstants.black,
                      ),
              gap: 4,
              title: fieldName,
              subtitle:
                  '${(arnText.isNullOrEmpty ? notAvailableText : arnText.length > 26 ? (arnText.substring(0, 24) + '...') : arnText)}',
            ),
            // if (profileController.advisorOverview?.partnerArn == null ||
            //     profileController.advisorOverview!.partnerArn!.arn!.isEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(
            //       left: 6,
            //     ),
            //     child: Tooltip(
            //       message: 'Complete KYC to attach ARN',
            //       decoration: BoxDecoration(
            //         color: ColorConstants.lightBlack,
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //       triggerMode: TooltipTriggerMode.tap,
            //       child: Icon(
            //         Icons.info_outline,
            //         color: ColorConstants.errorColor,
            //         size: 14,
            //       ),
            //     ),
            //   ),
            Spacer(),
            if (showRefreshButton())
              _buildRefreshArn(context, arnText)
            else
              _buildAddOrUpdateArn(context, arnText)
          ],
        ),
        if (profileController.advisorOverview?.partnerArn?.arnValidTill != null)
          Text(
            'Valid till - ${getFormattedDate(profileController.advisorOverview?.partnerArn?.arnValidTill)}',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          )
      ],
    );
  }

  Widget _buildPendingKyc({
    required BuildContext context,
    required String fieldName,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text.rich(
            TextSpan(
              text: 'Missing',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.errorColor,
                  ),
              children: [
                TextSpan(
                  text: ' - Complete KYC to attach ARN',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRefreshArn(BuildContext context, String? arnText) {
    return InkWell(
      onTap: () {
        profileController.searchPartnerArn();
        CommonUI.showBottomSheet(
          context,
          child: RefreshArnDetailsBottomSheet(),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.sync,
            color: ColorConstants.primaryAppColor,
          ),
          SizedBox(width: 5),
          Text(
            'Refresh',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  Widget _buildAddOrUpdateArn(BuildContext context, String? arnText) {
    if (profileController.advisorOverview?.agent?.kycStatus ==
        AgentKycStatus.APPROVED) {
      bool isArnPending =
          profileController.advisorOverview?.partnerArn?.status ==
              ArnStatus.Pending;
      if (isArnPending) {
        return Text(
          'Under Progress',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack, fontWeight: FontWeight.w600),
        );
      }
      // else {
      // return ClickableText(
      //   fontSize: 14,
      //   fontWeight: FontWeight.w700,
      //   onClick: () {
      //     if (profileController.advisorOverview!.agent!.kycStatus ==
      //         AgentKycStatus.APPROVED) {
      //       MixPanelAnalytics.trackWithAgentId(
      //         "update_arn",
      //         screen: 'partner_profile',
      //         screenLocation: 'partner_profile',
      //       );
      //       updateARN(context);
      //     }
      //   },
      //   text: (profileController.advisorOverview!.agent!.kycStatus !=
      //           AgentKycStatus.APPROVED)
      //       ? ''
      //       : (arnText.isNullOrEmpty ? 'Add ARN' : 'Update ARN'),
      // );
      // }
    }

    return SizedBox();
  }

  Future<void> updateARN(BuildContext context) async {
    await profileController.initiateKycSubFlow(context, 'PARTNER_ARN');
    if (profileController.kycSubFlowState == NetworkState.loaded &&
        profileController.kycSubFlowUrl.isNotNullOrEmpty) {
      openKycSubFlowUrl(
        kycUrl: profileController.kycSubFlowUrl!,
        context: context,
        onExit: () {
          refreshAgentModel!();
        },
      );
    }
  }

  // void attachARN(BuildContext context) {
  //   bool isPstExists =
  //       profileController.advisorOverview!.agent?.pst?.id != null;

  //   if (profileController.advisorOverview?.partnerArn == null) {
  //     if (profileController
  //             .advisorOverview?.agent?.panNumber?.isNotNullOrEmpty ??
  //         false) {
  //       arnAttachDialog(
  //         context,
  //         description:
  //             'Your ARN was not detected for PAN - ${profileController.advisorOverview?.agent?.panNumber ?? ''}. what would you like to do?',
  //         buttonText: 'Search my ARN',
  //         btnController: profileController.btnController,
  //         buttonAction: () async {
  //           searchPartnerArn(context);
  //         },
  //       );
  //     } else {
  //       arnAttachDialog(
  //         context,
  //         description: isPstExists
  //             ? 'For attaching ARN, please share your pan number with your RM'
  //             : 'For attaching ARN, please contact us at ops@wealthy.in',
  //         isCheckingArn: false,
  //         buttonText: isPstExists ? 'Contact RM' : 'Mail to ops@wealthy.in',
  //         showButton: true,
  //         btnController: profileController.btnController,
  //         buttonAction: () async {
  //           profileController.btnController?.reset();
  //           if (isPstExists) {
  //             showModalBottomSheet<void>(
  //               isScrollControlled: true,
  //               useRootNavigator: true,
  //               context: context,
  //               barrierColor: Colors.black.withOpacity(0.8),
  //               backgroundColor: ColorConstants.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(20.0),
  //                   topRight: Radius.circular(20.0),
  //                 ),
  //               ),
  //               builder: (BuildContext context) {
  //                 return ContactRmBottomSheetScreen(
  //                     advisorModel: profileController.advisorOverview,
  //                     fromScreen: "Profile");
  //               },
  //             );
  //           } else {
  //             await launch("mailto:ops@wealthy.in");
  //           }
  //         },
  //       );
  //     }
  //   } else if (!profileController.advisorOverview!.partnerArn!.isArnActive!) {
  //     arnAttachDialog(
  //       context,
  //       description:
  //           'Your ARN was expired / not attached properly. What would you like to do?',
  //       buttonText: 'Search my ARN',
  //       btnController: profileController.btnController,
  //       buttonAction: () async {
  //         searchPartnerArn(context);
  //       },
  //     );
  //   } else {
  //     navigateToArnScreen(
  //         context, profileController.advisorOverview!.partnerArn);
  //   }
  // }

  bool isArnAttached() {
    return profileController.advisorOverview?.partnerArn != null &&
        (profileController.advisorOverview!.partnerArn?.isArnActive == true);
  }

  bool showRefreshButton() {
    if (profileController.advisorOverview?.partnerArn?.arnValidTill == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      DateTime arnValidTill =
          profileController.advisorOverview!.partnerArn!.arnValidTill!;
      bool isArnExpiresIn6Months = (DateTime(
              arnValidTill.year, arnValidTill.month - 6, arnValidTill.day))
          .isBefore(now);

      return isArnAttached() && isArnExpiresIn6Months;
    } catch (error) {
      return false;
    }
  }

  String getAgentArn() {
    PartnerArnModel? partnerArn = profileController.advisorOverview?.partnerArn;
    if (partnerArn == null || partnerArn.arn!.isEmpty) {
      return notAvailableText;
    } else {
      return 'ARN-${partnerArn.arn}${partnerArn.euin!.isNotEmpty ? ', ${partnerArn.euin}' : ''}';
    }
  }
}
