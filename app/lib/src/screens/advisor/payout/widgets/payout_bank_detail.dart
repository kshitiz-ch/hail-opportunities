import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/home/widgets/add_bank_detail_card.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayoutBankDetail extends StatelessWidget {
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    if (homeController.canPromptBankUpdateFeature) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 12),
        child: AddBankDetailCard(),
      );
    }

    return _buildBankDetail(context);
  }

  Widget _buildBankDetail(BuildContext context) {
    Widget _buildInfo(String key, String value) {
      final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w500,
          );
      return Expanded(
        child: CommonUI.buildColumnTextInfo(
          title: key,
          subtitle: value,
          titleStyle: style,
          gap: 6,
          subtitleStyle: style?.copyWith(
            color: ColorConstants.black,
            fontSize: 14,
          ),
        ),
      );
    }

    final agent = homeController.advisorOverviewModel?.agent;

    final bankData = [
      ['Current Bank Account', agent?.bankDetail?.bankAccountNo ?? '-'],
      [
        'Account Holder Name',
        agent?.bankDetail?.nameAsPerBank ?? agent?.name ?? '-'
      ],
      ['Bank Name', agent?.bankDetail?.bankName ?? '-'],
      ['IFSC', agent?.bankDetail?.bankIfscCode ?? '-'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfo(bankData.first.first, bankData.first.last),
              _buildInfo(bankData[1].first, bankData[1].last),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfo(bankData[2].first, bankData[2].last),
                SizedBox(width: 10),
                _buildInfo(bankData.last.first, bankData.last.last),
              ],
            ),
          ),
          _buildUpdateCTA(context),
        ],
      ),
    );
  }

  Widget _buildUpdateCTA(BuildContext context) {
    final agent = homeController.advisorOverviewModel?.agent;
    final isKycApproved = agent?.kycStatus == AgentKycStatus.APPROVED;
    final isUnderProcess = agent?.bankStatus == PartnerBankStatus.SUBMITTED;
    if (isKycApproved && !isUnderProcess) {
      return SizedBox(
        width: SizeConfig().screenWidth! / 2,
        height: 40,
        child: ActionButton(
          onPressed: () {
            MixPanelAnalytics.trackWithAgentId(
              "update_bank_details",
              screen: 'payouts',
              screenLocation: 'payouts',
            );
            updateBankDetail(context);
          },
          margin: EdgeInsets.zero,
          text: (!homeController.isBankDetailAdded
              ? 'Add Bank Detail'
              : 'Update Bank Detail'),
        ),
      );
    }
    return SizedBox();
  }

  Future<void> updateBankDetail(BuildContext context) async {
    await homeController.initiateKycSubFlow(context, 'PARTNER_BANK');
    if (homeController.kycSubFlowState == NetworkState.loaded &&
        homeController.kycSubFlowUrl.isNotNullOrEmpty) {
      openKycSubFlowUrl(
        kycUrl: homeController.kycSubFlowUrl! + '&new_app_version=true',
        context: context,
        onExit: () {
          homeController.getAdvisorOverview();
        },
      );
    }
  }
}
