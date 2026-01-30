import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:flutter/material.dart';

class ClientInvestmentOverview extends StatefulWidget {
  const ClientInvestmentOverview({
    Key? key,
    required this.investmentData,
  }) : super(key: key);

  final GenericPortfolioOverviewModel investmentData;

  @override
  State<ClientInvestmentOverview> createState() =>
      _ClientInvestmentOverviewState();
}

class _ClientInvestmentOverviewState extends State<ClientInvestmentOverview> {
  @override
  Widget build(BuildContext context) {
    double? returns = widget.investmentData.xirr ?? 0;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Current Value',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  letterSpacing: 0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      WealthyAmount.currencyFormat(
                          widget.investmentData.currentValue, 2),
                      style: Theme.of(context).primaryTextTheme.headlineMedium,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonClientUI.absoluteAnnualisedSwitch(
                      context,
                      showAbsoluteReturn: false,
                      textStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              letterSpacing: 0.3),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4, right: 2),
                          child: Image.asset(
                            returns.isNegative
                                ? AllImages().lossIcon
                                : AllImages().gainIcon,
                            height: 9,
                            width: 9,
                          ),
                        ),
                        Text(
                          getReturnPercentageText(returns),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                color: !returns.isNegative
                                    ? ColorConstants.greenAccentColor
                                    : ColorConstants.errorColor,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Invested',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              letterSpacing: 0.3),
                    ),
                    SizedBox(height: 4),
                    Text(
                      WealthyAmount.currencyFormat(
                          widget.investmentData.investedValue, 2),
                      style: Theme.of(context).primaryTextTheme.headlineMedium,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unrealised Gain/Loss',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              letterSpacing: 0.3),
                    ),
                    SizedBox(height: 4),
                    Text(
                      WealthyAmount.currencyFormat(
                          widget.investmentData.unrealisedGain, 2),
                      style: Theme.of(context).primaryTextTheme.headlineMedium,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
