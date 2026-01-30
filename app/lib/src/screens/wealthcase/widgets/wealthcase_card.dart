import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:flutter/material.dart';

import '../../../config/constants/color_constants.dart';

class WealthcaseCard extends StatelessWidget {
  final WealthcaseModel model;

  const WealthcaseCard({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    final cagrData = getWealthCaseCagrRow(model);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo and risk level
          Row(
            children: [
              // SmartValues logo
              CachedNetworkImage(
                imageUrl: getWealthCaseLogo(model.riaName),
                fit: BoxFit.contain,
                height: 20,
                width: 100,
              ),
              const Spacer(),

              // Risk level
              buildRiskLevel(model.riskProfile ?? '-', context),
            ],
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            (model.viewName ?? '-').toTitleCase(),
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Category tag
          // buildCategoryTag(model.sectors ?? '-', context),

          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: buildStatItem(
                  cagrData.keys.first,
                  cagrData.values.first,
                  context,
                ),
              ),
              Expanded(
                child: buildStatItem(
                  'Min. Investment amount',
                  WealthyAmount.currencyFormat(model.minInvestment?.round(), 0),
                  context,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: buildStatItem(
                  'Subscription Fees',
                  '${model.subscription?.percentage?.toStringAsFixed(2) ?? 0}% of AUM',
                  context,
                ),
              ),
              Expanded(
                child: buildStatItem(
                  'Rebalance Frequency',
                  model.displayReviewFrequency,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildRiskLevel(String riskLevel, BuildContext context) {
  Color getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
      case 'HIGH RISK':
        return ColorConstants.redAccentColor;
      case 'MODERATE':
      case 'MODERATE RISK':
        return ColorConstants.yellowAccentColor;
      case 'LOW':
      case 'LOW RISK':
        return ColorConstants.greenAccentColor;
      default:
        return ColorConstants.tertiaryBlack;
    }
  }

  final riskColor = getRiskColor(riskLevel);
  String riskText = riskLevel.toCapitalized();
  if (!riskText.toLowerCase().contains('risk')) {
    riskText = '$riskText Risk';
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: riskColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      riskText,
      style: context.titleLarge?.copyWith(
        color: riskColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget buildStatItem(String label, String value, BuildContext context) {
  return CommonUI.buildColumnTextInfo(
    title: label,
    subtitle: value,
    gap: 6,
    subtitleMaxLength: 2,
    titleStyle: context.titleLarge?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      height: 1.25,
    ),
    subtitleStyle: context.headlineSmall?.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
      height: 1.25,
    ),
  );
}

Widget buildCategoryTag(String sector, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      border: Border.all(
        color: ColorConstants.borderColor,
        width: 1,
      ),
    ),
    child: Text(
      sector,
      style: context.titleLarge?.copyWith(
        color: ColorConstants.tertiaryBlack,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
