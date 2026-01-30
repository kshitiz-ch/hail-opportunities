import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardedClientCard extends StatelessWidget {
  final int clientIndex;
  final controller = Get.find<BrokingController>();
  late TextStyle textStyle;

  OnboardedClientCard({Key? key, required this.clientIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.black,
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientLogo(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildClientDetails(context),
                  ),
                ),
                Expanded(
                  child: _buildClientOnboardingStatus(context),
                )
              ],
            ),
          ),
          _buildClientKycStatus(context),
        ],
      ),
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    final effectiveIndex = clientIndex % 7;
    final name = controller.brokingOnboardingList[clientIndex].name;
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          name!.initials,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 16,
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    final model = controller.brokingOnboardingList[clientIndex];
    return CommonUI.buildColumnTextInfo(
      titleMaxLength: 2,
      title: model.name.toCapitalized(),
      expandTextWidget: true,
      subtitle: 'UCC : ${model.ucc}',
      titleStyle: textStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorConstants.black,
        overflow: TextOverflow.clip,
      ),
      subtitleStyle: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
    );
  }

  Widget _buildClientOnboardingStatus(BuildContext context) {
    final model = controller.brokingOnboardingList[clientIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Status ',
            style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
            children: [
              TextSpan(
                text:
                    getClientInvestmentStatusDescription(model.frontendStatus),
                style: textStyle,
              )
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          getFormattedDate(model.createdAt),
          style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
        ),
      ],
    );
  }

  Widget _buildClientKycStatus(BuildContext context) {
    final model = controller.brokingOnboardingList[clientIndex];
    return Container(
      color: ColorConstants.secondaryWhite,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: 'FnO Status  ',
              style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
              children: [
                TextSpan(
                  text: (model.isFnoEnabled ?? false) ? 'Enabled' : 'Disabled',
                  style: textStyle,
                ),
              ],
            ),
          ),
          if (model.showKycButton) _buildUrlWidget(title: 'KYC URL'),
          if (model.showFnOButton) _buildUrlWidget(title: 'FnO URL'),
        ],
      ),
    );
  }

  Widget _buildUrlWidget({required String title}) {
    return InkWell(
      onTap: () async {
        final type = title.contains('KYC') ? 'BROKING' : 'BROKING_FNO';
        final url = await controller.generateBrokingKycUrl(
          type,
          controller.brokingOnboardingList[clientIndex].userId!,
        );

        MixPanelAnalytics.trackWithAgentId(
          "copy_fno_url",
          screen: 'broking',
          screenLocation: 'latest_clients_added',
        );

        if (url.isNullOrEmpty ||
            controller.brokingUrlResponse.state == NetworkState.error) {
          showToast(text: 'Error generating link');
        } else {
          copyData(data: url);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.copy,
            size: 10,
            color: ColorConstants.primaryAppColor,
          ),
          SizedBox(width: 4),
          Text(
            title,
            style: textStyle.copyWith(
              color: ColorConstants.primaryAppColor,
            ),
          )
        ],
      ),
    );
  }
}
