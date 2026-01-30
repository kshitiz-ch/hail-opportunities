import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/insurance_investment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget getInvestmentProductBottomSheet(BuildContext context,
    {String? productType, productData}) {
  if (productType == "mld") {
    return _buildDebentureBottomSheet(context, productData);
  }

  if (productType == "unlistedstock") {
    return _buildUnlistedStockBottomSheet(context, productData);
  }

  if (productType == "pms") {
    return _buildPmsBottomSheet(context, productData);
  }

  if (productType == "fd") {
    return _buildFixedDepositBottomSheet(context, productData);
  }

  if (productType == "motor") {
    return _buildMotorInsuranceBottomSheet(context, productData);
  }

  // if (productType == "term" || productType == "savings") {
  //   return _buildTermSavingsBottomSheet(productData);
  // }

  if (productType == "health") {
    return _buildHealthInsuranceBottomSheet(context, productData);
  }

  return SizedBox();
}

_buildDebentureBottomSheet(
    BuildContext context, DebentureInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.schemeName!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          'ISIN · ${data.isin}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12, color: ColorConstants.tertiaryBlack, height: 1.4),
        ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Invested Value",
            subtitle:
                WealthyAmount.currencyFormat(data.currentInvestedValue, 0),
          ),
          GridData(
            title: "Current Value",
            subtitle: WealthyAmount.currencyFormat(data.currentValue, 0),
          ),
          if (data.issueDate != null)
            GridData(
              title: "Issue Date",
              subtitle: DateFormat('dd-MM-yyyy').format(data.issueDate!),
            ),
          if (data.maturityDate != null)
            GridData(
              title: "Maturity Date",
              subtitle: DateFormat('dd-MM-yyyy').format(data.maturityDate!),
            ),
          if (data.isMatured!)
            GridData(
              title: "Matured",
              subtitle: data.isMatured.toString().toLowerCase() == "true"
                  ? "Yes"
                  : "No",
            ),
        ],
      ),
    ],
  );
}

_buildUnlistedStockBottomSheet(
    BuildContext context, UnlistedStockInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.securityName!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          'ISIN · ${data.isin}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12, color: ColorConstants.tertiaryBlack, height: 1.4),
        ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Invested Value",
            subtitle:
                WealthyAmount.currencyFormat(data.currentInvestedValue, 0),
          ),
          GridData(
            title: "Current Value",
            subtitle: WealthyAmount.currencyFormat(data.currentValue, 0),
          ),
          if (data.settlementDate != null)
            GridData(
              title: "Settlement Date",
              subtitle: DateFormat('dd-MM-yyyy').format(data.settlementDate!),
            ),
        ],
      ),
    ],
  );
}

_buildFixedDepositBottomSheet(
    BuildContext context, FixedDepositInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.provider!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Invested Value",
            subtitle:
                WealthyAmount.currencyFormat(data.currentInvestedValue, 0),
          ),
          GridData(
            title: "Payout frequency",
            subtitle: data.payoutFrequency,
          ),
          GridData(
            title: "ROI",
            subtitle: getReturnPercentageText(data.returnsInterestRate),
          ),
          // TODO: Check how tenure months is coming from backend
          GridData(
            title: "Tenure Months",
            subtitle: data.tenureMonths,
          )
        ],
      ),
    ],
  );
}

_buildPmsBottomSheet(BuildContext context, PmsInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.pmsName!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          data.manufacturer!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12, color: ColorConstants.tertiaryBlack, height: 1.4),
        ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Invested Value",
            subtitle:
                WealthyAmount.currencyFormat(data.currentInvestedValue, 0),
          ),
          GridData(
            title: "Current Value",
            subtitle: WealthyAmount.currencyFormat(data.currentValue, 0),
          ),
          if (data.accountOpenedAt != null)
            GridData(
              title: "Account Opened",
              subtitle: DateFormat('dd-MM-yyyy').format(data.accountOpenedAt!),
            ),
          GridData(
            title: "Current IRR",
            subtitle: data.currentIrr.toString() + '%',
          ),
          if (data.asOnDate != null)
            GridData(
              title: "As on Date",
              subtitle: DateFormat('dd-MM-yyyy').format(data.asOnDate!),
            ),
          GridData(
            title: "Client ID",
            subtitle: data.pmsClientId,
          )
        ],
      ),
    ],
  );
}

_buildMotorInsuranceBottomSheet(
    BuildContext context, MotorInsuranceInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.productDetails!.productDisplayName!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          data.insuranceType!.toTitleCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12, color: ColorConstants.tertiaryBlack, height: 1.4),
        ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Policy Number",
            subtitle: data.policyNumber,
          ),
          if (data.policyStartDate != null)
            GridData(
              title: "Policy Start Date",
              subtitle: DateFormat('dd-MM-yyyy').format(data.policyStartDate!),
            ),
          if (data.expiryDate != null)
            GridData(
              title: "Expiry Date",
              subtitle: DateFormat('yyyy mm dd').format(data.expiryDate!),
            ),
          GridData(
            title: "Premium Amount",
            subtitle: WealthyAmount.currencyFormat(data.premiumAmount, 0),
          ),
          if (data.renewalDate != null)
            GridData(
              title: "Renewal Date",
              subtitle: DateFormat('yyyy mm dd').format(data.renewalDate!),
            ),
          GridData(
            title: "Reg Number",
            subtitle: data.vehicleRegistrationNumber,
          ),
          GridData(
            title: "Vehicle Model",
            subtitle: data.vehicleModel,
          )
        ],
      ),
    ],
  );
}

_buildHealthInsuranceBottomSheet(
    BuildContext context, HealthInsuranceInvestmentModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        data.plan!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          data.insuranceType!.toTitleCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: 12, color: ColorConstants.tertiaryBlack, height: 1.4),
        ),
      ),
      SizedBox(height: 44),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Person Insurance",
            subtitle:
                data.personInsured.isNotNullOrEmpty ? data.personInsured : '-',
          ),
          if (data.policyStartDate != null)
            GridData(
              title: "Policy Start Date",
              subtitle: data.policyStartDate != null
                  ? DateFormat('dd-MM-yyyy').format(data.policyStartDate!)
                  : '-',
            ),
          if (data.expiryDate != null)
            GridData(
              title: "Expiry Date",
              subtitle: data.expiryDate != null
                  ? DateFormat('yyyy mm dd').format(data.expiryDate!.toLocal())
                  : '-',
            ),
          GridData(
            title: "Premium Amount",
            subtitle: WealthyAmount.currencyFormat(data.premiumAmount, 0),
          ),
          if (data.renewalDate != null)
            GridData(
              title: "Renewal Date",
              subtitle: data.renewalDate != null
                  ? DateFormat('yyyy mm dd').format(data.renewalDate!)
                  : '-',
            ),
          GridData(
            title: "Multiplier Benefit",
            subtitle: data.multiplierBenefit.isNotNullOrEmpty
                ? data.multiplierBenefit
                : '-',
          ),
          GridData(
            title: "Sum Insured",
            subtitle: WealthyAmount.currencyFormat(data.sumInsured, 0),
          ),
          GridData(
            title: "Total Sum Insured",
            subtitle: WealthyAmount.currencyFormat(data.totalSumInsured, 0),
          ),
        ],
      ),
    ],
  );
}
