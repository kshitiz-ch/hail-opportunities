import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'category_breakup_bottomsheet.dart';

class TotalInvestmentCard extends StatefulWidget {
  const TotalInvestmentCard({Key? key}) : super(key: key);

  @override
  State<TotalInvestmentCard> createState() => _TotalInvestmentCardState();
}

class _TotalInvestmentCardState extends State<TotalInvestmentCard> {
  late TextStyle titleStyle;
  late TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    titleStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
        color: ColorConstants.tertiaryBlack, fontWeight: FontWeight.w600);

    subtitleStyle = Theme.of(context)
        .primaryTextTheme
        .headlineLarge!
        .copyWith(fontSize: 17);

    return GetBuilder<ClientAdditionalDetailController>(
        id: GetxId.clientInvestments,
        builder: (controller) {
          GenericPortfolioOverviewModel investmentData =
              controller.clientInvestmentsResult!.total!;

          double? returns = investmentData.xirr ?? 0;
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorConstants.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildCurrentAndInvestedValue(context, investmentData),
                      Divider(
                        color: ColorConstants.borderColor,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonClientUI.absoluteAnnualisedSwitch(
                                    context,
                                    showAbsoluteReturn: false,
                                    iconColor: ColorConstants.darkGrey,
                                    textStyle: titleStyle,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        getReturnPercentageText(returns),
                                        style: subtitleStyle,
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 4, right: 2),
                                        child: Image.asset(
                                          returns.isNegative
                                              ? AllImages().lossIcon
                                              : AllImages().gainIcon,
                                          height: 9,
                                          width: 9,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonUI.buildInfoToolTip(
                                    toolTipMessage:
                                        '* In case of PMS and Fixed Income the above unrealized Gain/Loss represent the total Gain/Loss',
                                    titleText: 'Unrealised Gain/Loss',
                                    showDuration: Duration(seconds: 10),
                                    titleStyle: titleStyle,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    WealthyAmount.currencyFormat(
                                        investmentData.unrealisedGain, 2),
                                    style: subtitleStyle,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ClickableText(
                  text: 'View Chart',
                  mainAxisAlignment: MainAxisAlignment.center,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Image.asset(
                      AllImages().chartDonutIcon,
                      width: 20,
                    ),
                  ),
                  fontSize: 14,
                  onClick: () {
                    CommonUI.showBottomSheet(
                      context,
                      child: CategoryBreakupBottomSheet(),
                    );
                  },
                )
              ],
            ),
          );
        });
  }

  Widget _buildCurrentAndInvestedValue(
      BuildContext context, GenericPortfolioOverviewModel investmentData) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Invested Value',
              titleStyle: titleStyle,
              subtitle: WealthyAmount.currencyFormat(
                  investmentData.costOfCurrentInvestment, 2),
              subtitleStyle: subtitleStyle,
            ),
          ),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Current Value',
              titleStyle: titleStyle,
              subtitle:
                  WealthyAmount.currencyFormat(investmentData.currentValue, 2),
              subtitleStyle: subtitleStyle,
            ),
          ),
        ],
      ),
    );
  }
}
