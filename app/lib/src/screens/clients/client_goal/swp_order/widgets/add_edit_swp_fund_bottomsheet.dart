import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/create_swp_controller.dart';
import 'package:app/src/utils/swp_scheme_context.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/goal_inputs/amount_input.dart';
import 'package:app/src/widgets/input/goal_inputs/dates_selector.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_scheme_dropdown.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditSwpFundBottomSheet extends StatelessWidget {
  const AddEditSwpFundBottomSheet({
    Key? key,
    this.isEdit = false,
    this.fundIdSelected,
  })  : assert(
          isEdit ? fundIdSelected != null : true,
        ),
        super(key: key);

  final bool isEdit;
  final String? fundIdSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 50),
      child: GetBuilder<CreateSwpController>(
        id: GetxId.schemeForm,
        builder: (controller) {
          return Form(
            key: controller.schemeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndCloseIcon(context),
                Flexible(
                  flex: controller.dropdownSelectedScheme == null ? 0 : 1,
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: Radius.circular(8),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 25)
                          .copyWith(bottom: 80),
                      children: [
                        GoalSchemeDropdown(
                          goalSchemes: controller.schemeWithFolios,
                          amcCode: controller
                              .dropdownSelectedScheme?.schemeData.amcCode,
                          selectedScheme:
                              controller.dropdownSelectedScheme?.schemeData,
                          switchFundType: SwitchFundType.SwitchOut,
                          onSchemeSelect: (SchemeMetaModel scheme) {
                            if ((scheme.folioOverview?.currentValue ?? 0) <=
                                0) {
                              return showToast(
                                  text:
                                      "Scheme should have value greater than zero");
                            }

                            final swpSchemeContext = SwpSchemeContext(
                              schemeData: scheme,
                              goalId: controller.goalId,
                            );
                            controller
                                .updateDropdownSelectedScheme(swpSchemeContext);
                            // pop drop down list bottomsheet
                            AutoRouter.of(context).popForced();
                          },
                        ),
                        _buildSwpFormFields(context, controller),
                      ],
                    ),
                  ),
                ),
                _buildAddFundButton(context, controller)
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
            isEdit ? 'Edit Fund' : 'Add Funds for SWP',
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

  Widget _buildAddFundButton(
      BuildContext context, CreateSwpController controller) {
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
      child: (controller.dropdownSelectedScheme != null &&
              controller.isFundDisabledForSwp)
          ? Text(
              "Please Note: Withdrawal is not possible currently as your fund balance is below the minimum withdrawal amount specified for the selected SWP",
              textAlign: TextAlign.center,
              style: context.headlineSmall!
                  .copyWith(color: ColorConstants.tertiaryBlack),
            )
          : ActionButton(
              isDisabled: controller.dropdownSelectedScheme == null,
              onPressed: () {
                if (controller.schemeFormKey.currentState!.validate()) {
                  if (controller.dropdownSelectedScheme!.startDate!
                      .isAfter(controller.dropdownSelectedScheme!.endDate!)) {
                    showToast(text: 'End Date should be after the Start Date');
                    return;
                  }
                  if (controller.dropdownSelectedScheme!.days.isNullOrEmpty) {
                    showToast(text: 'Select SWP days');
                    return;
                  }
                  if (isEdit) {
                    controller.updatedSelectedWithdrawalScheme(fundIdSelected!);
                  } else {
                    controller.moveToWithdrawalSchemes();
                  }
                  AutoRouter.of(context).popForced();
                }
              },
              text: '${isEdit ? 'Update' : 'Add'} Fund',
              margin: EdgeInsets.zero,
            ),
    );
  }

  Widget _buildSwpFormFields(
      BuildContext context, CreateSwpController controller) {
    if (controller.dropdownSelectedScheme != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!controller.isFundDisabledForSwp)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: DatesSelector(
                  orderType: 'SWP',
                  selectedDays: controller.dropdownSelectedScheme?.days ?? [],
                  onChanged: (List<int> days) {
                    controller.updateSelectedSchemeDays(days);
                  },
                ),
              ),
            AmountInput(
              amountController: controller.amountController,
              enabled: !controller.isFundDisabledForSwp,
              minAmount: controller
                  .dropdownSelectedScheme?.schemeData.minWithdrawalAmt,
              validator: (value) {
                if (controller.isFundDisabledForSwp) {
                  return 'Withdrawal is not possible currently as your fund balance is below the minimum withdrawal amount specified for the selected SWP';
                }

                final currentValue = (controller.dropdownSelectedScheme
                        ?.schemeData.folioOverview?.currentValue ??
                    0);
                final minWithdrawalAmt = controller
                        .dropdownSelectedScheme?.schemeData.minWithdrawalAmt ??
                    0;
                final amount =
                    WealthyCast.toDouble(value?.replaceAll(',', '') ?? 0);
                if (amount == null) {
                  return 'Amount field is required';
                }

                final isAmountLessThanMin = minWithdrawalAmt > amount;
                if (isAmountLessThanMin) {
                  return 'Amount is less than min withdrawal amount';
                }

                final isAmountMoreThanAvailable = amount > currentValue;
                if (isAmountMoreThanAvailable) {
                  return "Amount is more than fund balance";
                }

                return null;
              },
              onChanged: (value) {
                controller.updateSelectedSchemeAmount(value);
              },
            ),
            if (!controller.isFundDisabledForSwp)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 30),
                    child: GoalDateInput(
                      controller: controller.startDateController,
                      label: 'Start Date',
                      onDateSelect: controller.updateSelectedSchemeStartDate,
                    ),
                  ),

                  // End Date
                  GoalDateInput(
                    controller: controller.endDateController,
                    label: 'End Date',
                    startDate: controller.dropdownSelectedScheme?.startDate,
                    onDateSelect: controller.updateSelectedSchemeEndDate,
                  )
                ],
              )
          ],
        ),
      );
    }
    return SizedBox();
  }
}
