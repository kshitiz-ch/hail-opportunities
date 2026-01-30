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

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class OpportunitiesFocus extends StatefulWidget {
  const OpportunitiesFocus({Key? key}) : super(key: key);

  @override
  State<OpportunitiesFocus> createState() => _OpportunitiesFocusState();
}

class _OpportunitiesFocusState extends State<OpportunitiesFocus> {
  late List<ClientData> clients;

  @override
  void initState() {
    super.initState();
    clients = _getClientData();
  }

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${clients.length} clients',
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
            itemCount: clients.length,
            itemBuilder: (context, index) {
              return ClientCard(client: clients[index]);
            },
            autoplay: false,
            viewportFraction: 0.9,
            scale: 0.95,
            loop: clients.length > 1,
          ),
        ),
      ],
    );
  }

  List<ClientData> _getClientData() {
    return [
      ClientData(
        initials: 'RK',
        name: 'Rajesh Kumar',
        amount: '₹1.5 L',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Risk: Stopped SIP', const Color(0xFFFEE2E2),
              const Color(0xFFDC2626), Icons.warning_amber_rounded),
          TagData('Opp: Insurance', const Color(0xFFEDE9FE),
              const Color(0xFF7C3AED), Icons.lightbulb_outline),
        ],
        alert:
            '💡 Critical: Monthly investment stopped 65 days ago, risking long-term...',
      ),
      ClientData(
        initials: 'AR',
        name: 'Aditi Rao',
        amount: '₹50 K',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Growth: Stagnant SIP', const Color(0xFFFED7AA),
              const Color(0xFFEA580C), Icons.trending_up),
        ],
        alert: '💡 Inflation Risk: SIP running flat with 0% step-up.',
      ),
      ClientData(
        initials: 'VS',
        name: 'Vikram Shah',
        amount: '₹2.1 L',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Risk: Stopped SIP', const Color(0xFFFEE2E2),
              const Color(0xFFDC2626), Icons.warning_amber_rounded),
          TagData('Portfolio: Underperforming', const Color(0xFFE5E7EB),
              const Color(0xFF6B7280), Icons.bar_chart),
        ],
        alert:
            '💡 Alert: 3 funds underperforming benchmark by avg 4.5%, SIP stopped fo...',
      ),
      ClientData(
        initials: 'PM',
        name: 'Priya Menon',
        amount: '₹3.2 L',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Opp: Insurance', const Color(0xFFEDE9FE),
              const Color(0xFF7C3AED), Icons.lightbulb_outline),
          TagData('Growth: Stagnant SIP', const Color(0xFFFED7AA),
              const Color(0xFFEA580C), Icons.trending_up),
        ],
        alert:
            '💡 Ultra HNI with significant protection gap. High conversion probabili...',
      ),
      ClientData(
        initials: 'AS',
        name: 'Amit Sharma',
        amount: '₹80 K',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Portfolio: Underperforming', const Color(0xFFE5E7EB),
              const Color(0xFF6B7280), Icons.bar_chart),
        ],
        alert:
            '💡 2 large cap funds dragging returns. Switch to flexi-cap recommended.',
      ),
      ClientData(
        initials: 'DN',
        name: 'Deepa Nair',
        amount: '₹1.8 L',
        bgColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7C3AED),
        tags: [
          TagData('Opp: Insurance', const Color(0xFFEDE9FE),
              const Color(0xFF7C3AED), Icons.lightbulb_outline),
        ],
        alert:
            '💡 Family floater upgrade recommended. Spouse and children uninsured.',
      ),
    ];
  }
}

class ClientCard extends StatelessWidget {
  final ClientData client;

  const ClientCard({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: client.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: client.textColor,
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
                      client.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.amount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: client.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: client.tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tag.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tag.icon,
                      size: 14,
                      color: tag.textColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: tag.textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Alert message
          Text(
            client.alert,
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

class ClientData {
  final String initials;
  final String name;
  final String amount;
  final Color bgColor;
  final Color textColor;
  final List<TagData> tags;
  final String alert;

  ClientData({
    required this.initials,
    required this.name,
    required this.amount,
    required this.bgColor,
    required this.textColor,
    required this.tags,
    required this.alert,
  });
}

class TagData {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  TagData(this.label, this.bgColor, this.textColor, this.icon);
}
