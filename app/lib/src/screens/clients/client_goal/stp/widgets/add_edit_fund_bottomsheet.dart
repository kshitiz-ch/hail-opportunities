import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/stp_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/goal_inputs/amount_input.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_scheme_dropdown.dart';
import 'package:app/src/widgets/input/goal_inputs/dates_selector.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditFundBottomSheet extends StatelessWidget {
  const AddEditFundBottomSheet({Key? key, this.editIndex}) : super(key: key);

  final int? editIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 50),
      child: GetBuilder<StpController>(
        id: GetxId.schemeForm,
        builder: (controller) {
          return Form(
            key: controller.schemeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleAndCloseIcon(context),

                // Switch Out
                Flexible(
                  flex: controller.dropdownSelectedScheme?.switchOut == null
                      ? 0
                      : 1,
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: Radius.circular(8),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 25)
                          .copyWith(bottom: 40),
                      children: [
                        GoalSchemeDropdown(
                          label: 'Moving from',
                          goalSchemes: controller.isAnyFundPortfolio
                              ? controller.anyFundSwitchOutSchemes
                              : controller.switchOutSchemes,
                          selectedScheme:
                              controller.dropdownSelectedScheme?.switchOut,
                          switchFundType: SwitchFundType.SwitchOut,
                          onSchemeSelect: (SchemeMetaModel scheme) {
                            if ((scheme.folioOverview?.currentValue ?? 0) <=
                                0) {
                              return showToast(
                                  text:
                                      "Scheme should have value greater than zero");
                            }

                            StpSchemeContext schemeContext = StpSchemeContext(
                                switchOut: SchemeMetaModel.clone(scheme));

                            controller.amountController.clear();
                            controller
                                .updateDropdownSelectedScheme(schemeContext);
                            AutoRouter.of(context).popForced();
                          },
                        ),
                        if (controller.dropdownSelectedScheme?.switchOut !=
                            null)
                          // Switch In
                          Padding(
                            padding: EdgeInsets.only(bottom: 30, top: 30),
                            child: GoalSchemeDropdown(
                              label: 'Moving to',
                              selectedScheme:
                                  controller.dropdownSelectedScheme?.switchIn,
                              goalSchemes: controller.switchInSchemes,
                              switchFundType: SwitchFundType.SwitchIn,
                              amcCode: controller
                                  .dropdownSelectedScheme?.switchOut?.amc,
                              onSchemeSelect: (SchemeMetaModel scheme) {
                                controller.amountController.clear();
                                controller.dropdownSelectedScheme?.switchIn =
                                    scheme;
                                controller.update([GetxId.schemeForm]);

                                AutoRouter.of(context).popForced();
                              },
                            ),
                          ),
                        if (controller.dropdownSelectedScheme?.switchOut !=
                                null &&
                            controller.dropdownSelectedScheme?.switchIn != null)
                          _buildStpForm(context, controller),
                      ],
                    ),
                  ),
                ),

                _buildActionButton(context, controller)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleAndCloseIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0)
          .copyWith(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Fund for STP',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          CommonUI.bottomsheetCloseIcon(context)
        ],
      ),
    );
  }

  Widget _buildStpForm(BuildContext context, StpController controller) {
    double minAmount =
        controller.dropdownSelectedScheme?.switchIn?.minDepositAmt ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            child: DatesSelector(
              orderType: 'STP',
              selectedDays: controller.selectedDays,
              onChanged: (value) {
                controller.updateStpDays(value);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: AmountInput(
              amountController: controller.amountController,
              minAmount: minAmount,
              validator: (value) {
                if (value.isNullOrEmpty) {
                  return 'This fields is required';
                }

                if ((double.tryParse(value!) ?? 0) < minAmount) {
                  return 'Min Amount should be ${WealthyAmount.currencyFormat(minAmount, 0)}';
                }

                return null;
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: GoalDateInput(
              controller: controller.startDateController,
              label: 'Start Date',
              onDateSelect: controller.updateStartDate,
            ),
          ),

          // End Date
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: GoalDateInput(
              controller: controller.endDateController,
              label: 'End Date',
              startDate: controller.dropdownSelectedScheme?.startDate,
              onDateSelect: controller.updateEndDate,
            ),
          ),

          // _buildAddSwitchButton(context, controller)
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, StpController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.darkBlack.withOpacity(0.1),
            blurRadius: 5.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ActionButton(
        isDisabled: controller.dropdownSelectedScheme?.switchIn == null,
        onPressed: () {
          if (controller.schemeFormKey.currentState!.validate()) {
            if (controller.selectedDays.isEmpty) {
              showToast(text: 'Please select days for STP');
              return;
            }

            controller.saveDropdownSelectedScheme(editIndex: editIndex);
            AutoRouter.of(context).popForced();
          }
        },
        text: '${editIndex != null ? 'Update' : 'Add'} Fund',
        margin: EdgeInsets.zero,
      ),
    );
  }
}
