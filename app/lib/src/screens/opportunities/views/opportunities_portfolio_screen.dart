import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/portfolio_review_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesPortfolioScreen extends StatelessWidget {
  const OpportunitiesPortfolioScreen({Key? key}) : super(key: key);

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'Portfolio Opportunities',
      ),
      body: GetBuilder<OpportunitiesController>(
        builder: (controller) {
          final portfolioClients =
              controller.portfolioOpportunities?.clients ?? [];

          if (portfolioClients.isEmpty) {
            return const Center(
              child: Text(
                'No portfolio opportunities available',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: portfolioClients.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final client = portfolioClients[index];
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
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9D5FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(client.clientName),
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
                            client.clientName,
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
                                '${client.numberOfUnderperformingSchemes} Funds Lagging',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Value: ${_formatCurrency(client.totalValueUnderperforming)}',
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
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
            },
          );
        },
      ),
    );
  }
}
