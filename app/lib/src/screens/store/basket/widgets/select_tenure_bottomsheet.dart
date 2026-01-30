import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_edit_fund_controller.dart';
import 'package:app/src/screens/store/basket/widgets/custom_tenure_bottomsheet.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectTenureBottomSheet extends StatelessWidget {
  final tenureList = [20, 10, 5, 1, 'Indefinite', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Tenure',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Choose the investment duration',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ],
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
          SizedBox(height: 20),
          GetBuilder<BasketEditFundController>(
            builder: (controller) {
              return RadioButtons(
                spacing: 30,
                runSpacing: 80,
                direction: Axis.vertical,
                items: tenureList,
                selectedValue: getSelectedTenure(controller),
                onTap: (tenureSelected) {
                  onTapTenure(tenureSelected, controller, context);
                },
                itemBuilder: (context, value, index) {
                  final text = value is String ? value : '$value Years';

                  return Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displayMedium!
                        .copyWith(
                          fontSize: 16,
                          color: controller.sipData.tenure == value
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  void onTapTenure(
    dynamic tenureSelected,
    BasketEditFundController controller,
    BuildContext context,
  ) {
    if (tenureSelected == 'Custom') {
      CommonUI.showBottomSheet(
        context,
        child: CustomTenureBottomSheet(),
        isScrollControlled: false,
      );
    } else {
      bool isIndefiniteTenure = tenureSelected == 'Indefinite';
      // indefinite == year 2100
      final indefiniteTenure =
          2100 - (controller.sipData.startDate ?? DateTime.now()).year;
      int tenure = isIndefiniteTenure ? indefiniteTenure : tenureSelected;
      controller.updateTenure(tenure, isIndefiniteTenure: isIndefiniteTenure);
      AutoRouter.of(context).popForced();
    }
  }
}

dynamic getSelectedTenure(BasketEditFundController controller,
    {bool showCustomText = true}) {
  if (controller.sipData.isIndefiniteTenure) {
    return 'Indefinite';
  }
  if (controller.sipData.isCustomTenure && showCustomText) {
    return 'Custom';
  }
  return controller.sipData.tenure;
}
