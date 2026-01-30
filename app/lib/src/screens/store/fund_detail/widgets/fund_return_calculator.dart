import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_return_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_return.dart';
import 'package:app/src/screens/store/fund_detail/widgets/investment_slider.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FundReturnCalculator extends StatelessWidget {
  final SchemeMetaModel fund;

  const FundReturnCalculator({Key? key, required this.fund}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundReturnController>(
      init: FundReturnController(fund),
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvestmentType(context, controller),
              InvestmentSlider(inputType: FundReturnInputType.Amount),
              SizedBox(height: 40),
              InvestmentSlider(inputType: FundReturnInputType.Period),
              SizedBox(height: 20),
              FundReturn(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvestmentType(
    BuildContext context,
    FundReturnController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Type ',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 13, bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.darkBlack.withOpacity(0.05),
                offset: Offset(0.0, 0.0),
                spreadRadius: 0.0,
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: InvestmentType.values.map<Widget>(
              (investmentType) {
                final text = investmentType == InvestmentType.SIP
                    ? 'Monthly SIP'
                    : 'Lumpsum';
                final isSelected =
                    investmentType == controller.selectedInvestmentType;
                return GestureDetector(
                  onTap: () {
                    controller.updateInvestmentType(investmentType);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: isSelected
                          ? ColorConstants.primaryAppv3Color
                          : ColorConstants.white,
                      border: isSelected
                          ? Border.all(color: ColorConstants.primaryAppColor)
                          : Border.fromBorderSide(BorderSide.none),
                    ),
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? ColorConstants.primaryAppColor
                                : ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        )
      ],
    );
  }
}
