import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/screens/store/demat_store/widgets/incentive_term_condition_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncentiveTable extends StatelessWidget {
  const IncentiveTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(builder: (controller) {
      final headlineStyle = Theme.of(context).primaryTextTheme.headlineLarge;
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text.rich(
                TextSpan(
                  text: 'Account Opening Incentives',
                  style: headlineStyle!
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PricingTable(isAuthorized: controller.isAuthorised),
            ),
            Center(child: _buildIncentiveCondition(context)),
          ],
        ),
      );
    });
  }

  Widget _buildTableText(BuildContext context, String text,
      {bool isHeader = false}) {
    TextStyle textStyle;

    if (isHeader) {
      textStyle = Theme.of(context)
          .primaryTextTheme
          .headlineMedium!
          .copyWith(fontWeight: FontWeight.w700);
    } else {
      textStyle = Theme.of(context).primaryTextTheme.headlineSmall!;
    }
    return Expanded(
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

  Widget _buildIncentiveCondition(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'By proceeding I agree to the',
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        ClickableText(
          padding: EdgeInsets.zero,
          text: 'Terms & Conditions',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          onClick: () {
            CommonUI.showBottomSheet(
              context,
              child: IncentiveTermConditionBottomSheet(),
            );
          },
        )
      ],
    );
  }
}

class PricingTable extends StatelessWidget {
  const PricingTable({Key? key, required this.isAuthorized}) : super(key: key);

  final bool isAuthorized;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorConstants.secondarySeparatorColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            _buildHeaderRow(context),
            // Data Rows
            _buildDataRow(
              context,
              'Broking Account Activation',
              '₹200',
              '₹200',
              showNonAuthorizedTooltip: true,
            ),
            Divider(height: 1, color: ColorConstants.secondarySeparatorColor),
            _buildDataRow(context, '₹5K Margin', '₹400', '₹0'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        border: Border(
          bottom: BorderSide(
            color: ColorConstants.secondarySeparatorColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            child: Text(
              'Target',
              style:
                  context.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isAuthorized ? 50 : 0),
              child: Text(
                'Authorised Person',
                style: context.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!isAuthorized)
            Expanded(
              child: Text(
                'Non Authorised Person',
                style: context.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    String target,
    String authorized,
    String nonAuthorized, {
    bool showNonAuthorizedTooltip = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 120,
            child: Text(
              target,
              style:
                  context.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isAuthorized ? 50 : 0),
              child: Text(
                authorized,
                style: context.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!isAuthorized)
            Expanded(
              child: Row(
                children: [
                  Text(
                    nonAuthorized,
                    style: context.headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (showNonAuthorizedTooltip) _buildTooltipIcon(context),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTooltipIcon(BuildContext context) {
    final text =
        'Rs.200 incentive will be applicable to all broking accounts activated on or after 1 Nov 2025. For accounts activated earlier, the incentive will be Rs.100';

    return Padding(
      padding: EdgeInsets.all(4),
      child: Tooltip(
        showDuration: Duration(seconds: 5),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: ColorConstants.black,
            borderRadius: BorderRadius.circular(6)),
        triggerMode: TooltipTriggerMode.tap,
        textStyle: context.titleLarge!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        message: text,
        child: Icon(
          Icons.info_outline,
          color: ColorConstants.primaryAppColor,
          size: 16,
        ),
      ),
    );
  }
}
