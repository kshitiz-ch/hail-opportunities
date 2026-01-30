import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ActivateSegmentConfirmationBottomSheet extends StatelessWidget {
  final statementList = <String>[
    'Bank statement for the last 6 months with an average balance of more than ₹10,000. (Statement must be in the name of the Wealthy account holder.)',
    'The latest salary slip with gross monthly income exceeding ₹15,000.',
    'ITR acknowledgement with gross annual income exceeding ₹1,20,000.',
    'Form 16 with gross annual income exceeding ₹1,20,000.',
    'Certificate of net worth more than ₹10,00,000. Statement of Demat holdings with holdings value exceeding ₹10,000',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.lightBackgroundColorV2,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: getSafeTopPadding(30, context),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    AutoRouter.of(context).popForced();
                  },
                  icon: Icon(
                    Icons.close,
                    size: 24,
                    color: ColorConstants.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
              child: Text(
                'Would you like to activate\nyour futures and options?',
                style:
                    Theme.of(context).primaryTextTheme.headlineLarge?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
              ),
            ),
            _buildStatementList(context),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                  children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0.0, 0.0),
                        child: Text('*'),
                      ),
                    ),
                    TextSpan(
                      text: 'Once activated, can not be deactivated',
                    ),
                  ],
                ),
              ),
            ),
            // Continue Button
            ActionButton(
              text: 'Continue',
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24)
                  .copyWith(top: 80),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatementList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12).copyWith(top: 30),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share any of the following \nstatements',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ]..addAll(
            statementList.map<Widget>(
              (statement) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    children: [
                      Image.asset(
                        AllImages().diamondBulletIcon,
                        height: 12,
                        width: 12,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          statement,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              ?.copyWith(
                                height: 1.3,
                                color: ColorConstants.tertiaryBlack,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ).toList(),
          ),
      ),
    );
  }
}
