import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/clients/client_detail/widgets/product_investment_list_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientProductOverviewCard extends StatelessWidget {
  ClientProductOverviewCard({
    Key? key,
    required this.overview,
    this.asOn,
    required this.productType,
  }) : super(key: key);

  final DateTime? asOn;
  final GenericPortfolioOverviewModel overview;
  final ClientInvestmentProductType productType;

  @override
  Widget build(BuildContext context) {
    final returnPercentage = overview.xirr ?? 0;
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildColumnInfo(
                  context,
                  title: 'Current Value',
                  subtitle:
                      WealthyAmount.currencyFormat(overview.currentValue, 2),
                ),
                _buildColumnInfo(
                  context,
                  customTitle: buildReturnType(
                    context: context,
                    showAbsouteReturn: false,
                  ),
                  customSubtitle: Row(
                    children: [
                      if (overview.absoluteReturns.isNotNullOrZero)
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Image.asset(
                            returnPercentage.isNegative
                                ? AllImages().lossIcon
                                : AllImages().gainIcon,
                            height: 9,
                            width: 9,
                          ),
                        ),
                      Text(
                        overview.absoluteReturns.isNotNullOrZero
                            ? getReturnPercentageText(returnPercentage)
                            : '0%',
                        style:
                            Theme.of(context).primaryTextTheme.headlineMedium,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildColumnInfo(
                  context,
                  title: 'Invested Value',
                  subtitle: WealthyAmount.currencyFormat(
                      overview.costOfCurrentInvestment, 2),
                ),
                _buildColumnInfo(
                  context,
                  title: _gainLossText(),
                  subtitle:
                      WealthyAmount.currencyFormat(overview.unrealisedGain, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (asOn != null) _buildLastUpdatedDate(context)
        ],
      ),
    );
  }

  String _gainLossText() {
    switch (productType) {
      case ClientInvestmentProductType.debentures:
      case ClientInvestmentProductType.fixedDeposit:
        return 'Gains';
      case ClientInvestmentProductType.pms:
        return 'Gain/Loss';
      default:
        return 'Unrealised Gain/Loss';
    }
  }

  Widget _buildLastUpdatedDate(BuildContext context) {
    String asOnDate = DateFormat('dd MMM yyyy').format(asOn!);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        'Last Updated on $asOnDate',
        textAlign: TextAlign.left,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
            ),
      ),
    );
  }

  Widget _buildColumnInfo(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? customSubtitle,
    Widget? customTitle,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customTitle != null)
            customTitle
          else
            Text(
              title ?? '',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(color: ColorConstants.tertiaryBlack),
            ),
          SizedBox(height: 4),
          if (customSubtitle != null)
            customSubtitle
          else
            Text(
              subtitle ?? '',
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            ),
        ],
      ),
    );
  }
}
