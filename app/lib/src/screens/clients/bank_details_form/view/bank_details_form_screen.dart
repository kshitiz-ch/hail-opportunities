import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/bank_details_form_controller.dart';
import 'package:app/src/controllers/demat/demats_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../widgets/floating_action_button_section.dart';

@RoutePage()
class BankDetailsFormScreen extends StatelessWidget {
  // Fields
  final Client? client;
  ClientAccountModel accountDetails;
  // final AccountDetailsModel? accountDetails;
  final VoidCallback? onProceed;

  // Constructor
  BankDetailsFormScreen({
    Key? key,
    required this.client,
    required this.accountDetails,
    this.onProceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize BankDetailsFormController
    Get.put(BankDetailsFormController(client, accountDetails));
    bool fromDematScreen = onProceed != null;

    List<String> bankAccountTypeOptions = [];

    bankAccountType.forEach((key, value) {
      bankAccountTypeOptions.add(key);
    });

    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontSize: 16,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );

    void goBackHandler() async {
      // If bank account is created, but user click back button
      // Then the bank account created should get updated on the demats controller
      if (fromDematScreen && Get.isRegistered<BankDetailsFormController>()) {
        BankDetailsFormController bankDetailsFormController =
            Get.find<BankDetailsFormController>();

        String bankAccountId =
            bankDetailsFormController.bankAccountResult.id ?? '';
        if (bankAccountId.isNotNullOrEmpty &&
            Get.isRegistered<DematsController>()) {
          DematsController dematsController = Get.find<DematsController>();

          dematsController.userBankAccounts
              .insert(0, bankDetailsFormController.bankAccountResult);
        }
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          goBackHandler();
          AutoRouter.of(context).popForced();
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        // App Bar
        appBar: CustomAppBar(
          showBackButton: true,
          onBackPress: () {
            goBackHandler();
            AutoRouter.of(context).popForced();
          },
          titleText: 'Add Bank Details',
          trailingWidgets: [
            if (onProceed == null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Step 2 of 3',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
              ),
          ],
        ),

        // Body
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(30, 16, 30, 130),
          child: GetBuilder<BankDetailsFormController>(
            initState: (_) {},
            dispose: (_) {
              if (fromDematScreen) {
                Get.delete<BankDetailsFormController>();
              }
            },
            builder: (controller) {
              final bankAccountBranch = controller
                      .bankAccountResult.branch.isNotNullOrEmpty
                  ? '${controller.bankAccountResult.branch![0].toUpperCase() + controller.bankAccountResult.branch!.substring(1).toLowerCase()} Branch'
                  : '';
              return Form(
                key: controller.bankDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client\'s Full Name',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 12.0,
                              color: ColorConstants.tertiaryBlack),
                    ),
                    SizedBox(height: 4),
                    Text(controller.client!.name!,
                        style:
                            Theme.of(context).primaryTextTheme.headlineSmall),

                    SizedBox(height: 44),

                    // Account Number Input Field
                    SimpleTextFormField(
                      enabled: controller.addBankDetailsState !=
                          NetworkState.loading,
                      controller: controller.accountNumberController,
                      label: "Bank Account Number",
                      hintText: "Eg. 20xxxxxxx20",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(18),
                      ],
                      onChanged: (value) {
                        controller.update();
                      },
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isNullOrEmpty) {
                          return 'Account Number is required.';
                        }

                        if (value!.length < 9 || value.length > 18) {
                          return 'Account number should be 9 digits to 18 digits long.';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 40),

                    // IFSC Input Field
                    SimpleTextFormField(
                      enabled: (controller.accountNumberController?.text
                                  .isNotNullOrEmpty ??
                              false) &&
                          controller.addBankDetailsState !=
                              NetworkState.loading,
                      controller: controller.ifscController,
                      label: "IFSC Code",
                      hintText: 'Eg ICICI0001234',
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            '[0-9a-zA-Z]',
                          ),
                        ),
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      suffixIcon:
                          controller.ifscState == NetworkState.loading ||
                                  controller.addBankDetailsState ==
                                      NetworkState.loading
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorConstants.primaryAppColor,
                                  ),
                                )
                              : controller.ifscState == NetworkState.loaded
                                  ? Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    )
                                  : null,
                      onChanged: (value) {
                        if (value.length == 11) {
                          if (controller
                                  .accountNumberController?.text.isEmpty ??
                              false) {
                            showToast(text: 'Please enter account number');
                          } else {
                            controller.updateIfsc();
                          }
                        }
                      },
                      onSubmitted: (value) {
                        if (value.length == 11) {
                          if (controller
                                  .accountNumberController?.text.isEmpty ??
                              false) {
                            showToast(text: 'Please enter account number');
                          } else {
                            controller.updateIfsc();
                          }
                        }
                      },
                      validator: (value) {
                        if (value.isNullOrEmpty) {
                          return 'IFSC code is required.';
                        }

                        if (value!.length != 11) {
                          return 'IFSC code should be 11 digits long.';
                        }

                        return null;
                      },
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: SimpleDropdownFormField<String>(
                        hintText: 'Please choose an option',
                        items: bankAccountTypeOptions,
                        customText: (value) {
                          return bankAccountType[value];
                        },
                        useLabelAsHint: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
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
                      ),
                    ),

                    SizedBox(height: 42),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: (controller.ifscState == NetworkState.loaded &&
                              controller
                                  .bankAccountResult.address.isNotNullOrEmpty)
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColorConstants.secondaryAppColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${controller.bankAccountResult.bank}',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  if (controller.bankAccountResult.branch
                                      .isNotNullOrEmpty)
                                    Text(
                                      bankAccountBranch,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontSize: 12,
                                              color:
                                                  ColorConstants.tertiaryBlack),
                                    )
                                ],
                              ),
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: FloatingActionButtonSection(
          onProceed: onProceed,
        ),
      ),
    );
  }
}
