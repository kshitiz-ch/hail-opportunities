import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RebalanceScheduleCard extends StatelessWidget {
  final WealthcaseModel? wealthcaseModel;
  final VoidCallback? onHelpTap;
  final VoidCallback? onWealthcaseInfoTap;

  const RebalanceScheduleCard({
    Key? key,
    required this.wealthcaseModel,
    this.onHelpTap,
    this.onWealthcaseInfoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorConstants.borderColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rebalance Schedule',
                style: context.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildScheduleInfo(context),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: _buildDivider(),
        ),
        // _buildHelpSection(context),
        // const SizedBox(height: 16),
        _buildWealthcaseInfo(context),
      ],
    );
  }

  Widget _buildScheduleInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          'Rebalance Frequency',
          wealthcaseModel?.displayReviewFrequency ?? '-',
          context,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'Last Rebalance',
          _formatDate(wealthcaseModel?.lastReviewedAt),
          context,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'Next Rebalance',
          _formatDate(wealthcaseModel?.nextReviewDate),
          context,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.titleLarge?.copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: context.titleLarge?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: List.generate(
        150 ~/ 2,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index % 2 == 0
                ? ColorConstants.tertiaryBlack
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  // Widget _buildHelpSection(BuildContext context) {
  //   return GestureDetector(
  //     onTap: onHelpTap,
  //     child: Center(
  //       child: RichText(
  //         textAlign: TextAlign.center,
  //         text: TextSpan(
  //           style: context.titleLarge?.copyWith(
  //             color: ColorConstants.tertiaryBlack,
  //             fontWeight: FontWeight.w500,
  //           ),
  //           children: [
  //             const TextSpan(text: 'Need Help? '),
  //             TextSpan(
  //               text: 'Watch this video on how to Subscribe.',
  //               style: context.titleLarge?.copyWith(
  //                 color: ColorConstants.primaryAppColor,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWealthcaseInfo(BuildContext context) {
    return GestureDetector(
      onTap: onWealthcaseInfoTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What is Wealthcase?',
            style: context.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.info_outline,
            size: 20,
            color: ColorConstants.tertiaryBlack,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('MMMM yyyy').format(date);
  }
}
