import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/opportunities/models/portfolio_opportunity_model.dart';
import 'package:flutter/material.dart';

class PortfolioReviewBottomSheet extends StatelessWidget {
  final PortfolioClient client;

  const PortfolioReviewBottomSheet({
    Key? key,
    required this.client,
  }) : super(key: key);

  static void show(BuildContext context, PortfolioClient client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PortfolioReviewBottomSheet(client: client),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  double _calculateAverageXirrLag() {
    if (client.underperformingSchemes.isEmpty) return 0;
    final totalLag = client.underperformingSchemes.fold<double>(
      0,
      (sum, scheme) => sum + scheme.xirrUnderperformance,
    );
    return totalLag / client.underperformingSchemes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Portfolio Diagnosis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFED7AA),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAD5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_down,
                        size: 20,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Identified '),
                            TextSpan(
                              text:
                                  '${client.numberOfUnderperformingSchemes} funds',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' contributing to a '),
                            TextSpan(
                              text:
                                  '${_calculateAverageXirrLag().abs().toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                                text:
                                    ' XIRR lag. Generate a review report to analyze next steps.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Underperforming Schemes
              const Text(
                'Underperforming Schemes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic list of underperforming schemes
              ...List.generate(
                client.underperformingSchemes.length,
                (index) {
                  final scheme = client.underperformingSchemes[index];
                  return Column(
                    children: [
                      if (index > 0)
                        const Divider(height: 32, color: Color(0xFFE5E7EB)),
                      _buildFundItem(
                        name: scheme.schemeName,
                        value: _formatCurrency(scheme.currentValue),
                        performance:
                            '${scheme.xirrUnderperformance.toStringAsFixed(1)}%',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Generate Portfolio Review Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    AutoRouter.of(context).push(PortfolioReviewRoute(
                        client: NewClientModel.fromJson({
                      'user_id': client.userId,
                      'customer_id': client.userId,
                      'name': client.clientName
                    })));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryAppColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.description_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate Portfolio Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundItem({
    required String name,
    required String value,
    required String performance,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Value: $value',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              performance,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'vs Bench',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
