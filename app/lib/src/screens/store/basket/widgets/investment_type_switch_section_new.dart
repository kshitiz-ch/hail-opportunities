import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/animation/shake_widget.dart';
import 'package:app/src/widgets/input/investment_type_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvestmentTypeSwitchSectionNew extends StatelessWidget {
  // Fields
  final String? tag;

  // Constructor
  const InvestmentTypeSwitchSectionNew({
    Key? key,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = SizeConfig().isTabletDevice;
    return Column(
      crossAxisAlignment:
          isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        GetBuilder<BasketController>(
          id: 'investment-type',
          global: tag != null ? false : true,
          init: Get.find<BasketController>(tag: tag),
          builder: (controller) {
            return Container(
              alignment: isTablet ? Alignment.center : Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
              child: controller.showSelectInvestmentTypeErrorText &&
                      controller.investmentType == null
                  ? ShakeWidget(
                      key: UniqueKey(),
                      child: _buildInvestmentTypeSwitch(controller),
                    )
                  : _buildInvestmentTypeSwitch(controller),
            );
          },
        ),
        GetBuilder<BasketController>(
          id: 'error-text',
          global: tag != null ? false : true,
          init: Get.find<BasketController>(tag: tag),
          builder: (controller) {
            return AnimatedSize(
              duration: 200.milliseconds,
              child: controller.showSelectInvestmentTypeErrorText
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32)
                          .copyWith(bottom: 22.0),
                      child: Text(
                        'Please select the investment type.',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodySmall!
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
  }

  InvestmentTypeSwitch _buildInvestmentTypeSwitch(BasketController controller) {
    return InvestmentTypeSwitch(
      hasOneTimeBlockedfunds: controller.hasOneTimeBlockedFunds,
      hasSipBlockedFunds: controller.hasSipBlockedFunds,
      investmentTypeAllowed: controller.investmentTypeAllowed,
      investmentType: controller.investmentType,
      onChanged: (type) {
        controller.updateInvestmentType(type);
      },
    );
  }
}
