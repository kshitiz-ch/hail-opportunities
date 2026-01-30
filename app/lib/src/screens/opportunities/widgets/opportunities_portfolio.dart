import 'package:app/src/screens/opportunities/widgets/portfolio_review_bottomsheet.dart';
import 'package:flutter/material.dart';

class OpportunitiesPortfolio extends StatelessWidget {
  const OpportunitiesPortfolio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Review Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle view all action
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6B46E5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF6B46E5),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // Portfolio Items
          _buildPortfolioItem(
            context,
            initials: 'RS',
            name: 'Ramesh Shah',
            fundsLagging: 3,
            value: '₹4.4L',
            color: const Color(0xFFE9D5FF),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          _buildPortfolioItem(
            context,
            initials: 'SJ',
            name: 'Suresh Joshi',
            fundsLagging: 5,
            value: '₹9.1L',
            color: const Color(0xFFE9D5FF),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          _buildPortfolioItem(
            context,
            initials: 'AD',
            name: 'Aditi Desai',
            fundsLagging: 2,
            value: '₹3.6L',
            color: const Color(0xFFE9D5FF),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(
    BuildContext context, {
    required String initials,
    required String name,
    required int fundsLagging,
    required String value,
    required Color color,
  }) {
    return Container(
      // padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: const Color(0xFFE5E7EB),
      //     width: 1,
      //   ),
      // ),
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
                    fontSize: 16,
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
              PortfolioReviewBottomSheet.show(context);
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
