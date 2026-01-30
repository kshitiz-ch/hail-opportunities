import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_detail/widgets/portfolio_return_calculator.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class PortfolioGraph extends StatelessWidget {
  const PortfolioGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'graph-view',
      builder: (controller) {
        return Container(
          color: ColorConstants.secondaryWhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadioButtons(context, controller),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                // switchInCurve: Curves.ease,
                // switchOutCurve: Curves.ease,
                child: controller.selectedGraphView == FundGraphView.Historical
                    ? Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Chart(
                          productVariant: controller.portfolio.productVariant,
                          portfolio: controller.portfolio,
                        ),
                      )
                    : PortfolioReturnCalculator(
                        portfolio: controller.portfolio,
                        schemes: controller.fundsResult.schemeMetas ?? [],
                        basketMaxStartNavDate: controller.basketMaxStartNavDate,
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioButtons(
      BuildContext context, MFPortfolioDetailController controller) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          boxShadow: [
            BoxShadow(
              color: ColorConstants.darkBlack.withOpacity(0.1),
              offset: Offset(0.0, 4.0),
              spreadRadius: 0.0,
              blurRadius: 10.0,
            ),
          ],
          border: Border.all(color: ColorConstants.black.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: RadioButtons(
          items: controller.showChart
              ? FundGraphView.values
              : [FundGraphView.Custom],
          spacing: 30,
          runSpacing: 0,
          selectedValue: controller.selectedGraphView,
          itemBuilder: (context, value, index) {
            late String text;
            if (value == FundGraphView.Historical) {
              text = 'Historical View';
            } else {
              text = 'Return Calculator';
            }
            return Text(
              text,
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: value == controller.selectedGraphView
                        ? ColorConstants.black
                        : ColorConstants.tertiaryBlack,
                  ),
            );
          },
          direction: Axis.horizontal,
          onTap: (value) {
            if (controller.selectedGraphView != value) {
              controller.updateSelectedGraphView(value);
            }
          },
        ),
      ),
    );
  }
}
