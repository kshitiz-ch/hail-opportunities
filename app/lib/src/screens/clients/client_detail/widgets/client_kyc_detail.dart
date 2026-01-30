import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientKYCDetail extends StatelessWidget {
  const ClientKYCDetail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GetBuilder<ClientDetailController>(
            id: 'investment-status',
            builder: (controller) {
              String mfInvestmentStatus = '';
              if (controller.investmentStatusResponse.state ==
                  NetworkState.loaded) {
                if (controller.mfInvestmentStatus.isNotNullOrEmpty) {
                  mfInvestmentStatus = controller.mfInvestmentStatus;
                } else {
                  mfInvestmentStatus = 'NA';
                }
              }

              if (controller.investmentStatusResponse.state ==
                  NetworkState.error) {
                mfInvestmentStatus = 'NA';
              }

              return Expanded(
                child: _buildDetailField(
                  context: context,
                  field: 'MF Profile',
                  // TODO: update proper status text
                  // agent kyc and client kyc status are different
                  value: mfInvestmentStatus,
                  textColor: controller.mfInvestmentStatus
                          .contains(InvestmentStatus.INVESTMENTREADY)
                      ? ColorConstants.greenAccentColor
                      : ColorConstants.black,
                ),
              );
            },
          ),
          CommonUI.buildProfileDataSeperator(
            color: ColorConstants.darkGrey,
            width: 1,
            height: 16,
          ),
          GetBuilder<ClientDetailController>(
              id: 'account-details',
              builder: (controller) {
                return Expanded(
                  child: _buildDetailField(
                    context: context,
                    field: 'Mandate',
                    value: _getMandateValue(controller),
                    textColor: _getMandateTextColor(controller),
                  ),
                );
              }),
        ],
      ),
    );
  }

  String _getMandateValue(ClientDetailController controller) {
    if (controller.mandateResponse.state == NetworkState.loading) {
      return '';
    }

    return controller.userMandateMeta?.statusText ?? 'Not Found';
    // if (controller.mandates.isEmpty) {
    //   return 'Not Found';
    // }

    // return getMandateStageDescription(
    //   controller.mandates.first.stage,
    // );
  }

  Color _getMandateTextColor(ClientDetailController controller) {
    if (controller.userMandateMeta?.mandateConfirmedAt != null) {
      return ColorConstants.greenAccentColor;
    }
    // if (controller.mandates.isNotEmpty) {
    //   if (controller.mandates.first.stage == 4) {
    //     return ColorConstants.greenAccentColor;
    //   }

    //   if ([1, 2, 3].contains(controller.mandates.first.stage)) {
    //     return ColorConstants.primaryAppColor;
    //   }

    //   return ColorConstants.errorColor;
    // }

    return ColorConstants.black;
  }

  Widget _buildDetailField({
    required BuildContext context,
    Color? textColor,
    required String field,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            field,
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(width: 6),
          Flexible(
            child: MarqueeWidget(
              child: Text(
                value,
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: textColor,
                    ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 6.0),
          //   child: Text(
          //     value.capitalizeFirst,
          //     style: Theme.of(context).primaryTextTheme.titleLarge.copyWith(
          //           color: textColor,
          //         ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
