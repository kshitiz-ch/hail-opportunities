import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FundOverviewSection extends StatelessWidget {
  const FundOverviewSection({
    Key? key,
    required this.fund,
    this.isTopUpPortfolio = false,
  }) : super(key: key);

  final SchemeMetaModel? fund;
  final bool? isTopUpPortfolio;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            );
    String navDisplay = '';
    if ((fund?.nav ?? 0) == 0) {
      navDisplay = "0";
    } else {
      navDisplay = (fund?.nav ?? 0).toStringAsFixed(4);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ).copyWith(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GridData(
                  customSubtitle: Row(
                    children: [
                      Text(
                        fund?.nav != null ? navDisplay : '-',
                        style: subtitleStyle,
                      ),
                      if (fund?.navDate != null)
                        Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Tooltip(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: ColorConstants.black,
                                borderRadius: BorderRadius.circular(6)),
                            triggerMode: TooltipTriggerMode.tap,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                            message:
                                'Nav Date : ${getFormattedDate(fund!.navDate!)}',
                            child: Icon(
                              Icons.info_outline,
                              color: ColorConstants.black,
                              size: 16,
                            ),
                          ),
                        )
                    ],
                  ),
                  title: "Latest NAV",
                  titleStyle: titleStyle,
                ),
              ),
              Expanded(
                child: GridData(
                  subtitle: "${WealthyAmount.currencyFormat(
                    (isTopUpPortfolio! &&
                            (fund?.folioOverview?.exists ?? false))
                        ? fund!.minAddDepositAmt
                        : fund!.minDepositAmt,
                    0,
                    showSuffix: false,
                  )}",
                  title: "Min Investment", titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  // subtitle: "Min ${isTopUpPortfolio ? 'Addl ' : ''}Investment",
                ),
              ),
              Expanded(
                child: GridData(
                  subtitle: fund?.minSipDepositAmt != null
                      ? "${WealthyAmount.currencyFormat(
                          fund!.minSipDepositAmt,
                          0,
                          showSuffix: false,
                        )}"
                      : '-',
                  title: "Min Sip Amount",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  // subtitle: "Min ${isTopUpPortfolio ? 'Addl ' : ''}Investment",
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GridData(
                  subtitle: fund?.expenseRatio != null
                      ? "${fund!.expenseRatio!.toStringAsFixed(2)}%"
                      : '-',
                  title: "Expense Ratio",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              GetBuilder<FundDetailController>(
                id: 'exit-load',
                initState: (_) {
                  FundDetailController controller =
                      Get.find<FundDetailController>();
                  if (controller.exitLoadTime == null &&
                      controller.exitLoadUnit == null) {
                    controller.getExitLoadDetails();
                  }
                },
                builder: (controller) {
                  return Expanded(
                    child: GridData(
                      customSubtitle: Row(
                        children: [
                          Text(
                            (fund?.exitLoadPercentage?.isNotNullOrZero ?? false)
                                ? "${fund!.exitLoadPercentage!.toStringAsFixed(2)}%"
                                : "-",
                            style: subtitleStyle,
                          ),
                          if ((fund?.exitLoadPercentage.isNotNullOrZero ??
                                  false) &&
                              controller.exitLoadTime != null &&
                              controller.exitLoadUnit != null)
                            Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Tooltip(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    color: ColorConstants.black,
                                    borderRadius: BorderRadius.circular(6)),
                                triggerMode: TooltipTriggerMode.tap,
                                textStyle: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                message:
                                    'Exit load of ${fund?.exitLoadPercentage!.toStringAsFixed(2)}% if redeemed within ${getExitLoadDescription(controller.exitLoadTime, controller.exitLoadUnit)}',
                                child: Icon(
                                  Icons.info_outline,
                                  color: ColorConstants.black,
                                  size: 16,
                                ),
                              ),
                            )
                        ],
                      ),
                      title: "Exit Load",
                      titleStyle: titleStyle,
                    ),
                  );
                },
              ),
              Expanded(
                child: GridData(
                  subtitle: fund?.aum != null
                      ? '${WealthyAmount.currencyFormat(fund?.aum, 2)} Cr'
                      : '-',
                  title: "Fund Size",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
