import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_error.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_focus.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_insurance.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_loader.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_overview.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_portfolio.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_sip.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'Opportunities',
        // trailingWidgets: [
        //   Container(
        //     width: 120,
        //     alignment: Alignment.centerRight,
        //     child: NewsletterYearDropdown(),
        //   ),
        // ],
      ),
      body: GetBuilder<OpportunitiesController>(
        init: OpportunitiesController(),
        initState: (state) {
          state.controller?.initializeOpportunitiesData();
        },
        builder: (controller) {
          // if (controller.opportunitiesOverviewResponse.state ==
          //     NetworkState.loading) {
          //   return Center(
          //     child: OpportunitiesLoader(
          //       size: 60,
          //       color: const Color(0xFF7F30FE),
          //     ),
          //   );
          // }

          // if (controller.opportunitiesOverviewResponse.state ==
          //     NetworkState.error) {
          //   return OpportunitiesError(
          //     message: controller.opportunitiesOverviewResponse.message,
          //     onRetry: () {
          //       controller.initializeOpportunitiesData();
          //     },
          //   );
          // }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                OpportunitiesOverview(),
                const SizedBox(height: 20),
                OpportunitiesFocus(),
                const SizedBox(height: 20),
                OpportunitiesPortfolio(),
                const SizedBox(height: 20),
                OpportunitiesSip(),
                const SizedBox(height: 20),
                OpportunitiesInsurance(),
              ],
            ),
          );
        },
      ),
    );
  }
}
