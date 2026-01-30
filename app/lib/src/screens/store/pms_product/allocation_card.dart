import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';

class AllocationCard extends StatelessWidget {
  final String title;
  final List<PMSPieChartModel> items;

  const AllocationCard({
    Key? key,
    this.title = 'Allocation',
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final model = items[index];
              final color = _getDefaultColor(index);

              return _buildHoldingItem(
                context: context,
                model: model,
                color: color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem({
    required BuildContext context,
    required PMSPieChartModel model,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Row
        Text(
          model.name ?? '-',
          style: context.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: ColorConstants.black,
          ),
        ),

        SizedBox(height: 12),

        // Progress Bar
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConstants.lightGrey,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (model.value ?? 0) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            Text(
              '${model.value?.toStringAsFixed(2)}%',
              style: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getDefaultColor(int index) {
    final defaultColors = [
      ColorConstants.primaryAppColor, // Purple
      ColorConstants.skyBlue, // Blue
      ColorConstants.tangerineColor, // Orange
      ColorConstants.greenAccentColor, // Green
      ColorConstants.yellowAccentColor, // Yellow
      ColorConstants.redAccentColor, // Red
    ];

    return defaultColors[index % defaultColors.length];
  }
}
