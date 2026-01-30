import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/portfolio_return_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_detail/widgets/portfolio_return_card.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'investment_slider.dart';

class PortfolioReturnCalculator extends StatelessWidget {
  const PortfolioReturnCalculator({
    Key? key,
    required this.portfolio,
    required this.schemes,
    this.basketMaxStartNavDate,
  }) : super(key: key);

  final GoalSubtypeModel portfolio;
  final List<SchemeMetaModel> schemes;
  final DateTime? basketMaxStartNavDate;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioReturnController>(
      init: PortfolioReturnController(
        portfolio,
        schemes,
        basketMaxStartNavDate,
      ),
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
              PortfolioReturnCard()
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvestmentType(
    BuildContext context,
    PortfolioReturnController controller,
  ) {
    // in smart mover sip not allowed
    final investmentTypes = portfolio.isSmartSwitch
        ? [InvestmentType.oneTime]
        : InvestmentType.values;
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
            children: investmentTypes.map<Widget>(
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
