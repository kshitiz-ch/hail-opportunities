import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/screens/home/empanelment/widgets/empanelment_form_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmpanelmentActionButton extends StatelessWidget {
  const EmpanelmentActionButton(
      {super.key,
      required this.actionButtonText,
      this.fromDialog = false,
      this.isDisabled = false});

  final String actionButtonText;
  final bool fromDialog;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmpanelmentController>(
      builder: (controller) {
        return ActionButton(
          isDisabled: isDisabled,
          text: actionButtonText,
          showProgressIndicator: controller.empanelmentAddressResponse.state ==
              NetworkState.loading,
          onPressed: () async {
            // if (controller.isAddressMissing) {
            //   await controller.getAgentEmpanelmentAddress();
            // }

            if (controller.empanelmentAddressResponse.state ==
                    NetworkState.cancel ||
                controller.empanelmentAddressResponse.state ==
                    NetworkState.loaded) {
              if (controller.isAddressMissing) {
                CommonUI.showBottomSheet(
                  context,
                  child: EmpanelmentFormBottomsheet(),
                );
              } else if (controller.isOrderIdExists) {
                if (fromDialog) {
                  AutoRouter.of(context).popForced();
                }

                controller.initRazorPay();
              } else {
                CommonUI.showBottomSheet(
                  context,
                  child: EmpanelmentFormBottomsheet(),
                );
              }
            } else if (controller.empanelmentAddressResponse.state ==
                NetworkState.error) {
              CommonUI.showBottomSheet(
                context,
                child: EmpanelmentFormBottomsheet(),
              );
            }
          },
        );
      },
    );
  }
}
