import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/utils.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';

class PmsProductOverview extends StatelessWidget {
  final PMSVariantModel? product;

  PmsProductOverview({this.product});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text('No product data available'),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Current AUM, Inception Date, Fund Manager
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Current AUM',
                  // AUM is in crore
                  value: '${_getAumDisplay()} Cr',
                  context: context,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Inception Date',
                  value: getFormattedDate(product!.inceptionDate),
                  context: context,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Fund Manager',
                  value: product!.fundManager ?? '-',
                  context: context,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Second row: Min Investment, Management Fee (Fixed),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Min. Investment',
                  value: _getMinInvestmentDisplay(),
                  context: context,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Management Fee - Fixed',
                  value: _getManagementFeeDisplay(),
                  context: context,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Third row: Management Fee (Hybrid) and Exit Load
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: _buildInfoCard(
                  title: 'Management Fee - Hybrid',
                  value: _getHybridFeeDisplay(),
                  context: context,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Exit Load',
                  value: _getExitLoadDisplay(),
                  context: context,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Investment Objective Section
          _buildInvestmentObjectiveSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return CommonUI.buildColumnTextInfo(
      title: title,
      subtitle: value,
      titleStyle: context.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: ColorConstants.tertiaryBlack,
      ),
      subtitleStyle: context.headlineSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: ColorConstants.black,
      ),
    );
  }

  String _getAumDisplay() {
    if (product!.currentAum == null) return '-';

    return WealthyAmount.currencyFormat(product!.currentAum!, 2);
  }

  String _getMinInvestmentDisplay() {
    if (product!.minPurchaseAmount == null) return '-';

    return WealthyAmount.currencyFormat(product!.minPurchaseAmount!, 2);
  }

  String _getManagementFeeDisplay() {
    if (product!.expenseRatio.isNotNullOrEmpty) {
      return formatAsPercentage(product!.expenseRatio);
    }
    return '-';
  }

  String _getHybridFeeDisplay() {
    if (product!.expenseRatioProfitShare.isNotNullOrEmpty) {
      return formatAsPercentage(product!.expenseRatioProfitShare);
    }
    return '-';
  }

  String _getExitLoadDisplay() {
    if (product!.exitLoad.isNotNullOrEmpty) {
      return formatAsPercentage(product!.exitLoad);
    }
    if (product!.exitLoadDisplay.isNotNullOrEmpty) {
      return formatAsPercentage(product!.exitLoadDisplay);
    }
    return '-';
  }

  // Investment Objective Section
  Widget _buildInvestmentObjectiveSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Objective',
          style: context.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: ColorConstants.tertiaryBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          product!.description ?? '-',
          style: context.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: ColorConstants.black,
          ),
        ),
      ],
    );
  }
}
