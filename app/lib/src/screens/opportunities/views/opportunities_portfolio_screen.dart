import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/portfolio_opportunity_item.dart';
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
                child: PortfolioOpportunityItem(
                  client: client,
                  initials: _getInitials(client.clientName),
                  name: client.clientName,
                  fundsLagging: client.numberOfUnderperformingSchemes,
                  value: _formatCurrency(client.totalValueUnderperforming),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
