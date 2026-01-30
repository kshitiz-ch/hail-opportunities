import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PmsTncScreen extends StatelessWidget {
  static const List<String> _termsAndConditions = [
    'Investments in securities market are subject to market risks.',
    'Past performance may or may not be sustained in future and should not be used as basis for comparison with other investments.',
    'The performance data for the Portfolio Manager and Investment Approach provided above has not been verified by SEBI or any other regulatory authority',
    'Returns for 1 year or lesser time horizon are absolute returns, while more than 1 year are CAGR. Returns have been calculated using Time Weighted Rate of Return method (TWRR) as prescribed by the SEBI.',
    'Data sourced from respective AMCs. WealthyIN is not responsible for the accuracy of data',
    'Data shown above is for informational purposes only and should not be considered investment advise in any way',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Terms & Conditions'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20.0),
        itemCount: _termsAndConditions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildBulletPoint(_termsAndConditions[index], context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ActionButton(
        text: 'Got It',
        onPressed: () {
          AutoRouter.of(context).pop();
        },
      ),
    );
  }

  Widget _buildBulletPoint(String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
