// import 'package:flutter/material.dart';
// import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

// class OpportunitiesFocus extends StatefulWidget {
//   final List<FocusItem>? items;
//   final Function(String itemId, String actionType)? onActionTapped;

//   const OpportunitiesFocus({
//     Key? key,
//     this.items,
//     this.onActionTapped,
//   }) : super(key: key);

//   @override
//   State<OpportunitiesFocus> createState() => _OpportunitiesFocusState();
// }

// class _OpportunitiesFocusState extends State<OpportunitiesFocus> {
//   final List<FocusItem> defaultItems = [
//     FocusItem(
//       itemId: '1',
//       clientName: 'Priya Menon',
//       initials: 'PM',
//       badgeLabel: 'PAYMENT STOPPED',
//       badgeColor: const Color(0xFFFEE2E2),
//       badgeTextColor: const Color(0xFFDC2626),
//       primaryValue: '90',
//       primaryLabel: 'Days',
//       isPrimaryWarning: true,
//       description:
//           'Critical: 90 days without SIP payment. Risk of lapse. Contact urgently.',
//       actionLabel: 'Fix Mandate',
//       actionColor: const Color(0xFF7C3AED),
//     ),
//     FocusItem(
//       itemId: '2',
//       clientName: 'Amit Sharma',
//       initials: 'AS',
//       badgeLabel: 'HIGH POTENTIAL',
//       badgeColor: const Color(0xFFEDE9FE),
//       badgeTextColor: const Color(0xFF7C3AED),
//       primaryValue: '92',
//       primaryLabel: 'Opportunity Score',
//       isPrimaryWarning: false,
//       description:
//           'HNI client with zero term cover. Family protection is a priority.',
//       actionLabel: 'Pitch Cover',
//       actionColor: const Color(0xFF7C3AED),
//     ),
//     FocusItem(
//       itemId: '3',
//       clientName: 'Priya Menon',
//       initials: 'PM',
//       badgeLabel: 'PAYMENT STOPPED',
//       badgeColor: const Color(0xFFFEE2E2),
//       badgeTextColor: const Color(0xFFDC2626),
//       primaryValue: '90',
//       primaryLabel: 'Days',
//       isPrimaryWarning: true,
//       description:
//           'Critical: 90 days without SIP payment. Risk of lapse. Contact urgently.',
//       actionLabel: 'Fix Mandate',
//       actionColor: const Color(0xFF7C3AED),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final displayItems = widget.items ?? defaultItems;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Focus This Week',
//                 style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[800],
//                     ),
//               ),
//               Text(
//                 '${displayItems.length} items',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Colors.grey[500],
//                     ),
//               ),
//             ],
//           ),
//         ),
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           child: SizedBox(
//             key: ValueKey(displayItems.length),
//             height: 240,
//             child: Swiper.children(
//               autoplay: false,
//               viewportFraction: 0.9,
//               outer: false,
//               loop: displayItems.length > 1,
//               children: _buildCards(context, displayItems),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildCards(BuildContext context, List<FocusItem> items) {
//     return items.map((item) => _buildCard(context, item)).toList();
//   }

//   Widget _buildCard(BuildContext context, FocusItem item) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with client name and badge
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEDE9FE),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Center(
//                     child: Text(
//                       item.initials,
//                       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                             color: const Color(0xFF7C3AED),
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.clientName,
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[800],
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: item.badgeColor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     item.badgeLabel,
//                     style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                           color: item.badgeTextColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 10,
//                         ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Primary value with icon
//             Row(
//               children: [
//                 if (item.isPrimaryWarning)
//                   Icon(
//                     Icons.warning_rounded,
//                     color: Colors.red[400],
//                     size: 20,
//                   )
//                 else
//                   Icon(
//                     Icons.auto_awesome,
//                     color: item.badgeTextColor,
//                     size: 20,
//                   ),
//                 const SizedBox(width: 8),
//                 Text(
//                   item.primaryValue,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: item.isPrimaryWarning
//                             ? Colors.red[500]
//                             : Colors.grey[800],
//                       ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   item.primaryLabel,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Description
//             Text(
//               item.description,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                     height: 1.4,
//                   ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const Spacer(),
//             // Action Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   widget.onActionTapped?.call(item.itemId, item.actionLabel);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: item.actionColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: Text(
//                   item.actionLabel,
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FocusItem {
//   final String itemId;
//   final String clientName;
//   final String initials;
//   final String badgeLabel;
//   final Color badgeColor;
//   final Color badgeTextColor;
//   final String primaryValue;
//   final String primaryLabel;
//   final bool isPrimaryWarning;
//   final String description;
//   final String actionLabel;
//   final Color actionColor;

//   FocusItem({
//     required this.itemId,
//     required this.clientName,
//     required this.initials,
//     required this.badgeLabel,
//     required this.badgeColor,
//     required this.badgeTextColor,
//     required this.primaryValue,
//     required this.primaryLabel,
//     required this.isPrimaryWarning,
//     required this.description,
//     required this.actionLabel,
//     required this.actionColor,
//   });
// }

import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class OpportunitiesFocus extends StatelessWidget {
  const OpportunitiesFocus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final topFocusClients =
            controller.opportunitiesOverview?.topFocusClients ?? [];

        if (topFocusClients.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Focus Clients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${topFocusClients.length} clients',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: Swiper(
                itemCount: topFocusClients.length,
                itemBuilder: (context, index) {
                  return ClientCard(client: topFocusClients[index]);
                },
                autoplay: false,
                viewportFraction: 0.9,
                scale: 0.95,
                loop: topFocusClients.length > 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ClientCard extends StatelessWidget {
  final dynamic client; // TopFocusClient from API

  const ClientCard({Key? key, required this.client}) : super(key: key);

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getTagColor(String tag, bool isBackground) {
    if (tag.toLowerCase().contains('risk') ||
        tag.toLowerCase().contains('stopped')) {
      return isBackground ? const Color(0xFFFEE2E2) : const Color(0xFFDC2626);
    } else if (tag.toLowerCase().contains('opp') ||
        tag.toLowerCase().contains('insurance')) {
      return isBackground ? const Color(0xFFEDE9FE) : const Color(0xFF7C3AED);
    } else if (tag.toLowerCase().contains('growth') ||
        tag.toLowerCase().contains('stagnant')) {
      return isBackground ? const Color(0xFFFED7AA) : const Color(0xFFEA580C);
    } else if (tag.toLowerCase().contains('portfolio') ||
        tag.toLowerCase().contains('underperform')) {
      return isBackground ? const Color(0xFFE5E7EB) : const Color(0xFF6B7280);
    }
    return isBackground ? const Color(0xFFE5E7EB) : const Color(0xFF6B7280);
  }

  IconData _getTagIcon(String tag) {
    if (tag.toLowerCase().contains('risk') ||
        tag.toLowerCase().contains('stopped')) {
      return Icons.warning_amber_rounded;
    } else if (tag.toLowerCase().contains('opp') ||
        tag.toLowerCase().contains('insurance')) {
      return Icons.lightbulb_outline;
    } else if (tag.toLowerCase().contains('growth') ||
        tag.toLowerCase().contains('stagnant')) {
      return Icons.trending_up;
    } else if (tag.toLowerCase().contains('portfolio') ||
        tag.toLowerCase().contains('underperform')) {
      return Icons.bar_chart;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(client.clientName);
    final tags = client.tags as List<String>? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9D5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.totalImpactValue,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final bgColor = _getTagColor(tag, true);
              final textColor = _getTagColor(tag, false);
              final icon = _getTagIcon(tag);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: textColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Pitch Hook (Alert message)
          Text(
            '💡 ${client.pitchHook}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
