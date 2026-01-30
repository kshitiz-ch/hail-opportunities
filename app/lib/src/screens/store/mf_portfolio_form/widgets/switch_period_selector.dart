import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class SwitchPeriodSelector extends StatelessWidget {
  const SwitchPeriodSelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "POSSIBLE SWITCH PERIOD" Text
          Text(
            "Choose Possible Switch Period",
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.tertiaryGrey),
          ),

          SizedBox(height: 16.0),

          GetBuilder<MFPortfolioDetailController>(
            id: 'possible-switch-period',
            builder: (controller) {
              return RadioButtons(
                direction: Axis.vertical,
                spacing: 26,
                items: controller.possibleSwitchPeriods,
                selectedValue: controller.selectedSwitchPeriod,
                itemBuilder: (BuildContext context, value, index) {
                  return Text(
                    '$value Months',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontWeight: FontWeight.w500,
                            color: controller.selectedSwitchPeriod == value
                                ? ColorConstants.black
                                : ColorConstants.tertiaryBlack),
                  );
                },
                onTap: (value) {
                  controller.updateSelectedSwitchPeriod(
                    value,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
