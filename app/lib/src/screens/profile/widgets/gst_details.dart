import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GstDetails extends StatelessWidget {
  GstDetails({Key? key, this.agent, this.refreshAgentModel}) : super(key: key);
  final ProfileController profileController = Get.find<ProfileController>();

  final AgentModel? agent;
  final Function? refreshAgentModel;

  @override
  Widget build(BuildContext context) {
    // If kyc not approved, don't show anything related to GST
    if (agent!.kycStatus != AgentKycStatus.APPROVED) {
      return SizedBox();
    }

    // Show Add GST option
    if (agent?.gst?.gstin == null) {
      return _buildAddGst(context);
    }

    // Show Edit or Verify GST option
    if (agent?.gst != null && agent!.gst!.gstin.isNotNullOrEmpty) {
      return _buildEditVerifyGst(context);
    }

    return SizedBox();
  }

  Widget _buildAddGst(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GST',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NA',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                        ),
              ),
              // ClickableText(
              //   text: 'Add',
              //   fontSize: 14,
              //   fontHeight: 1.3,
              //   onClick: () {
              //     updateGST(context);

              //     // CommonUI.showBottomSheet(
              //     //   context,
              //     //   child: GstFormBottomSheet(
              //     //     panNumber: agent!.panNumber,
              //     //     gstFormMode: GstFormMode.Add,
              //     //     onFormSubmit: () {
              //     //       refreshAgentModel!();
              //     //     },
              //     //   ),
              //     // );
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditVerifyGst(BuildContext context) {
    bool isGstVerified = agent!.gst!.verifiedAt != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GST',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      agent!.gst!.gstin!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.black,
                          ),
                    ),
                    if (!isGstVerified)
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: ColorConstants.white,
                              backgroundImage:
                                  AssetImage(AllImages().errorIcon),
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
                    else if (agent?.gst?.corporateName != null)
                      Text(
                        agent!.gst!.corporateName!,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 1.5),
                      )
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     ClickableText(
              //       text: 'Edit',
              //       fontSize: 14,
              //       fontHeight: 1.3,
              //       onClick: () {
              //         MixPanelAnalytics.trackWithAgentId(
              //           "update_gst",
              //           screen: 'partner_profile',
              //           screenLocation: 'partner_profile',
              //         );
              //         updateGST(context);
              //         // CommonUI.showBottomSheet(
              //         //   context,
              //         //   child: GstFormBottomSheet(
              //         //     gstNumber: agent?.gst?.gstin,
              //         //     panNumber: agent!.panNumber,
              //         //     gstFormMode: GstFormMode.Edit,
              //         //     onFormSubmit: () {
              //         //       refreshAgentModel!();
              //         //     },
              //         //   ),
              //         // );
              //       },
              //     ),
              //     if (!isGstVerified)
              //       Row(
              //         children: [
              //           Container(
              //             margin: EdgeInsets.symmetric(horizontal: 8),
              //             width: 1,
              //             height: 12,
              //             color: ColorConstants.primaryAppColor,
              //           ),
              //           ClickableText(
              //             text: 'Verify',
              //             fontHeight: 1.3,
              //             fontSize: 14,
              //             onClick: () {
              //               CommonUI.showBottomSheet(
              //                 context,
              //                 child: GstFormBottomSheet(
              //                   gstNumber: agent?.gst?.gstin,
              //                   panNumber: agent!.panNumber,
              //                   gstFormMode: GstFormMode.Verify,
              //                   onFormSubmit: () {
              //                     refreshAgentModel!();
              //                   },
              //                 ),
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //   ],
              // )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> updateGST(BuildContext context) async {
    await profileController.initiateKycSubFlow(context, 'PARTNER_GST');
    if (profileController.kycSubFlowState == NetworkState.loaded &&
        profileController.kycSubFlowUrl.isNotNullOrEmpty) {
      openKycSubFlowUrl(
        kycUrl: profileController.kycSubFlowUrl! + '&new_app_version=true',
        context: context,
        onExit: () {
          refreshAgentModel!();
        },
      );
    }
  }
}
