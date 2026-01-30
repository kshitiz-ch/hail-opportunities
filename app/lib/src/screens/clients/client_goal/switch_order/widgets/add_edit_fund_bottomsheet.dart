import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'amount_section.dart';
import 'scheme_dropdown.dart';

class AddEditFundBottomSheet extends StatelessWidget {
  const AddEditFundBottomSheet({Key? key, this.editIndex}) : super(key: key);

  final int? editIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 50),
      child: GetBuilder<SwitchOrderController>(
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
                  flex: controller.dropdownSelectedScheme?.switchOut == null
                      ? 0
                      : 1,
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 25).copyWith(
                        bottom: controller.amountInputFocusNode.hasFocus
                            ? MediaQuery.of(context).viewInsets.bottom
                            : 30),
                    children: [
                      // Switch Out

                      SchemeDropdown(
                        switchFundType: SwitchFundType.SwitchOut,
                      ),

                      if (controller.dropdownSelectedScheme?.switchOut != null)
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: SchemeDropdown(
                            switchFundType: SwitchFundType.SwitchIn,
                          ),
                        ),

                      if (controller.dropdownSelectedScheme?.switchOut !=
                              null &&
                          controller.dropdownSelectedScheme?.switchIn != null)
                        AmountSection(),
                    ],
                  ),
                ),
                _buildAddSwitchButton(context, controller)
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
            editIndex != null ? 'Edit Fund' : 'Add Funds for Switch',
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

  Widget _buildAddSwitchButton(
      BuildContext context, SwitchOrderController controller) {
    final isValid = controller.isFormValid;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24.0),
      child: ActionButton(
        isDisabled: !isValid,
        onPressed: () {
          if (isValid) {
            controller.moveToSwitchOrderSchemes(editIndex: editIndex);
            AutoRouter.of(context).popForced();
          }
        },
        text: '${editIndex != null ? 'Update' : 'Add'} Switch',
        margin: EdgeInsets.zero,
      ),
    );
  }
}
