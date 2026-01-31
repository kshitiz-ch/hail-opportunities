import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/insurance_opportunity_item.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesInsuranceScreen extends StatelessWidget {
  const OpportunitiesInsuranceScreen({Key? key}) : super(key: key);

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
                child: InsuranceOpportunityItem(opportunity: opp),
              );
            },
          );
        },
      ),
    );
  }
}
