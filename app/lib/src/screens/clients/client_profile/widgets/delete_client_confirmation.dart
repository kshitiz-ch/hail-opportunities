import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/controllers/client/client_profile_controller.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DeleteClientConfirmationBottomSheet extends StatelessWidget {
  const DeleteClientConfirmationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientProfileController>(
      id: GetxId.delete,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(30)
              .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delete Confirmation',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                  ),
                  CommonUI.bottomsheetCloseIcon(context),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 40),
              //   child: Text(
              //     'Are you sure you want to Delete\nyour Account ?',
              //     style:
              //         Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              //               color: ColorConstants.black,
              //               fontWeight: FontWeight.w500,
              //               height: 24 / 16,
              //             ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 24),
                child: Text(
                  'Type “DELETE” below to delete your client account',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w400,
                        height: 17 / 14,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SimpleTextFormField(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.black,
                        height: 17 / 14,
                      ),
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter("delete".length),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      },
                    )
                  ],
                  contentPadding: EdgeInsets.only(bottom: 12, top: 6),
                  label: 'Type “DELETE”',
                  useLabelAsHint: true,
                  controller: controller.deleteTextController,
                  onSubmitted: (value) {},
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.lightRedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      AllImages().alertIcon,
                      height: 24,
                      width: 24,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'You can only delete clients who have not completed kyc or don\'t have any investments with Wealthy',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.errorTextColor,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              ActionButton(
                text: 'Delete Account',
                showProgressIndicator: controller.deleteClientResponse.state ==
                    NetworkState.loading,
                margin: EdgeInsets.zero,
                onPressed: () async {
                  if (controller.deleteTextController.text.isNotNullOrEmpty &&
                      controller.deleteTextController.text.toLowerCase() ==
                          'delete') {
                    await controller.deleteClient();

                    if (controller.deleteClientResponse.state ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).push(
                        SuccessRoute(
                          title:
                              'Client ${(controller.client?.name.isNotNullOrEmpty ?? false) ? '(${controller.client?.name}) ' : ''}deleted Successfully',
                          actionButtonText: 'Back to Clients',
                          onPressed: () {
                            AutoRouter.of(context)
                                .popUntil(ModalRoute.withName(BaseRoute.name));
                            final NavigationController navController =
                                Get.find<NavigationController>();
                            final clientListController =
                                Get.isRegistered<ClientListController>()
                                    ? Get.find<ClientListController>()
                                    : null;

                            if (clientListController != null) {
                              clientListController.resetPagination();
                              clientListController.queryClientList();
                            }

                            navController.setCurrentScreen(Screens.CLIENTS);
                          },
                        ),
                      );
                    } else if (controller.deleteClientResponse.state ==
                        NetworkState.error) {
                      showToast(
                          text: controller.deleteClientResponse.message,
                          context: context);
                    }
                  } else {
                    showToast(
                      text: 'Type “DELETE” to delete your client account',
                      context: context,
                    );
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }
}
