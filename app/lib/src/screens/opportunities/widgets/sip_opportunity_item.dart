import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/screens/opportunities/widgets/sip_revival_bottomsheet.dart';
import 'package:app/src/screens/opportunities/widgets/sip_stepup_bottomsheet.dart';
import 'package:app/src/screens/opportunities/widgets/sip_simulator_sheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/opportunities/models/sip_opportunity_model.dart';
import 'package:flutter/material.dart';

class SipOpportunityItem extends StatelessWidget {
  final String userId;
  final String name;
  final List<String> fundName;
  final String statusText;
  final bool isStopped;
  final StagnantSipOpportunity? stagnantOpportunity;
  final StoppedSipOpportunity? stoppedOpportunity;

  const SipOpportunityItem({
    Key? key,
    required this.userId,
    required this.name,
    required this.fundName,
    required this.statusText,
    this.isStopped = false,
    this.stagnantOpportunity,
    this.stoppedOpportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create client object
    final client = Client.fromJson({
      'user_id': userId,
      'name': name,
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fundName.isEmpty
                      ? '-'
                      : fundName.length == 1
                          ? fundName[0]
                          : '${fundName[0]} +${fundName.length - 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isStopped
                        ? const Color(0xFFFFE5E5)
                        : const Color(0xFFF8EEE2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isStopped
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFF98814),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Distinct CTA Button
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isStopped) {
      // STOPPED SIP - Orange "Pitch Restart" button
      return GestureDetector(
        onTap: () {
          if (stoppedOpportunity != null) {
            SipRevivalBottomSheet.show(context, stoppedOpportunity!);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.restore,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Pitch Restart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // STAGNANT SIP - Purple "Pitch Step-up" button
      return GestureDetector(
        onTap: () {
          if (stagnantOpportunity != null) {
            SipSimulatorSheet.show(
              context,
              clientName: name,
              userId: userId,
              currentSipAmount: stagnantOpportunity!.currentSip,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6725F4),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6725F4).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Pitch Step-up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
