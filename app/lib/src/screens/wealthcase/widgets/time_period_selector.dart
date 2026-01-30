import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimePeriodSelector extends StatelessWidget {
  final controller = Get.find<WealthcaseController>();

  @override
  Widget build(BuildContext context) {
    final model = controller.selectedWealthcase!;
    final borderColor = Color(0xffEDE6FC).withOpacity(0.7);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: model.availablePeriods.map((period) {
          final isSelected = period == model.selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (model.selectedPeriod == period) return;
                model.selectedPeriod = period;
                controller.update();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: !isSelected ? Colors.white : Color(0xffF9F6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(right: BorderSide(color: borderColor)),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: context.headlineSmall?.copyWith(
                    color: isSelected
                        ? ColorConstants.primaryAppColor
                        : ColorConstants.tertiaryBlack,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
