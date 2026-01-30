import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:core/modules/store/models/fixed_deposit_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

List<Widget>? getProductBottomData(product,
    {bool? isTopUpPortfolio = false,
    bool isShownOnStore = false,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle}) {
  if (product is SchemeMetaModel) {
    return _buildFundBottomData(
      product,
      isTopUpPortfolio: isTopUpPortfolio!,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
    );
  }

  if (product is GoalSubtypeModel) {
    return _buildPortfolioBottomData(product, isShownOnStore: isShownOnStore);
  }

  if (product is UnlistedProductModel) {
    return _buildPreIPOBottomData(product);
  }

  if (product is FixedDepositModel) {
    return _buildFixedDepositBottomData(product);
  }

  if (product is DebentureModel) {
    return _buildDebentureBottomData(product);
  }

  if (product is PMSVariantModel) {
    return _buildPMSVariantBottomData(
      product,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
    );
  }

  return null;
}

_buildFundBottomData(SchemeMetaModel fund,
    {bool isTopUpPortfolio = false,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle}) {
  double minAmount = (isTopUpPortfolio && (fund.folioOverview?.exists ?? false))
      ? fund.minAddDepositAmt!
      : fund.minDepositAmt!;

  return [
    BottomData(
        title: getReturnPercentageText(fund.returns?.oneYrRtrns),
        subtitle: "Last 1 Year",
        align: BottomDataAlignment.left,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        flex: 1),
    BottomData(
        title: getReturnPercentageText(fund.returns?.threeYrRtrns),
        subtitle: "Last 3 Years",
        align: BottomDataAlignment.left,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        flex: 1),
    BottomData(
      title: getReturnPercentageText(fund.returns?.fiveYrRtrns),
      subtitle: "Last 5 Years",
      align: BottomDataAlignment.left,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      // flex: 1
    ),
    BottomData(
        customTitle: buildExitLoadDescription(fund),
        subtitle: "Exit Load",
        align: BottomDataAlignment.left,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        flex: 1),
    BottomData(
        title: "${fund.expenseRatio?.toStringAsFixed(2)}%",
        subtitle: "Expense Ratio",
        align: BottomDataAlignment.left,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        flex: 1),
    BottomData(
      title: WealthyAmount.currencyFormat(minAmount.toStringAsFixed(0), 0,
          showSuffix: false),
      subtitle: "Min Amount",
      align: BottomDataAlignment.left,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      // flex: 1
    )
  ];
}

_buildPortfolioBottomData(product, {bool isShownOnStore = false}) {
  return [
    BottomData(
      title: getReturnPercentageText(product.pastOneYearReturns),
      subtitle: "Last 1 Year",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: getReturnPercentageText(product.pastThreeYearReturns),
      subtitle: "Last 3 Years",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: getReturnPercentageText(product.pastFiveYearReturns),
      subtitle: "Last 5 Years",
      flex: 1,
      align: BottomDataAlignment.right,
    ),
    BottomData(
      title: "${product.term ?? 0} years",
      subtitle: "Horizon",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    if (isShownOnStore)
      BottomData(
        title: "${(product.avgReturns * 100).toStringAsFixed(2)}%",
        subtitle: "Avg Returns",
        flex: 1,
        align: BottomDataAlignment.left,
      )
    else
      BottomData(
        title:
            "${(product.minReturns * 100).toStringAsFixed(2)} - ${(product.maxReturns * 100).toStringAsFixed(2)}%",
        subtitle: "Historical Returns",
        flex: 1,
        align: BottomDataAlignment.left,
      ),
    BottomData(
      title: WealthyAmount.currencyFormat(
        product.minAmount,
        product.minAmount % 1000 == 0 ? 0 : 1,
      ),
      subtitle: "Min Amount",
      flex: 1,
      align: BottomDataAlignment.right,
    ),
  ];
}

_buildPreIPOBottomData(product) {
  return [
    BottomData(
      title: WealthyAmount.formatWithoutTrailingZero(
        product.minSellPrice,
        2,
        addCurrency: true,
      ),
      subtitle: "Min Sale Price",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    // data should be multiple of 3
    BottomData(
      title: WealthyAmount.formatWithoutTrailingZero(
        product.maxSellPrice,
        2,
        addCurrency: true,
      ),
      subtitle: "Max Sell Price",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: WealthyAmount.currencyFormat(
        product.minPurchaseAmount,
        product.minPurchaseAmount % 1000 == 0 ? 0 : 1,
      ),
      subtitle: "Min Purchase Amount",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
  ];
}

_buildFixedDepositBottomData(FixedDepositModel product) {
  return [
    BottomData(
      title: product.tenure ?? '-',
      subtitle: "Tenures",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    if (product.icraRating.isNotNullOrEmpty)
      BottomData(
        title: product.icraRating,
        subtitle: "ICRA Rating",
        flex: 1,
        align: BottomDataAlignment.left,
      ),
    if (product.minPurchaseAmount != null)
      BottomData(
        title: WealthyAmount.currencyFormat(
            product.minPurchaseAmount.toString(), 0),
        subtitle: "Min Amount",
        flex: 1,
        align: BottomDataAlignment.left,
      ),
    BottomData(
      title: product.rateOfInterest ?? '-',
      subtitle: "ROI",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: "",
      subtitle: "",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: "",
      subtitle: "",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
  ];
}

_buildDebentureBottomData(DebentureModel product) {
  String tradeDateFormatted = '-';
  String paymentEndDateFormatted = '-';

  if (product.tradeDate != null) {
    DateTime tradeDateParsed = DateTime.parse(product.tradeDate!);
    tradeDateFormatted = DateFormat('dd-MMM-yy').format(tradeDateParsed);
  }

  if (product.paymentEndDate != null) {
    DateTime paymentEndDateParsed = DateTime.parse(product.paymentEndDate!);
    paymentEndDateFormatted =
        DateFormat('dd-MMM-yy').format(paymentEndDateParsed);
  }

  return [
    BottomData(
      title: paymentEndDateFormatted,
      subtitle: "Last Payment Date",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
    BottomData(
      title: tradeDateFormatted,
      subtitle: "Trade Date",
      flex: 1,
    ),
    // data should be multiple of 3
    BottomData(
      title: WealthyAmount.currencyFormat(
        product.sellPrice,
        0,
      ),
      subtitle: "Price per unit",
      flex: 1,
      align: BottomDataAlignment.left,
    ),
  ];
}

_buildPMSVariantBottomData(
  PMSVariantModel product, {
  TextStyle? titleStyle,
  TextStyle? subtitleStyle,
}) {
  return [
    BottomData(
      title: product.minPurchaseAmount != null
          ? WealthyAmount.currencyFormat(product.minPurchaseAmount, 1)
          : '-',
      subtitle: 'Min Investment',
      flex: 2,
      align: BottomDataAlignment.left,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
    ),
    Spacer(),
    BottomData(
      title: product.minTopupAmount != null
          ? WealthyAmount.currencyFormat(product.minTopupAmount, 1)
          : '-',
      subtitle: 'Min Top up Amount',
      flex: 2,
      align: BottomDataAlignment.left,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
    )
  ];
}
