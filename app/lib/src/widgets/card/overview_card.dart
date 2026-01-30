import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard(
      {Key? key, required this.portfolio, this.isTopUpPortfolio = false})
      : super(key: key);

  final GoalSubtypeModel portfolio;
  final bool isTopUpPortfolio;

  @override
  Widget build(BuildContext context) {
    double minAmount =
        isTopUpPortfolio ? portfolio.minAddAmount! : portfolio.minAmount!;

    // return GridView.count(
    //   crossAxisCount: 3,
    //   crossAxisSpacing: 8.0,
    //   mainAxisSpacing: 8.0,
    //   childAspectRatio: 1.5,
    //   shrinkWrap: true,
    //   physics: ClampingScrollPhysics(),
    //   children: [
    //     GridDataNew(
    //       title: "Last 1 Year",
    //       subtitle: getReturnPercentageText(portfolio?.pastOneYearReturns),
    //     ),
    //     GridDataNew(
    //       title: "Last 3 Years",
    //       subtitle: getReturnPercentageText(portfolio?.pastThreeYearReturns),
    //     ),
    //     GridDataNew(
    //       title: "Last 5 Years",
    //       subtitle: getReturnPercentageText(portfolio?.pastFiveYearReturns),
    //     ),
    //     GridDataNew(
    //       title: "Horizon",
    //       subtitle: "${portfolio.term} years",
    //     ),
    //     GridDataNew(
    //       title: "Historical Returns",
    //       subtitle:
    //           "${(portfolio.minReturns * 100).toStringAsFixed(2)} - ${(portfolio.maxReturns * 100).toStringAsFixed(2)}%",
    //     ),
    //     GridDataNew(
    //       title: "Min Amount",
    //       subtitle: WealthyAmount.currencyFormat(
    //         minAmount,
    //         minAmount % 1000 == 0 ? 0 : 1,
    //       ),
    //     ),
    //   ],
    // );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Temp Hide
          // ===========
          // Row(
          //   children: [
          //     _data(context, "Last 1 Year",
          //         "${getReturnPercentageText(portfolio.pastOneYearReturns)}"),
          //     _data(context, "Last 3 Years",
          //         "${getReturnPercentageText(portfolio.pastThreeYearReturns)}"),
          //     _data(context, "Last 5 Years",
          //         "${getReturnPercentageText(portfolio.pastFiveYearReturns)}"),
          //   ],
          // ),
          // SizedBox(
          //   height: 24,
          // ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _data(context, "Horizon",
                  portfolio.term != null ? "${portfolio.term} years" : 'N/A'),
              _data(
                  context,
                  "Avg Returns",
                  portfolio.avgReturns != null
                      ? "${(portfolio.avgReturns! * 100).toStringAsFixed(2)}%"
                      : 'N/A'),
              _data(
                context,
                "Min Amount",
                WealthyAmount.currencyFormat(
                  minAmount,
                  minAmount % 1000 == 0 ? 0 : 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _data(BuildContext context, String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(
            height: 3.0,
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
