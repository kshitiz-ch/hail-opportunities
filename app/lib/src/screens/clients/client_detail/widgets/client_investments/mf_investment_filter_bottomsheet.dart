import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_investment_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MfInvestmentBottomSheet extends StatelessWidget {
  MfInvestmentBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MfInvestmentController>(
        id: 'filter-bottomsheet',
        builder: (controller) {
          return Container(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select one or more options',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: 18),
                ),
                SizedBox(height: 20),
                _buildOptions(context, MfInvestmentType.Funds, controller),
                _buildOptions(context, MfInvestmentType.Portfolios, controller),
                ActionButton(
                  text: 'Apply',
                  isDisabled: controller.filtersSelected.isEmpty,
                  margin: EdgeInsets.only(top: 50),
                  onPressed: () {
                    controller.saveFilters();
                    AutoRouter.of(context).popForced();
                  },
                )
              ],
            ),
          );
        });
  }

  Widget _buildOptions(BuildContext context, MfInvestmentType filterType,
      MfInvestmentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {
          controller.updateFiltersSelected(filterType);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: [
              if (controller.filtersSelected.contains(filterType))
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 4),
                  child: Icon(Icons.done,
                      color: ColorConstants.primaryAppColor, size: 12),
                )
              else
                SizedBox(
                  width: 26,
                ),
              Text(
                filterType.name,
                style:
                    Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                          fontSize: 16,
                          color: controller.filtersSelected.contains(filterType)
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
