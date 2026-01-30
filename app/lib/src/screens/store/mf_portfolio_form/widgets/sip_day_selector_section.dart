import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/widgets/input/sip_day_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipDaySelectorSection extends StatelessWidget {
  const SipDaySelectorSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'investment-type',
      builder: (controller) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
          child: controller.investmentType == InvestmentType.SIP
              ? Column(
                  children: [
                    // "CHOOSE DEBIT DAY" Text
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        bottom: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: ColorConstants.tertiaryGrey,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Choose Date of Monthly Debit",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    color: ColorConstants.tertiaryGrey,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GetBuilder<MFPortfolioDetailController>(
                        id: 'sip-day',
                        builder: (controller) {
                          return SipDaySelector(
                            selectedSipDay: controller.selectedSipDay,
                            sipDays: controller.sipDays,
                            onChanged: controller.updateSIPDay,
                          );
                        },
                      ),
                    ),
                  ],
                )
              : SizedBox(width: double.infinity),
        );
      },
    );
  }
}
