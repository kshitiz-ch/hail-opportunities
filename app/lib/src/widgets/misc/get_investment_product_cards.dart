import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/clients/client_detail/widgets/investment_list_bottomsheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/insurance_investment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget getInvestmentProductCard(BuildContext context,
    {String? productType, productData}) {
  if (productType == "mld") {
    return _buildDebentureInvestmentCard(context, productData, productType);
  }

  if (productType == "unlistedstock") {
    return _buildUnlistedStockInvestmentCard(context, productData, productType);
  }

  if (productType == "pms") {
    return _buildPmsInvestmentCard(context, productData, productType);
  }

  if (productType == "fd") {
    return _buildFixedDepositInvestmentCard(context, productData, productType);
  }

  if (productType == "motor") {
    return _buildMotorInsuranceInvestmentCard(
        context, productData, productType);
  }

  if (productType == "term" || productType == "savings") {
    return _buildTermSavingsInvestmentCard(context, productData, productType);
  }

  if (productType == "health") {
    return _buildHealthInsuranceInvestmentCard(
        context, productData, productType);
  }

  return SizedBox();
}

_buildDebentureInvestmentCard(BuildContext context,
    DebentureInvestmentModel productData, String? productType) {
  String? maturityDateFormatted;
  if (productData.maturityDate != null) {
    try {
      maturityDateFormatted =
          DateFormat('dd-MM-yyyy').format(productData.maturityDate!);
    } catch (error) {
      LogUtil.printLog(error);
    }
  }
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.schemeName,
    titleMaxLines: 3,
    description: 'ISIN · ${productData.isin}',
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
            productData: productData,
            productType: productType,
          ));
      // AutoRouter.of(context).push(
      //   DebentureDetailRoute(
      //     client: client,
      //     product: product,
      //   ),
      // );
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.currentValue, 0),
        subtitle: "Current Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      if (maturityDateFormatted.isNotNullOrEmpty)
        BottomData(
          title: maturityDateFormatted,
          subtitle: "Maturity Date",
          align: BottomDataAlignment.left,
          flex: 1,
        ),
      BottomData(
        title:
            WealthyAmount.currencyFormat(productData.currentInvestedValue, 0),
        subtitle: "Invested Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
    ],
    // leadingWidget: ,
  );
}

_buildUnlistedStockInvestmentCard(BuildContext context,
    UnlistedStockInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.securityName,
    titleMaxLines: 3,
    description: 'ISIN · ${productData.isin}',
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
      // AutoRouter.of(context).push(
      //   DebentureDetailRoute(
      //     client: client,
      //     product: product,
      //   ),
      // );
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.currentValue, 0),
        subtitle: "Current Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title:
            WealthyAmount.currencyFormat(productData.currentInvestedValue, 0),
        subtitle: "Invested Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title: productData.units.toString(),
        subtitle: "Units",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
    ],
    // leadingWidget: ,
  );
}

_buildPmsInvestmentCard(
    context, PmsInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.pmsName,
    titleMaxLines: 3,
    description: productData.manufacturer,
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.currentValue, 0),
        subtitle: "Current Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title:
            WealthyAmount.currencyFormat(productData.currentInvestedValue, 0),
        subtitle: "Invested Value",
        align: BottomDataAlignment.left,
        flex: 1,
      )
    ],
    // leadingWidget: ,
  );
}

_buildFixedDepositInvestmentCard(BuildContext context,
    FixedDepositInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.provider,
    titleMaxLines: 3,
    description: productData.payoutFrequency,
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.currentValue, 0),
        subtitle: "Current Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title:
            WealthyAmount.currencyFormat(productData.currentInvestedValue, 0),
        subtitle: "Invested Value",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title: getReturnPercentageText(productData.returnsInterestRate),
        subtitle: "Interest Rate",
        align: BottomDataAlignment.left,
        flex: 1,
      )
    ],
    // leadingWidget: ,
  );
}

_buildMotorInsuranceInvestmentCard(BuildContext context,
    MotorInsuranceInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.plan,
    titleMaxLines: 3,
    description: productData.insuranceType!.toTitleCase(),
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.premiumAmount, 0),
        subtitle: "Premium Amount",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title: productData.renewalDate != null
            ? DateFormat('dd/MM/yyyy').format(productData.renewalDate!)
            : '',
        subtitle: "Renewal Date",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
    ],
    // leadingWidget: ,
  );
}

_buildTermSavingsInvestmentCard(BuildContext context,
    TermSavingsInsuranceInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: productData.plan,
    titleMaxLines: 3,
    description: productData.insuranceType!.toTitleCase(),
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.sumAssured, 0),
        subtitle: "Sum Insured",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title: WealthyAmount.currencyFormat(productData.annualPremium, 0),
        subtitle: "Annual Premium",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
    ],
    // leadingWidget: ,
  );
}

_buildHealthInsuranceInvestmentCard(BuildContext context,
    HealthInsuranceInvestmentModel productData, String? productType) {
  return ProductCardNew(
    bgColor: ColorConstants.primaryCardColor,
    title: '${productData.plan} Insurance',
    titleMaxLines: 3,
    description: productData.insuranceType!.toTitleCase(),
    onTap: () async {
      await CommonUI.showBottomSheet(context,
          child: InvestmentProductBottomSheet(
              productData: productData, productType: productType));
    },
    bottomData: [
      BottomData(
        title: WealthyAmount.currencyFormat(productData.sumInsured, 0),
        subtitle: "Sum Insured",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
      BottomData(
        title: WealthyAmount.currencyFormat(productData.premiumAmount, 0),
        subtitle: "Premium Amount",
        align: BottomDataAlignment.left,
        flex: 1,
      ),
    ],
    // leadingWidget: ,
  );
}
