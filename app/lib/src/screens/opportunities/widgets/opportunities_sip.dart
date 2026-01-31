import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/views/opportunities_sip_screen.dart';
import 'package:app/src/screens/opportunities/widgets/sip_opportunity_item.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesSip extends StatefulWidget {
  const OpportunitiesSip({Key? key}) : super(key: key);

  @override
  State<OpportunitiesSip> createState() => _OpportunitiesSipState();
}

class _OpportunitiesSipState extends State<OpportunitiesSip> {
  String selectedTab = 'Stagnant';

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final stagnantOpps =
            controller.stagnantSipOpportunities?.opportunities ?? [];
        final stoppedOpps =
            controller.stoppedSipOpportunities?.opportunities ?? [];

        if (stagnantOpps.isEmpty && stoppedOpps.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 20),
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
                    'SIP Health',
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
                          builder: (context) => const OpportunitiesSipScreen(),
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

              // Tabs
              Row(
                children: [
                  _buildTab('Stagnant', selectedTab == 'Stagnant'),
                  const SizedBox(width: 8),
                  _buildTab('Stopped', selectedTab == 'Stopped'),
                ],
              ),

              const SizedBox(height: 16),

              // Divider line
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),

              // SIP Items - Dynamic from API based on selected tab (max 3 items)
              if (selectedTab == 'Stagnant')
                ...List.generate(
                    stagnantOpps.length > 3 ? 3 : stagnantOpps.length, (index) {
                  final opp = stagnantOpps[index];
                  return Column(
                    children: [
                      if (index > 0)
                        const Divider(height: 24, color: Color(0xFFE5E7EB)),
                      SipOpportunityItem(
                        userId: opp.userId,
                        name: opp.userName,
                        fundName: opp.schemeName,
                        statusText:
                            'No Step-up in ${opp.monthsStagnant} Months',
                        isStopped: false,
                        stagnantOpportunity: opp,
                      ),
                    ],
                  );
                })
              else
                ...List.generate(
                    stoppedOpps.length > 3 ? 3 : stoppedOpps.length, (index) {
                  final opp = stoppedOpps[index];
                  return Column(
                    children: [
                      if (index > 0)
                        const Divider(height: 24, color: Color(0xFFE5E7EB)),
                      SipOpportunityItem(
                        userId: opp.userId,
                        name: opp.userName,
                        fundName: [
                          'Last Paid: ${_formatDate(opp.lastSuccessDate)}'
                        ],
                        statusText: '${opp.daysSinceAnySuccess} Days Silent',
                        isStopped: true,
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

  Widget _buildTab(String title, bool isSelected) {
    final isStopped = title == 'Stopped';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isStopped ? const Color(0xFFDC2626) : const Color(0xFF6725F4))
              : const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
