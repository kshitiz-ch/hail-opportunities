import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteAddressBottomSheet extends StatelessWidget {
  final int index;

  const DeleteAddressBottomSheet({Key? key, required this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Delete Address ? ",
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.black,
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "All information will be deleted. \nDo you wish to continue?",
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: 'Cancel',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    AutoRouter.of(context).popForced();
                  },
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.primaryAppColor,
                      ),
                  bgColor: ColorConstants.primaryAppv3Color,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GetBuilder<ClientAddressController>(
                  builder: (ClientAddressController controller) {
                    return ActionButton(
                      showProgressIndicator: controller.deleteAddress.state ==
                          NetworkState.loading,
                      text: 'Continue',
                      margin: EdgeInsets.zero,
                      onPressed: () async {
                        await controller.deleteClientAddress(
                          index,
                          context,
                        );
                        if (controller.deleteAddress.state ==
                            NetworkState.loaded) {
                          controller.getClientAddressDetail();
                        } else if (controller.deleteAddress.state ==
                            NetworkState.error) {
                          showToast(text: controller.deleteAddress.message);
                        }
                        AutoRouter.of(context).popForced();
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
