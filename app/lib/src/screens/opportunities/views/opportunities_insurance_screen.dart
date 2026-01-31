import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesInsuranceScreen extends StatelessWidget {
  const OpportunitiesInsuranceScreen({Key? key}) : super(key: key);

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

  String _getClientCategory(double mfValue) {
    if (mfValue >= 10000000) return 'Ultra HNI';
    if (mfValue >= 5000000) return 'HNI';
    return 'High Net Worth';
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    if (category == 'Ultra HNI' || category == 'HNI') {
      return {
        'bgColor': const Color(0xFFEDE9FE),
        'textColor': const Color(0xFF6725F4),
      };
    }
    return {
      'bgColor': const Color(0xFFF8EEE2),
      'textColor': const Color(0xFFF98814),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'Insurance Opportunities',
      ),
      body: GetBuilder<OpportunitiesController>(
        builder: (controller) {
          final insuranceOpps =
              controller.insuranceOpportunities?.opportunities ?? [];

          if (insuranceOpps.isEmpty) {
            return const Center(
              child: Text(
                'No insurance opportunities available',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: insuranceOpps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final opp = insuranceOpps[index];
              final category = _getClientCategory(opp.mfCurrentValue);
              final style = _getCategoryStyle(category);

              return InkWell(
                onTap: () {
                  AutoRouter.of(context).push(InsuranceGenerateQuotesRoute(
                    productVariant: InsuranceProductVariant.HEALTH,
                    insuranceData: null,
                    selectedClient: null,
                  ));
                },
                child: Container(
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
                          color: const Color(0xFFEDE9FE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(opp.userName),
                            style: const TextStyle(
                              color: Color(0xFF6725F4),
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
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    opp.userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: style['bgColor'] as Color,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: style['textColor'] as Color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Score: ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2D3748),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${opp.coveragePercentage.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2D3748),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Gap: ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(opp.premiumOpportunityValue),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
