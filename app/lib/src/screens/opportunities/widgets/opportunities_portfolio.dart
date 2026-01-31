import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/views/opportunities_portfolio_screen.dart';
import 'package:app/src/screens/opportunities/widgets/portfolio_opportunity_item.dart';
import 'package:app/src/screens/opportunities/widgets/portfolio_review_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesPortfolio extends StatelessWidget {
  const OpportunitiesPortfolio({Key? key}) : super(key: key);

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
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final portfolioClients =
            controller.portfolioOpportunities?.clients ?? [];

        if (portfolioClients.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OpportunitiesPortfolioScreen(),
                        ),
                      );
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

              // Portfolio Items - Dynamic from API (max 3 items)
              ...List.generate(
                  portfolioClients.length > 3 ? 3 : portfolioClients.length,
                  (index) {
                final client = portfolioClients[index];
                return Column(
                  children: [
                    if (index > 0) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                    ],
                    PortfolioOpportunityItem(
                      client: client,
                      initials: _getInitials(client.clientName),
                      name: client.clientName,
                      fundsLagging: client.numberOfUnderperformingSchemes,
                      value: _formatCurrency(client.totalValueUnderperforming),
                      color: const Color(0xFFE9D5FF),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
