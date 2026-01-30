import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:flutter/material.dart';

class OfflineSipMetrics extends StatefulWidget {
  final SipAggregateModel? sipAggregate;

  const OfflineSipMetrics({super.key, this.sipAggregate});

  @override
  State<OfflineSipMetrics> createState() => _OfflineSipMetricsState();
}

class _OfflineSipMetricsState extends State<OfflineSipMetrics>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state based on whether tile should be expanded
    final hasData = widget.sipAggregate != null &&
        (widget.sipAggregate?.offlineSips?.activeCount ?? 0) > 0;
    if (hasData) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.sipAggregate != null &&
        (widget.sipAggregate?.offlineSips?.activeCount ?? 0) > 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Offline SIPs',
            style: context.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          trailing: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159,
                child: Icon(
                  Icons.expand_more,
                  size: 24.0,
                  color: ColorConstants.black,
                ),
              );
            },
          ),
          childrenPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          initiallyExpanded: hasData,
          onExpansionChanged: (expanded) {
            if (expanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          children: [
            _buildDetailRow(
              title: 'Active SIPs',
              subtitle:
                  widget.sipAggregate?.offlineSips?.activeCount.toString() ??
                      '0',
              icon: Icons.check_circle_outline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDetailRow(
                title: 'Active SIP Amount',
                subtitle: WealthyAmount.currencyFormat(
                    widget.sipAggregate?.offlineSips?.activeMonthlyAmount, 2),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 8),
            //   child: _buildDetailRow(
            //     title: 'Active Monthly Amount',
            //     subtitle:
            //         '~${WealthyAmount.currencyFormat(widget.sipAggregate?.offlineSips?.activeMonthlyAmount, 2)}',
            //     icon: Icons.paid,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildDetailRow(
                title: 'Paused SIPs',
                subtitle:
                    widget.sipAggregate?.offlineSips?.pausedCount.toString() ??
                        '0',
                icon: Icons.pause_circle_outline,
              ),
            ),
            _buildDetailRow(
              title: 'Inactive SIPs',
              subtitle:
                  widget.sipAggregate?.offlineSips?.inactiveCount.toString() ??
                      '0',
              icon: Icons.cancel_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final titleStyle = context.headlineSmall?.copyWith(
      color: ColorConstants.tertiaryBlack,
    );
    final subtitleStyle = context.headlineMedium?.copyWith(
      fontSize: 18,
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ColorConstants.primaryAppColor.withOpacity(0.7),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(title, style: titleStyle),
        ),
        SizedBox(width: 8),
        Text(
          subtitle,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
