import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/payout_controller.dart';
import 'package:app/src/screens/advisor/payout/widgets/payout_common_ui.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/advisor/models/payout_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeePayoutCard extends StatefulWidget {
  final PayoutModel employeePayout;

  const EmployeePayoutCard({Key? key, required this.employeePayout})
      : super(key: key);
  @override
  State<EmployeePayoutCard> createState() => _EmployeePayoutCardState();
}

class _EmployeePayoutCardState extends State<EmployeePayoutCard> {
  late TextStyle textStyle;
  late TextStyle headerTextStyle;

  bool showProducts = false;

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
        );
    headerTextStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w400,
            );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(),
          if (showProducts) _buildProducts(),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final data = {
      (widget.employeePayout.agentName ?? '-').toTitleCase():
          widget.employeePayout.agentEmail ?? '-',
      'Final Payout':
          WealthyAmount.currencyFormat(widget.employeePayout.finalPayout, 2),
      'Base Payout':
          WealthyAmount.currencyFormat(widget.employeePayout.basePayout, 2),
      'GST':
          WealthyAmount.currencyFormat(widget.employeePayout.effectiveGst, 2),
      'TDS': WealthyAmount.currencyFormat(widget.employeePayout.tds, 2),
    };
    Widget _buildInfo({
      required String title,
      required String subtitle,
      TextStyle? titleStyle,
      TextStyle? subtitleStyle,
    }) {
      titleStyle ??= textStyle;
      subtitleStyle ??= headerTextStyle;

      return CommonUI.buildColumnTextInfo(
        title: title,
        subtitle: subtitle,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        subtitleMaxLength: 2,
        titleMaxLength: 2,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildInfo(
                  title: data.entries.first.key,
                  subtitle: data.entries.first.value,
                  titleStyle: headerTextStyle,
                  subtitleStyle: textStyle,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildInfo(
                  title: data.entries.elementAt(1).key,
                  subtitle: data.entries.elementAt(1).value,
                  titleStyle: textStyle.copyWith(color: ColorConstants.black),
                  subtitleStyle: headerTextStyle,
                ),
              ),
            ],
          ),
        ),
        CommonUI.buildProfileDataSeperator(
          color: ColorConstants.borderColor,
          width: double.infinity,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ...data.entries.skip(2).map(
                (entry) {
                  return Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildInfo(
                          title: entry.key,
                          subtitle: entry.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showProducts = !showProducts;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Products',
                        style: textStyle.copyWith(
                          color: ColorConstants.primaryAppColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        showProducts
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 12,
                        color: ColorConstants.primaryAppColor,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProducts() {
    return GetBuilder<PayoutController>(
      id: widget.employeePayout.payoutId,
      builder: (controller) {
        if (!controller.payoutBreakupMap
            .containsKey(widget.employeePayout.payoutId)) {
          controller.getPayoutProductBreakup(widget.employeePayout.payoutId!);
        }
        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.loading) {
          return SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.error) {
          return SizedBox(
            height: 100,
            child: Center(
              child: RetryWidget(
                controller.payoutProductBreakupResponse.message,
                onPressed: () {
                  controller
                      .getPayoutProductBreakup(widget.employeePayout.payoutId!);
                },
              ),
            ),
          );
        }
        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.loaded) {
          final payoutProductBreakupData = controller
                  .payoutBreakupMap[widget.employeePayout.payoutId]
                  ?.map<MapEntry<String, String>>(
                (breakupData) {
                  String productDescription =
                      getInvestmentProductTitle(breakupData.productType);
                  if (productDescription.isNullOrEmpty) {
                    productDescription =
                        breakupData.productType.toCapitalized();
                  }
                  return MapEntry<String, String>(
                    productDescription,
                    WealthyAmount.currencyFormat(breakupData.baseRevenue, 2),
                  );
                },
              ) ??
              {};

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: PayoutCommonUI.buildDetailSection(
              data: payoutProductBreakupData,
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
