import 'package:flutter/material.dart';

class OpportunitiesOverview extends StatelessWidget {
  const OpportunitiesOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Icon(
                Icons.star_outline,
                size: 20,
                color: const Color(0xFF6725F4),
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
            '₹15.2 Lakhs',
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
            'Identified actionable value across 45 clients, primarily driven by Insurance Gaps.',
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
                  value: '₹10L',
                  label: 'INSURANCE',
                  iconColor: const Color(0xFF6725F4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownCard(
                  icon: Icons.trending_up,
                  value: '₹5L',
                  label: 'SIP RECOVERY',
                  iconColor: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownCard(
                  icon: Icons.bar_chart,
                  value: '₹20K',
                  label: 'REBALANCING',
                  iconColor: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
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
