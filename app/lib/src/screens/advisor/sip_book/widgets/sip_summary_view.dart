import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/current_month_sip_graph.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/monthly_sip_graph.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/offline_sip_metrics.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_month_metrics.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipSummaryView extends StatelessWidget {
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    titleStyle = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    subtitleStyle = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          fontSize: 18,
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
        );
    return SingleChildScrollView(
      child: GetBuilder<SipBookController>(
          id: 'sip-metric',
          builder: (controller) {
            if (controller.sipMetricResponse.state == NetworkState.loading) {
              return SkeltonLoaderCard(height: 300, radius: 0);
            }

            if (controller.sipMetricResponse.state == NetworkState.error) {
              return RetryWidget(
                controller.sipMetricResponse.message,
                onPressed: () {
                  controller.getSipMetrics();
                },
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline SIP Section
                OfflineSipMetrics(sipAggregate: controller.sipAggregate),
                // Online SIP Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32)
                      .copyWith(top: 8),
                  child: Text(
                    'Online SIPs',
                    style: context.headlineMedium?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildSipSummary(context, controller.sipAggregate),
                SipMonthMetric(sipAggregate: controller.sipAggregate),
                CurrentMonthSipGraph(),
                MonthlySipGraph(),
                SizedBox(height: 50),
              ],
            );
          }),
    );
  }

  Widget _buildSipSummary(
      BuildContext context, SipAggregateModel? sipAggregate) {
    final activeSipCount = sipAggregate?.activeSip?.count ?? 0;
    final activeSipDebit = sipAggregate?.activeSip?.transactions ?? 0;
    final activeSipAmount =
        WealthyAmount.currencyFormat(sipAggregate?.activeSip?.amount, 1);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: _buildSummaryHeader(
                    title: 'Active SIPs',
                    subtitle: activeSipCount.toString(),
                    totalDebits: activeSipDebit,
                    tooltip:
                        'SIPs within their scheduled end dates, with active client mandates, and not paused',
                  ),
                ),
              ),
              CommonUI.buildProfileDataSeperator(
                height: 80,
                width: 1,
                color: ColorConstants.borderColor,
              ),
              Expanded(
                child: Center(
                  child: _buildSummaryHeader(
                    title: 'Total SIP Amount',
                    subtitle: activeSipAmount,
                  ),
                ),
              ),
            ],
          ),
          CommonUI.buildProfileDataSeperator(
            color: ColorConstants.borderColor,
            width: double.infinity,
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildSummaryDetail(sipAggregate),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryHeader({
    required String title,
    required String subtitle,
    int? totalDebits,
    String? tooltip,
  }) {
    final subtitle2 = totalDebits == null
        ? ''
        : totalDebits > 1
            ? ' ( $totalDebits SIP Debits )'
            : ' ( $totalDebits SIP Debit )';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tooltip.isNotNullOrEmpty)
          CommonUI.buildInfoToolTip(
            toolTipMessage: tooltip!,
            titleStyle: titleStyle,
            titleText: title,
            rightPadding: 10,
          )
        else
          Text(title, style: titleStyle),
        SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: subtitle,
            style: subtitleStyle,
            children: [
              if (subtitle2.isNotNullOrEmpty)
                TextSpan(
                  text: subtitle2,
                  style: subtitleStyle?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryDetail(SipAggregateModel? sipAggregate) {
    Widget _buildDetailRow({
      required String title,
      required String subtitle,
      String? subtitle2,
      required String iconPath,
    }) {
      return Row(
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title, style: titleStyle),
            ),
          ),
          Text(
            subtitle,
            style: subtitleStyle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              subtitle2 ?? '',
              style: subtitleStyle?.copyWith(fontSize: 14),
            ),
          )
        ],
      );
    }

    final uniqueClientSip =
        sipAggregate?.uniqueClientsWithActiveSips?.count ?? 0;
    final sipRegisteredMonth = sipAggregate?.newCurrentMonthSip;
    final sipPausedMonth = sipAggregate?.pausedCurrentMonth;
    final eMandatePending = sipAggregate?.unsuccessfulMandateSips;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          iconPath: AllImages().sipClientIcon,
          title: 'Unique Clients with Active SIP(s)',
          subtitle: uniqueClientSip.toString(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildDetailRow(
            iconPath: AllImages().monthlySipIcon,
            title: 'SIP(s) Registered this month',
            subtitle: '${sipRegisteredMonth?.count ?? 0}',
            subtitle2:
                '( ${WealthyAmount.currencyFormat(sipRegisteredMonth?.amount, 1)} )',
          ),
        ),
        _buildDetailRow(
          iconPath: AllImages().sipPausedIcon,
          title: 'SIP(s) Paused this month',
          subtitle: '${sipPausedMonth?.count ?? 0}',
          subtitle2:
              '( ${WealthyAmount.currencyFormat(sipPausedMonth?.amount, 1)} )',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildDetailRow(
            iconPath: AllImages().sipPendingIcon,
            title: 'SIP(s) E Mandate Pending',
            subtitle: '${eMandatePending?.count ?? 0}',
          ),
        ),
      ],
    );
  }
}
