import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/client/sip/client_sip_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SIPSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientSipDetailController>(
      builder: (ClientSipDetailController controller) {
        final sipStatus = CommonUI.getSIPStatusDataNew(controller.selectedSip);
        final textStyle =
            Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                );
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: ColorConstants.primaryCardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'SIP is currently ${sipStatus['statusText']}',
                        style: textStyle,
                      ),
                    ),
                    SizedBox(width: 5),
                    // Expanded(
                    //   child: CommonUI.buildColumnTextInfo(
                    //     title: 'SIP is currently ${sipStatus['statusText']}',
                    //     subtitle: '',
                    //     // subtitle:
                    //     //     'Started on ${getFormattedDate(controller.selectedSip.startDate!)}',
                    //     titleMaxLength: 2,
                    //     gap: 4,
                    //     titleStyle: textStyle,
                    //     subtitleStyle: textStyle?.copyWith(
                    //       fontWeight: FontWeight.w400,
                    //       color: ColorConstants.tertiaryBlack,
                    //     ),
                    //   ),
                    // ),
                    CommonUI.sipStatusUINew(
                      sipUserData: controller.selectedSip,
                      context: context,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CommonUI.buildProfileDataSeperator(
                  width: double.infinity,
                  height: 1,
                  color: ColorConstants.borderColor,
                ),
              ),
              _buildRowData(
                context: context,
                key: 'SIP Amount',
                value: WealthyAmount.currencyFormat(
                    controller.selectedSip.sipAmount, 0),
              ),
              SizedBox(
                height: 15,
              ),
              _buildRowData(
                context: context,
                key: 'SIP Day(s)',
                value: getSipDateStr(controller.selectedSip.sipDays),
                optionalWidget: buildSipDaysInfoIcon(
                    controller.selectedSip.sipDays, context),
              ),
              SizedBox(
                height: 15,
              ),
              _buildRowData(
                context: context,
                key: 'Start Date',
                value: getDateMonthYearFormat(
                  controller.selectedSip.startDate,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              _buildRowData(
                context: context,
                key: 'End Date',
                value: getDateMonthYearFormat(
                  controller.selectedSip.endDate,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 15),
              //   child: _buildRowData(
              //     context: context,
              //     key: 'Next SIP Date',
              //     value: getDateMonthYearFormat(
              //       controller.selectedSip?.nextSipDate,
              //     ),
              //   ),
              // ),
              CommonMfUI.buildStepperInfoUI(context, controller.selectedSip),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRowData({
    required BuildContext context,
    required String key,
    required String value,
    Widget? optionalWidget,
  }) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            key,
            style: textStyle?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: textStyle,
          ),
          if (optionalWidget != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: optionalWidget,
            )
        ],
      ),
    );
  }
}
