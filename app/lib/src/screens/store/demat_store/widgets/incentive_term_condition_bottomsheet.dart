import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/screens/store/demat_store/widgets/referral_term_condition_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class IncentiveTermConditionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                AutoRouter.of(context).popForced();
              },
              color: ColorConstants.black,
              iconSize: 24,
              icon: Icon(Icons.close),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleText(tcTitle, context),
                  SizedBox(height: 20),
                  ..._buildBulletList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleText(String title, BuildContext context) {
    return Text(
      'Terms and Conditions for Business partners Incentive',
      style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  List<Widget> _buildBulletList(BuildContext context) {
    final bulletList = getBulletPoints();
    return bulletList
        .map<Widget>(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$bulletPointUnicode  ',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.black,
                        height: 18 / 12,
                      ),
                ),
                Expanded(
                  child: Text(
                    '${text}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<String> getBulletPoints() {
    return <String>[
      'All above incentives are Independent (KYC+5K margin is 600)',
      'All trading account opened  in a calendar month will be counted for incentive calculation',
      'Incentives will be calculated on a monthly basis and release on a monthly basis',
      'KYC Incentive will be paid on 15th of the next month and margin incentives will be paid after 15th of the following month (eg: KYC Incentives of Jan will be paid by 15h of feb and Margin Incentives will be paid by 15th of Mar)',
      'Margin incentive will be calculated on cash margin only. Total Margin will be used for the computation of the margin incentive (Payin-payout).',
      'Payin will have a grace period of 15 days post month close. Margin has to be maintained for at-least one month post cutoff date. (eg: payin till 15th Feb will be considered for Jan, payouts till 15th Mar will de deducted for margin calculation)',
      'Margin computation will only consider funds paid in and paid out to the customer bank account. All other transactions will not affect margin computation for this incentive computation',
      'All incentives will be for new account openings only no other accounts will be considered',
      'A business partner needs to have at-least 10 accounts opened and 4 activated (accounts with 5K margin and 1 trade) in wealthy to qualify for the incentive programs (this is in total not each month)',
      'Incentives from the first account will be given in the month the business partner gets activated.',
      'Revenue sharing will happen on a monthly basis and payout for the brokerage will happen on 15th of the month for the preceding month',
      'No backend mapping of clients will be considered for incentive calculation',
      'Wealthy reserve the right to cancel/ modify this incentive policy  at any time with prior intimation or without any intimation'
    ];
  }
}
