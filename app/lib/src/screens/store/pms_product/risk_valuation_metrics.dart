import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';

class RiskValuationMetrics extends StatelessWidget {
  final PMSVariantModel? product;

  RiskValuationMetrics({this.product});

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text('No product data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: Standard Deviation, Sharpe Ratio, Beta
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _buildInfoCard(
                title: 'Standard Deviation',
                value: _getStandardDeviationDisplay(),
                context: context,
              ),
            ),
            Flexible(
              child: _buildInfoCard(
                title: 'Sharpe Ratio',
                value: _getSharpeRatioDisplay(),
                context: context,
              ),
            ),
            Flexible(
              child: _buildInfoCard(
                title: 'Beta',
                value: _getBetaDisplay(),
                context: context,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Second row: P/E, P/B
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'P/E',
                value: _getPERatioDisplay(),
                context: context,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: 'P/B',
                value: _getPBRatioDisplay(),
                context: context,
              ),
            ),
          ],
        ),
      ],
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

  String _getStandardDeviationDisplay() {
    if (product!.standardDeviation.isNullOrEmpty) {
      return '-';
    }
    return formatAsPercentage(product!.standardDeviation);
  }

  String _getSharpeRatioDisplay() {
    if (product!.sharpeRatio == null) return '-';

    return product!.sharpeRatio!.toStringAsFixed(2);
  }

  String _getBetaDisplay() {
    if (product!.beta == null) return '-';

    return product!.beta!.toStringAsFixed(2);
  }

  String _getPERatioDisplay() {
    if (product!.peRatio == null) return '-';

    return product!.peRatio!.toStringAsFixed(2);
  }

  String _getPBRatioDisplay() {
    if (product!.pbRatio == null) return '-';

    return product!.pbRatio!.toStringAsFixed(2);
  }
}
