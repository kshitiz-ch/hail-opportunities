import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:api_sdk/api_constants.dart';
import 'package:flutter/material.dart';

class ClientInvestmentsCard extends StatelessWidget {
  const ClientInvestmentsCard(
      {Key? key,
      required this.productType,
      this.investmentData,
      this.asOn,
      this.totalValue})
      : super(key: key);

  final ClientInvestmentProductType productType;
  final GenericPortfolioOverviewModel? investmentData;
  final DateTime? asOn;
  final double? totalValue;
  // final List? productList;
  // final MfProductsInvestmentModel? mfProducts;
  // final double? currentValue;
  // final bool isInsurance;
  // final int? pendingProductsCount;

  // final ClientInvestment investment;

  @override
  Widget build(BuildContext context) {
    bool showProductsCount = false;
    // (productList.isNotNullOrEmpty || pendingProductsCount! > 0) &&
    //     !isInsurance;

    String trailingText = WealthyAmount.currencyFormat(
      investmentData?.currentValue,
      0,
      showSuffix: false,
    );
    // if (isInsurance) {
    //   trailingText = '${productList!.length.toString()} products';
    // } else {
    //   trailingText = WealthyAmount.currencyFormat(
    //     currentValue,
    //     0,
    //     showSuffix: false,
    //   );
    // }

    return InkWell(
      onTap: () {
        if (investmentData == null) {
          return showToast(text: 'No Investment Found');
        }

        if (productType == ClientInvestmentProductType.mutualFunds) {
          MixPanelAnalytics.trackWithAgentId(
            "mutual_funds",
            screen: 'user_profile',
            screenLocation: 'investements',
          );

          AutoRouter.of(context).push(
            MfInvestmentListRoute(
              asOn: asOn,
              portfolioOverview: investmentData!,
            ),
          );
        } else {
          MixPanelAnalytics.trackWithAgentId(
            productType.name.toLowerCase(),
            screen: 'user_profile',
            screenLocation: 'investements',
          );
          AutoRouter.of(context).push(
            ProductInvestmentListRoute(
              productType: productType,
              asOn: asOn,
              portfolioOverview: investmentData!,
              // productList: productList,
              // isMf: productType == InvestmentProductType.mf,
              // mfProducts: mfProducts,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: getInvestmentColors(productType),
                shape: BoxShape.circle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getClientInvestmentProductTitle(productType),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                  SizedBox(width: 5),
                  if (totalValue != null &&
                      investmentData?.currentValue != null)
                    Text(
                      getPercentageText(
                          investmentData!.currentValue! / totalValue!),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  // showProductsCount ? _buildProductsCount(context) : SizedBox(),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  trailingText,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: ColorConstants.primaryAppColor,
                    size: 20,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildProductsCount(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 5),
  //     child: Row(
  //       children: [
  //         Text(
  //           '${productList!.length.toString()} Invested',
  //           style: Theme.of(context)
  //               .primaryTextTheme
  //               .headlineSmall!
  //               .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12),
  //         ),
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 7),
  //           child: Container(
  //             height: 10,
  //             width: 1,
  //             color: ColorConstants.secondaryLightGrey,
  //           ),
  //         ),
  //         Text(
  //           '${pendingProductsCount.toString()} Pending',
  //           style: Theme.of(context)
  //               .primaryTextTheme
  //               .headlineSmall!
  //               .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
