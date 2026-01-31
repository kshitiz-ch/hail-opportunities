// import 'package:flutter/material.dart';

// class OpportunitiesInsurance extends StatelessWidget {
//   final VoidCallback? onViewAll;
//   final List<InsuranceLead>? items;
//   final Function(String leadId)? onLeadTapped;

//   const OpportunitiesInsurance({
//     Key? key,
//     this.onViewAll,
//     this.items,
//     this.onLeadTapped,
//   }) : super(key: key);

//   final List<InsuranceLead> defaultItems = const [
//     InsuranceLead(
//       leadId: '1',
//       clientName: 'Suresh Kumar',
//       initials: 'SK',
//       badge: 'Ultra HNI',
//       badgeColor: Color(0xFF7C3AED),
//       score: 95,
//       gap: '₹75,000',
//     ),
//     InsuranceLead(
//       leadId: '2',
//       clientName: 'Amit Sharma',
//       initials: 'AS',
//       badge: 'HNI',
//       badgeColor: Color(0xFF7C3AED),
//       score: 92,
//       gap: '₹60,000',
//     ),
//     InsuranceLead(
//       leadId: '3',
//       clientName: 'Priya Menon',
//       initials: 'PM',
//       badge: 'High Net Worth',
//       badgeColor: Color(0xFFF59E0B),
//       score: 88,
//       gap: '₹50,000',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final displayItems = items ?? defaultItems;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'High Value Insurance Leads',
//                   style:
//                       Theme.of(context).primaryTextTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
//                           ),
//                 ),
//                 GestureDetector(
//                   onTap: onViewAll,
//                   child: Text(
//                     'View All >',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: const Color(0xFF7C3AED),
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           // Items List
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: displayItems.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final item = displayItems[index];
//               return _buildLeadItem(context, item);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeadItem(BuildContext context, InsuranceLead item) {
//     return GestureDetector(
//       onTap: () {
//         onLeadTapped?.call(item.leadId);
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           children: [
//             // Avatar with initials
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEDE9FE),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(
//                 child: Text(
//                   item.initials,
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                         color: const Color(0xFF7C3AED),
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Client info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         item.clientName,
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[800],
//                             ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: item.badgeColor.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           item.badge,
//                           style:
//                               Theme.of(context).textTheme.labelSmall?.copyWith(
//                                     color: item.badgeColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Score: ${item.score}',
//                           style:
//                               Theme.of(context).textTheme.bodySmall?.copyWith(
//                                     color: Colors.grey[700],
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                         ),
//                         TextSpan(
//                           text: '  Gap: ${item.gap}',
//                           style:
//                               Theme.of(context).textTheme.bodySmall?.copyWith(
//                                     color: Colors.grey[600],
//                                   ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Icon(
//               Icons.chevron_right,
//               color: Colors.grey[400],
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class InsuranceLead {
//   final String leadId;
//   final String clientName;
//   final String initials;
//   final String badge;
//   final Color badgeColor;
//   final int score;
//   final String gap;

//   const InsuranceLead({
//     required this.leadId,
//     required this.clientName,
//     required this.initials,
//     required this.badge,
//     required this.badgeColor,
//     required this.score,
//     required this.gap,
//   });
// }

import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/views/opportunities_insurance_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesInsurance extends StatelessWidget {
  const OpportunitiesInsurance({Key? key}) : super(key: key);

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
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final insuranceOpps =
            controller.insuranceOpportunities?.opportunities ?? [];

        if (insuranceOpps.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    'High Value Insurance Leads',
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
                              const OpportunitiesInsuranceScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF6725F4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF6725F4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider line
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),

              // Insurance Lead Items - Dynamic from API (max 3 items)
              ...List.generate(
                  insuranceOpps.length > 3 ? 3 : insuranceOpps.length, (index) {
                final opp = insuranceOpps[index];
                final category = _getClientCategory(opp.mfCurrentValue);
                final style = _getCategoryStyle(category);

                return Column(
                  children: [
                    if (index > 0) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                    ],
                    _buildInsuranceLeadItem(
                      context,
                      initials: _getInitials(opp.userName),
                      name: opp.userName,
                      score: opp.coveragePercentage.toInt(),
                      gap: _formatCurrency(opp.premiumOpportunityValue),
                      badgeText: category,
                      badgeColor: style['bgColor'] as Color,
                      badgeTextColor: style['textColor'] as Color,
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

  Widget _buildInsuranceLeadItem(
    BuildContext context, {
    required String initials,
    required String name,
    required int score,
    required String gap,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return InkWell(
      onTap: () {
        // AutoRouter.of(context).push(
        //   InsuranceDetailRoute(productVariant: InsuranceProductVariant.QUOTE),
        // );
        AutoRouter.of(context).push(InsuranceGenerateQuotesRoute(
          productVariant: InsuranceProductVariant.HEALTH,
          insuranceData: null,
          selectedClient: null,
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  initials,
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            color: badgeTextColor,
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
                        '$score',
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
                        gap,
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
  }
}
