import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'investment_pie_chart.dart';

class CategoryBreakupBottomSheet extends StatelessWidget {
  const CategoryBreakupBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
          SizedBox(height: 5),
          Text(
            'Asset wise segregation ',
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          InvestmentPieChart(),
          Flexible(
            flex: 1,
            child: _buildCategoriesBreakUp(context),
          )
        ],
      ),
    );
  }

  Widget _buildCategoriesBreakUp(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: GetBuilder<ClientAdditionalDetailController>(
        id: GetxId.clientInvestments,
        builder: (controller) {
          // controller.clientInvestmentsResult.mf;
          double totalValue =
              controller.clientInvestmentsResult?.total?.currentValue ?? 0;
          return GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            children: [
              _buildCategoryPercentage(
                  context,
                  ClientInvestmentProductType.mutualFunds,
                  controller.clientInvestmentsResult?.mf?.currentValue,
                  totalValue),
              _buildCategoryPercentage(
                  context,
                  ClientInvestmentProductType.fixedDeposit,
                  controller.clientInvestmentsResult?.fd?.currentValue,
                  totalValue),
              _buildCategoryPercentage(
                  context,
                  ClientInvestmentProductType.preIpo,
                  controller.clientInvestmentsResult?.preipo?.currentValue,
                  totalValue),
              _buildCategoryPercentage(
                  context,
                  ClientInvestmentProductType.pms,
                  controller.clientInvestmentsResult?.pms?.currentValue,
                  totalValue),
              _buildCategoryPercentage(
                  context,
                  ClientInvestmentProductType.debentures,
                  controller.clientInvestmentsResult?.deb?.currentValue,
                  totalValue),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryPercentage(BuildContext context, productType,
      double? currentValue, double totalValue) {
    double percentage = ((currentValue ?? 0) / totalValue).toPercentage;
    String percentageText =
        percentage > 0 ? percentage.toStringWithoutTrailingZero(1)! : "0";
    return Container(
      height: 50,
      // decoration: BoxDecoration(
      //   border: Border.all(color: ColorConstants.borderColor),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: getInvestmentColors(productType),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                getClientInvestmentProductTitle(productType),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 3),
            child: Text(
                '${WealthyAmount.currencyFormat(currentValue, 2, showSuffix: true)} ($percentageText%)',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w700)),
          )
        ],
      ),
    );
  }
}
