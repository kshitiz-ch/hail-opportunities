import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipBookInfo extends StatelessWidget {
  final int tabIndex;

  final sipBookController = Get.find<SipBookController>();

  SipBookInfo({Key? key, required this.tabIndex}) : super(key: key);

  final summaryText =
      "For Offline SIPs, the SIP amount is shown as an approximate monthly value (as per RTA feeds): Daily = 22×, Weekly = 4.3×, Fortnightly = 2×, Quarterly = 0.33× per month.";

  final sipBookInfo = {
    'Online SIPs: ': 'SIPs registered via Wealthy’s platform.',
    'Offline SIPs: ':
        'SIPs registered directly with RTAs/AMCs or through offline channels. Monthly SIP Contribution is shown as an approximate monthly value (as per RTA feeds): Daily = 22×, Weekly = 4.3×, Fortnightly = 2×, Quarterly = 0.33× per month.',
    'Transactions: ':
        'Transaction details for SIPs registered through Wealthy’s platform.',
  };

  @override
  Widget build(BuildContext context) {
    final tabText = sipBookController.tabs[tabIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().sipbookIcon,
            height: 80,
            width: 144,
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              tabText,
              style: context.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black,
              ),
            ),
          ),
          tabIndex == 0
              ? Text(
                  summaryText,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                    height: 1.6,
                  ),
                )
              : _buildSipBookInfo(context),
          ActionButton(
            text: 'Got it',
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSipBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sipBookInfo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: entry.key,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.black,
                    height: 1.6,
                  ),
                ),
                TextSpan(
                  text: entry.value,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
