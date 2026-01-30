import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankDetail extends StatelessWidget {
  // field
  final ProfileController profileController = Get.find<ProfileController>();
  final Function? refreshAgentModel;
  String bankInfoText = '';
  bool showAddCTA = true;

  BankDetail({Key? key, this.refreshAgentModel}) : super(key: key) {
    final accountNo =
        profileController.advisorOverview?.agent?.bankDetail?.bankAccountNo;
    final ifscCode =
        profileController.advisorOverview?.agent?.bankDetail?.bankIfscCode;

    String? bankName =
        profileController.advisorOverview?.agent?.bankDetail?.bankName;
    final partnerBankStatus =
        profileController.advisorOverview?.agent?.bankStatus;

    if (partnerBankStatus == PartnerBankStatus.SUBMITTED) {
      bankInfoText = 'Under Verification Process';
    }
    // if bank details are coming then show it irrescpective of status
    else if (profileController.isBankDetailPresent) {
      if (bankName.isNullOrEmpty) {
        bankName = '${ifscCode?.substring(0, 4)} Bank';
      }
      bankInfoText = '${getMaskedText(text: accountNo!)} | $bankName';
      showAddCTA = false;
    } else {
      bankInfoText = getPartnerBankStatusText(partnerBankStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBankDetail(
      context: context,
      bankInfoText: bankInfoText,
      fieldName: profileController.isBankDetailPresent
          ? 'Bank Details'
          : 'Bank Status',
    );
  }

  Widget _buildBankDetail({
    required BuildContext context,
    required String bankInfoText,
    required String fieldName,
  }) {
    final agent = profileController.advisorOverview?.agent;
    final isKycApproved = agent?.kycStatus == AgentKycStatus.APPROVED;
    final isUnderProcess = agent?.bankStatus == PartnerBankStatus.SUBMITTED;
    Color bankInfoColor = ColorConstants.black;
    if (agent?.bankStatus == PartnerBankStatus.REJECTED &&
        !profileController.isBankDetailPresent) {
      bankInfoColor = ColorConstants.errorColor;
    }
    if (isUnderProcess) {
      bankInfoColor = ColorConstants.primaryAppColor.withOpacity(0.8);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              titleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        color: bankInfoColor,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
              gap: 4,
              title: fieldName,
              subtitle:
                  '${(bankInfoText.isNullOrEmpty ? notAvailableText : bankInfoText)}',
            ),
          ),
          // if (isKycApproved && !isUnderProcess)
          //   ClickableText(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w700,
          //     onClick: () {
          //       MixPanelAnalytics.trackWithAgentId(
          //         "update_bank_details",
          //         screen: 'partner_profile',
          //         screenLocation: 'partner_profile',
          //       );
          //       updateBankDetail(context);
          //     },
          //     text: (showAddCTA ? 'Add' : 'Update'),
          //   )
        ],
      ),
    );
  }

  Future<void> updateBankDetail(BuildContext context) async {
    await profileController.initiateKycSubFlow(context, 'PARTNER_BANK');
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
