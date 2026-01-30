import 'package:app/src/screens/opportunities/widgets/opportunities_focus.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_insurance.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_overview.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_portfolio.dart';
import 'package:app/src/screens/opportunities/widgets/opportunities_sip.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 100),
        child: Column(
          children: [
            OpportunitiesOverview(),
            SizedBox(height: 20),
            OpportunitiesFocus(),
            SizedBox(height: 20),
            OpportunitiesPortfolio(),
            SizedBox(height: 20),
            OpportunitiesSip(),
            SizedBox(height: 20),
            OpportunitiesInsurance(),
          ],
        ),
      ),
    );
  }
}
