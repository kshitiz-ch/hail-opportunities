import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class OpportunitiesOverview extends StatelessWidget {
  const OpportunitiesOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final overview = controller.opportunitiesOverview;
        final dashboardHero = overview?.dashboardHero;

        if (controller.opportunitiesOverviewResponse.state ==
            NetworkState.loading) {
          return Center(child: OpportunitiesLoadingView());
        }

        if (dashboardHero == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F3FF),
                Color(0xFFEDE9FE),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDDD6FE),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryAppColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AllImages().opportunitiesStar,
                          width: 14,
                          height: 14,
                          color: ColorConstants.primaryAppColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'WEEKLY OPPORTUNITY SCAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      controller.getOpportunitiesOverview(forceRefresh: true);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Color(0xFF6725F4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Value - Hero Metric
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _sanitizeCurrency(dashboardHero.formattedValue),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6725F4),
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                'Total Opportunity Value',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(height: 16),

              // Executive Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dashboardHero.executiveSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Breakdown Cards - Equal Width
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 24) / 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildBreakdownCard(
                          icon: Icons.shield_outlined,
                          value: dashboardHero.opportunityBreakdown.insurance,
                          label: 'Insurance',
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildBreakdownCard(
                          icon: Icons.trending_up_rounded,
                          value: dashboardHero.opportunityBreakdown.sipRecovery,
                          label: 'SIP Recovery',
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildBreakdownCard(
                          icon: Icons.pie_chart_outline_rounded,
                          value: dashboardHero.opportunityBreakdown.portfolioRebalancing,
                          label: 'Rebalancing',
                          color: const Color(0xFF6725F4),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Last Updated
              FutureBuilder<DateTime?>(
                future: controller.getCachedOverviewTimestamp(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final timestamp = snapshot.data!;
                    final now = DateTime.now();
                    final difference = now.difference(timestamp);

                    String timeAgo;
                    if (difference.inMinutes < 1) {
                      timeAgo = 'Just now';
                    } else if (difference.inHours < 1) {
                      timeAgo = '${difference.inMinutes}m ago';
                    } else if (difference.inDays < 1) {
                      timeAgo = '${difference.inHours}h ago';
                    } else {
                      timeAgo = '${difference.inDays}d ago';
                    }

                    return Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          'Updated $timeAgo',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _sanitizeCurrency(String value) {
    return value.replaceAll('₹', 'Rs. ').replaceAll('Rs.Rs.', 'Rs.').trim();
  }

  Widget _buildBreakdownCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _sanitizeCurrency(value),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
