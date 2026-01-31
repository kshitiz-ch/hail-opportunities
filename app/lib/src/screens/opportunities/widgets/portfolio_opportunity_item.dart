import 'package:app/src/screens/opportunities/widgets/portfolio_review_bottomsheet.dart';
import 'package:flutter/material.dart';

class PortfolioOpportunityItem extends StatelessWidget {
  final dynamic client;
  final String initials;
  final String name;
  final int fundsLagging;
  final String value;
  final Color color;

  const PortfolioOpportunityItem({
    Key? key,
    required this.client,
    required this.initials,
    required this.name,
    required this.fundsLagging,
    required this.value,
    this.color = const Color(0xFFE9D5FF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF6B46E5),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fundsLagging Funds Lagging',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Value: $value',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Funds Button
          ElevatedButton(
            onPressed: () {
              PortfolioReviewBottomSheet.show(context, client);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              backgroundColor: const Color(0xfff9fafb),
              foregroundColor: const Color(0xFF2D3748),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Color(0xFFe0e5eb),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'View Funds',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
