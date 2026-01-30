import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/bank_controller.dart';
import 'package:app/src/controllers/client/bank_form_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientBankFormScreen extends StatelessWidget {
  ClientBankFormScreen(
      {Key? key, this.client, this.bankAccount, this.onBankAdded})
      : super(key: key);

  final BankAccountModel? bankAccount;
  Client? client;
  final Function(BankAccountModel? bank)? onBankAdded;

  @override
  Widget build(BuildContext context) {
    if (client == null && Get.isRegistered<ClientDetailController>()) {
      client = Get.find<ClientDetailController>().client;
    }

    List<String> bankAccountTypeOptions = [];

    bankAccountType.forEach((key, value) {
      bankAccountTypeOptions.add(key);
    });

    return GetBuilder<ClientBankFormController>(
      init: ClientBankFormController(client, bankAccount),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText:
                '${controller.isEditFlow ? 'Update' : 'Add'} Bank Account',
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // Account Number
                    _buildAccountNumberInput(context, controller),

                    // IFSC
                    _buildIfscInput(context, controller),

                    // Account Type
                    _buildAccountTypeDropdown(
                        context, controller, bankAccountTypeOptions)
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildAddBankButton(context, controller),
        );
      },
    );
  }

  Widget _buildAccountNumberInput(
      BuildContext context, ClientBankFormController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: CommonClientUI.borderTextFormField(
        context,
        controller: controller.accountController,
        keyboardType: TextInputType.number,
        hintText: 'Bank Account No',
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(18),
        ],
        validator: (value) {
          if (value?.isNullOrEmpty ?? false) {
            return 'Account Number is required.';
          }

          if (value!.length < 9 || value.length > 18) {
            return 'Account number should be 9 digits to 18 digits long.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildIfscInput(
      BuildContext context, ClientBankFormController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: CommonClientUI.borderTextFormField(context,
          controller: controller.ifscController,
          hintText: 'IFSC',
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(
                '[0-9a-zA-Z]',
              ),
            ),
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(11),
          ], validator: (value) {
        if (value.isNullOrEmpty) {
          return 'IFSC code is required.';
        }

        if (value!.length != 11) {
          return 'IFSC code should be 11 digits long.';
        }

        return null;
      }),
    );
  }

  Widget _buildAccountTypeDropdown(
      BuildContext context,
      ClientBankFormController controller,
      List<String> bankAccountTypeOptions) {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontSize: 16,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );

    return SimpleDropdownFormField<String>(
      hintText: 'Please choose an option',
      items: bankAccountTypeOptions,
      customText: (value) {
        return bankAccountType[value] ?? "Savings";
      },
      // useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderRadius: 3,
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      value: controller.accountType,
      enabled: true,
      label: 'Account Type',
      onChanged: (val) {
        controller.accountType = val;
        controller.update();
      },
      validator: (value) {
        if (value == null) {
          return 'Account Type is required.';
        }

        return null;
      },
    );
  }

  Widget _buildAddBankButton(
      BuildContext context, ClientBankFormController controller) {
    return ActionButton(
      text: controller.isEditFlow ? 'Update' : 'Create',
      showProgressIndicator:
          controller.bankFormResponse.state == NetworkState.loading,
      onPressed: () async {
        if (controller.formKey.currentState!.validate()) {
          await controller.addBankDetails();

          if (controller.bankFormResponse.state == NetworkState.loaded) {
            showToast(
              text:
                  'Bank Account ${controller.isEditFlow ? 'Updated' : 'Added'}',
            );

            // Show Above Toast for 1 sec
            await Future.delayed(Duration(seconds: 1));

            if (onBankAdded != null) {
              onBankAdded!(controller.bankAccountResult);
            } else {
              AutoRouter.of(context).popUntilRouteWithName(
                ClientBankListRoute.name,
              );

              // Refetch Bank Accounts
              if (Get.isRegistered<ClientBankController>()) {
                Get.find<ClientBankController>().getClientBankAccounts();
              }

              // Refetch Investment Status
              if (Get.isRegistered<ClientDetailController>()) {
                Get.find<ClientDetailController>().getClientInvestmentStatus();
              }
            }
          } else {
            showToast(text: controller.bankFormResponse.message);
          }
        }
      },
    );
  }
}
