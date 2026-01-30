import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class MfPortfolioSubtypeListScreen extends StatelessWidget {
  // Fields
  final String? title;
  final int? goalType;
  final Client? client;
  final List<GoalSubtypeModel>? portfolios;
  // TODO: If portfolios == null, discuss on how to fetch the portfolio based on some identifier

  // Constructor
  const MfPortfolioSubtypeListScreen({
    Key? key,
    required this.title,
    required this.portfolios,
    @pathParam this.goalType,
    this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,

      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: "All $title (${portfolios!.length})",
      ),
      // Body
      body: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          ...portfolios!
              .map(
                (portfolio) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  margin: EdgeInsets.only(bottom: 16),
                  child: ProductCardNew(
                    bgColor: ColorConstants.primaryCardColor,
                    title: portfolio.title,
                    titleStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 15
                            // overflow: TextOverflow.ellipsis,
                            ),
                    leadingWidget: portfolio.iconSvg != null
                        ? Container(
                            margin: EdgeInsets.only(right: 12),
                            height: 36,
                            width: 36,
                            child: portfolio.iconSvg != null &&
                                    portfolio.iconSvg!.endsWith("svg")
                                ? SvgPicture.network(
                                    portfolio.iconSvg!,
                                  )
                                : Image.network(portfolio.iconSvg!),
                          )
                        : null,
                    description: portfolio.description,
                    descriptionMaxLines: 3,
                    onTap: () {
                      bool isCustomPortfolio =
                          portfolio.productVariant == otherFundsGoalSubtype;

                      if (isCustomPortfolio) {
                        AutoRouter.of(context).push(
                          FundListRoute(
                            client: client,
                            portfolio: portfolio,
                            isCustomPortfolio: true,
                          ),
                        );
                      } else {
                        AutoRouter.of(context).push(MfPortfolioDetailRoute(
                            client: client,
                            portfolio: portfolio,
                            isSmartSwitch: portfolio.isSmartSwitch));
                      }
                    },
                    bottomData: [
                      BottomData(
                        title: getReturnPercentageText(
                            portfolio.pastOneYearReturns),
                        subtitle: "Last 1 Year",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                      BottomData(
                        title: getReturnPercentageText(
                            portfolio.pastThreeYearReturns),
                        subtitle: "Last 3 Years",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                      BottomData(
                        title: getReturnPercentageText(
                            portfolio.pastFiveYearReturns),
                        subtitle: "Last 5 Years",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                      BottomData(
                        title: "${portfolio.term} years",
                        subtitle: "Horizon",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                      BottomData(
                        title:
                            "${(portfolio.avgReturns! * 100).toStringAsFixed(2)}%",
                        subtitle: "Avg Returns",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                      BottomData(
                        title: WealthyAmount.currencyFormat(
                          portfolio.minAmount,
                          portfolio.minAmount! % 1000 == 0 ? 0 : 1,
                        ),
                        subtitle: "Min Amount",
                        flex: 1,
                        align: BottomDataAlignment.left,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          // Bottom Padding
          SizedBox(
            height: 26.0,
          ),
        ],
      ),
    );
  }
}
