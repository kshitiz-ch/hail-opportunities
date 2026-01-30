import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/widgets/animation/shake_widget.dart';
import 'package:app/src/widgets/input/investment_type_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/get_utils.dart';

class InvestmentTypeSwitchSection extends StatelessWidget {
  final bool? isSmartSwitch;

  const InvestmentTypeSwitchSection({
    Key? key,
    this.isSmartSwitch = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'investment-type',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 44.0, 16.0, 16.0),
              child: Text(
                "Choose Investment Type",
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.tertiaryGrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: controller.showSelectInvestmentTypeErrorText &&
                      controller.investmentType == null
                  ? ShakeWidget(
                      key: UniqueKey(),
                      child: _buildInvestmentTypeSwitch(controller),
                    )
                  : _buildInvestmentTypeSwitch(controller),
            ),
            GetBuilder<MFPortfolioDetailController>(
              id: 'error-text',
              builder: (controller) {
                return AnimatedSize(
                  duration: 200.milliseconds,
                  child: controller.showSelectInvestmentTypeErrorText
                      ? Padding(
                          padding:
                              const EdgeInsets.only(bottom: 22.0, left: 30),
                          child: Text(
                            'Please select the investment type.',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleMedium!
                                .copyWith(color: ColorConstants.redAccentColor),
                          ),
                        )
                      : SizedBox(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  InvestmentTypeSwitch _buildInvestmentTypeSwitch(
      MFPortfolioDetailController controller) {
    return InvestmentTypeSwitch(
      investmentType: controller.investmentType,
      investmentTypeAllowed: controller.investmentTypeAllowed,
      isSIPButtonDisabled: isSmartSwitch,
      sipButtonDisableReason:
          isSmartSwitch! ? "SIP Disabled for Smart Switch" : null,
      onChanged: (type) => controller.updateInvestmentType(type),
    );
  }
}
