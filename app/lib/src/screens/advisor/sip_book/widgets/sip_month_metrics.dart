import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:flutter/material.dart';

class SipMonthMetric extends StatelessWidget {
  final SipAggregateModel? sipAggregate;
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;

  SipMonthMetric({Key? key, this.sipAggregate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    titleStyle = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    subtitleStyle = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
        );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.all(20),
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3.4,
            children: [
              _buildMonthMetric(
                context: context,
                title: 'Total SIP Debit Amount',
                subtitle: WealthyAmount.currencyFormat(
                    sipAggregate?.currentMonthAggregate?.amount, 1),
              ),
              _buildMonthMetric(
                context: context,
                title: 'Total SIP Debits',
                subtitle: '${sipAggregate?.currentMonthAggregate?.count ?? 0}',
              ),
              _buildMonthMetric(
                context: context,
                title: 'Successful',
                subtitle: WealthyAmount.currencyFormat(
                    sipAggregate?.wonSip?.amount, 1),
                totalDebits: sipAggregate?.wonSip?.count ?? 0,
                toolTipMessage: 'SIPs debits for which NAV is allocated',
              ),
              _buildMonthMetric(
                context: context,
                title: 'Inprogress',
                subtitle: WealthyAmount.currencyFormat(
                    sipAggregate?.inprogressSip?.amount, 1),
                totalDebits: sipAggregate?.inprogressSip?.count ?? 0,
                toolTipMessage: 'SIPs debit successful, Nav allocation pending',
              ),
              _buildMonthMetric(
                context: context,
                title: 'Pending',
                subtitle: WealthyAmount.currencyFormat(
                    sipAggregate?.pendingSip?.amount, 1),
                totalDebits: sipAggregate?.pendingSip?.count ?? 0,
                toolTipMessage: 'SIPs yet to be debited this month',
              ),
              _buildMonthMetric(
                context: context,
                title: 'Failed',
                subtitle: WealthyAmount.currencyFormat(
                    sipAggregate?.failedSip?.amount, 1),
                totalDebits: sipAggregate?.failedSip?.count ?? 0,
                toolTipMessage: 'Failed SIP Debits',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final text = getMonthDescription(DateTime.now().month);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ColorConstants.primaryCardColor,
      child: Row(
        children: [
          Image.asset(
            AllImages().monthlySipIcon2,
            height: 18,
            width: 18,
          ),
          SizedBox(width: 8),
          Text(
            "$text's Metrics",
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          )
        ],
      ),
    );
  }

  Widget _buildMonthMetric({
    required BuildContext context,
    required String title,
    required String subtitle,
    int? totalDebits,
    String? toolTipMessage,
  }) {
    final subtitle2 = totalDebits == null
        ? ''
        : totalDebits > 1
            ? ' ( $totalDebits Debits )'
            : ' ( $totalDebits Debit )';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (toolTipMessage.isNotNullOrEmpty)
          CommonUI.buildInfoToolTip(
            toolTipMessage: toolTipMessage!,
            titleStyle: titleStyle,
            titleText: title,
            rightPadding: 10,
          )
        else
          MarqueeWidget(child: Text(title, style: titleStyle)),
        SizedBox(height: 4),
        Row(
          children: [
            Text(subtitle, style: subtitleStyle),
            if (subtitle2.isNotNullOrEmpty)
              Text(
                subtitle2,
                style: subtitleStyle?.copyWith(fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}
