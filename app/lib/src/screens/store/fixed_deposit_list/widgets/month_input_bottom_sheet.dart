import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MonthInputBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<FixedDepositsController>(
        builder: (controller) {
          return ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(top: 40),
                child: BorderedTextFormField(
                  helperText: '',
                  useLabelAsHint: true,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  label: 'Enter Tenure',
                  labelStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                  controller: controller.monthInputController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  suffixIcon: Container(
                    width: 80,
                    padding: EdgeInsets.only(right: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'Months',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                    NoLeadingSpaceFormatter(),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    final noOfMonths =
                        int.tryParse(controller.monthInputController.text);
                    if (noOfMonths == null) {
                      return 'Please enter month tenure period';
                    }
                    if (noOfMonths >
                        controller.fdListModel!.tenureMonths!.max!) {
                      return 'Maximum tenure is ${controller.fdListModel!.tenureMonths!.max} months';
                    }
                    if (noOfMonths <
                        controller.fdListModel!.tenureMonths!.min!) {
                      return 'Minimum tenure is ${controller.fdListModel!.tenureMonths!.min} months';
                    }
                    // if (noOfMonths % 6 != 0) {
                    //   return 'Please enter month tenure period in multiples of 6';
                    // }
                    return null;
                  },
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              ActionButton(
                text: 'Done',
                margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 30)
                    .copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                onPressed: () {
                  // close keyboard if opened
                  if (FocusManager.instance.primaryFocus!.hasFocus) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  }
                  if (controller.isMonthInputValid()) {
                    controller.updateTenurePeriod(
                      callApi: true,
                      month: int.parse(
                        controller.monthInputController.text,
                      ),
                    );
                    AutoRouter.of(context).popForced();
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }
}
