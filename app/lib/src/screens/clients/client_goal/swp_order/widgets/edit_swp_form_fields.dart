import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/goal_inputs/amount_input.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditSWPFormField extends StatelessWidget {
  TextStyle? hintStyle;
  TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    hintStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    textStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
    return GetBuilder<SwpDetailController>(
      builder: (SwpDetailController controller) {
        final isDateExpired =
            controller.updatedSwp.startDate?.isBefore(DateTime.now()) ?? false;

        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: _buildAmountTextField(
                  context: context,
                  controller: controller,
                ),
              ),

              // Start Date
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: InkWell(
                  onTap: () {
                    if (isDateExpired) {
                      showToast(
                          text:
                              'SWP is already started. So Start Date cannot be changed now');
                    }
                  },
                  child: IgnorePointer(
                    ignoring: isDateExpired,
                    child: GoalDateInput(
                      controller: controller.startDateController,
                      label: 'Start Date',
                      onDateSelect: controller.updateStartDate,
                    ),
                  ),
                ),
              ),

              // End Date
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GoalDateInput(
                  controller: controller.endDateController,
                  label: 'End Date',
                  onDateSelect: controller.updateEndDate,
                  startDate: controller.updatedSwp.startDate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountTextField({
    required SwpDetailController controller,
    required BuildContext context,
  }) {
    double minAmount = controller.selectedSwp.swpFunds.isNotNullOrEmpty
        ? controller.selectedSwp.swpFunds!.first.minWithdrawalAmt
        : 0;
    final minText =
        'Minimum Withdrawal Amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';

    return AmountInput(
      amountController: controller.amountController,
      minAmount: minAmount,
      onChanged: (val) {
        controller.updateAmount(val);
      },
      validator: (value) {
        if (value.isNullOrEmpty) {
          return 'Amount is required.';
        }

        final amount = WealthyCast.toDouble(value?.replaceAll(',', '') ?? 0);
        if (amount == null) {
          return 'Amount field is required';
        }

        final isAmountInvalid = minAmount > amount;
        if (isAmountInvalid) {
          return '$minText';
        }
        return null;
      },
    );
  }
}
