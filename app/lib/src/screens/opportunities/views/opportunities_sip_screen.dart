import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesSipScreen extends StatefulWidget {
  const OpportunitiesSipScreen({Key? key}) : super(key: key);

  @override
  State<OpportunitiesSipScreen> createState() => _OpportunitiesSipScreenState();
}

class _OpportunitiesSipScreenState extends State<OpportunitiesSipScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'SIP Opportunities',
      ),
      body: GetBuilder<OpportunitiesController>(
        builder: (controller) {
          final stagnantOpps =
              controller.stagnantSipOpportunities?.opportunities ?? [];
          final stoppedOpps =
              controller.stoppedSipOpportunities?.opportunities ?? [];

          if (stagnantOpps.isEmpty && stoppedOpps.isEmpty) {
            return const Center(
              child: Text(
                'No SIP opportunities available',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            );
          }

          final currentData =
              selectedTab == 'Stagnant' ? stagnantOpps : stoppedOpps;

          return Column(
            children: [
              // Tabs
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTab('Stagnant', selectedTab == 'Stagnant'),
                    const SizedBox(width: 8),
                    _buildTab('Stopped', selectedTab == 'Stopped'),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentData.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (selectedTab == 'Stagnant') {
                      final opp = stagnantOpps[index];
                      // Create client object
                      final client = Client.fromJson({
                        'user_id': opp.userId,
                        'name': opp.userName,
                      });
                      return InkWell(
                        onTap: () {
                          AutoRouter.of(context).push(
                            SipDetailRoute(
                                client: client,
                                sipUserData: SipUserDataModel.fromJson({})),
                          );
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
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opp.userName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      opp.schemeName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status Badge with Arrow
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8EEE2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      'No Step-up: ${opp.monthsStagnant} Yrs',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFF98814),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final opp = stoppedOpps[index];
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
                        child: Row(
                          children: [
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opp.userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last Paid: ${_formatDate(opp.lastSuccessDate)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status Badge with Arrow
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5E5),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    '${opp.daysSinceAnySuccess} Days Silent',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                  },
                ),
              ),
            ],
          );
        },
      ),
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
