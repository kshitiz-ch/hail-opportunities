import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/broking/broking_activity_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientActivityCard extends StatelessWidget {
  final int clientIndex;

  final controller = Get.find<BrokingActivityController>();

  late TextStyle textStyle;
  late Map<String, String> payData;
  late Map<String, String> brokerageData;

  ClientActivityCard({Key? key, required this.clientIndex}) : super(key: key) {
    final model = controller.brokingActivityList[clientIndex];
    payData = <String, String>{
      'Pay In':
          WealthyAmount.currencyFormat(model.totalPayin, 2, showSuffix: true),
      'Pay Out':
          WealthyAmount.currencyFormat(model.totalPayout, 2, showSuffix: true),
    };
    brokerageData = <String, String>{
      "Partner's Brokerage": WealthyAmount.currencyFormat(
        model.partnerBrokerage,
        2,
        showSuffix: true,
      ),
      "Total Brokerage": WealthyAmount.currencyFormat(
        model.brokerageTotal,
        2,
        showSuffix: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.black,
        );

    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildClientLogo(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildClientDetails(context),
                  ),
                ),
              ],
            ),
          ),
          CommonUI.buildProfileDataSeperator(
            height: 1,
            color: ColorConstants.borderColor,
            width: double.infinity,
          ),
          // pay details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20)
                .copyWith(bottom: 12, top: 16),
            child: _buildClientActivityDetails(context, payData),
          ),
          // brokerage details
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
            child: _buildClientActivityDetails(
              context,
              brokerageData,
              textColor: ColorConstants.greenAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    final effectiveIndex = clientIndex % 7;
    final name = controller.brokingActivityList[clientIndex].name;
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
      radius: 18,
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    final model = controller.brokingActivityList[clientIndex];
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            (model.name ?? ''),
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'UCC : ${model.ucc}',
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildClientActivityDetails(
      BuildContext context, Map<String, String> data,
      {Color? textColor}) {
    return Row(
      children: data.entries
          .map(
            (data) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CommonUI.buildColumnTextInfo(
                  subtitleMaxLength: 2,
                  title: data.key,
                  subtitle: data.value,
                  subtitleStyle: textStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor ?? ColorConstants.black,
                  ),
                  titleStyle:
                      textStyle.copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
