import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
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

        // If no data, return empty container
        if (dashboardHero == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  SvgPicture.asset(
                    AllImages().opportunitiesStar,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WEEKLY OPPORTUNITY SCAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Value
              Text(
                dashboardHero.formattedValue,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6725F4),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Total Opportunity Value',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                dashboardHero.executiveSummary,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown Cards
              Row(
                children: [
                  Expanded(
                    child: _buildBreakdownCard(
                      icon: Icons.shield_outlined,
                      value: dashboardHero.opportunityBreakdown.insurance,
                      label: 'INSURANCE',
                      iconColor: const Color(0xFF6725F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBreakdownCard(
                      icon: Icons.trending_up,
                      value: dashboardHero.opportunityBreakdown.sipRecovery,
                      label: 'SIP RECOVERY',
                      iconColor: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBreakdownCard(
                      icon: Icons.bar_chart,
                      value: dashboardHero
                          .opportunityBreakdown.portfolioRebalancing,
                      label: 'REBALANCING',
                      iconColor: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
