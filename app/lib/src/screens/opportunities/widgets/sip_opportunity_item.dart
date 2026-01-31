import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/screens/opportunities/widgets/sip_stepup_bottomsheet.dart';
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

  const SipOpportunityItem({
    Key? key,
    required this.userId,
    required this.name,
    required this.fundName,
    required this.statusText,
    this.isStopped = false,
    this.stagnantOpportunity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create client object
    final client = Client.fromJson({
      'user_id': userId,
      'name': name,
    });

    return InkWell(
      onTap: () {
        if (!isStopped && stagnantOpportunity != null) {
          // Open bottom sheet for stagnant SIPs
          SipStepUpBottomSheet.show(context, stagnantOpportunity!);
        } else {
          // Navigate to SIP detail for stopped SIPs
          AutoRouter.of(context).push(
            SipDetailRoute(
                client: client, sipUserData: SipUserDataModel.fromJson({})),
          );
        }
      },
      child: Row(
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
                          : '${fundName[0]} +${fundName.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
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
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Status Badge with Arrow
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
