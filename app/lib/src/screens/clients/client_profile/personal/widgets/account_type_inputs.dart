import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/client/personal_form_controller.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'input_container.dart';

class AccountTypeInputs extends StatelessWidget {
  final accountTypesTextMap = {
    TaxStatus.indianResident: ['Individual', 'Joint', 'Minor'],
    TaxStatus.nonResidentIndian: ['NRO', 'NRE'],
    TaxStatus.nonIndividual: ['Corporate', 'Trust', 'HUF', 'GOVT', 'OTHER'],
  };

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientPersonalFormController>(
      builder: (controller) {
        return Column(
          children: [
            _buildTaxStatus(context, controller),
            _buildAccountType(context, controller),
            if (controller.panUsageType != PanUsageType.GUARDIAN)
              _buildPanInput(context, controller),
            if (controller.panUsageType == PanUsageType.GUARDIAN)
              _buildGuardianInputs(context, controller),
            if (controller.panUsageSubtype == PanUsageSubtype.DOUBLE_JOIN ||
                controller.panUsageSubtype == PanUsageSubtype.TRIPLE_JOIN)
              _buildSecondMemberInputs(context, controller),
            if (controller.panUsageSubtype == PanUsageSubtype.TRIPLE_JOIN)
              _buildThirdMemberInputs(context, controller)
          ],
        );
      },
    );
  }

  Widget _buildAccountType(
      BuildContext context, ClientPersonalFormController controller) {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return InputContainer(
      child: SimpleDropdownFormField<String>(
        hintText: 'Select Account Type',
        items: TaxStatus.getAccountTypes(controller.taxStatus ?? ''),
        customDropdownBuilder: (value) {
          return Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: ColorConstants.borderColor)),
            ),
            child: Text(
              value ?? '',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          );
        },
        value: controller.accountType,
        // contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: textStyle,
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        label: 'Account type',
        onChanged: (val) {
          controller.accountType = val;
          final panDetails = AccountType.getPanPanSubtype(val ?? '');
          controller.panUsageType = panDetails.first;
          controller.panUsageSubtype = panDetails.last;
          controller.formKey.currentState!.validate();
          controller.update();
        },
        validator: (val) {
          if (val == null) {
            return 'This field is required.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildTaxStatus(
      BuildContext context, ClientPersonalFormController controller) {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return InputContainer(
      child: SimpleDropdownFormField<String>(
        customMenuItemHeight: 80,
        hintText: 'Select Tax Status',
        items: [
          TaxStatus.indianResident,
          TaxStatus.nonResidentIndian,
          TaxStatus.nonIndividual
        ],
        customDropdownBuilder: (value) {
          return _buildTaxStatusDropdownItem(value!, context);
        },
        value: controller.taxStatus,
        // contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: textStyle,
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        label: 'Tax Status',
        onChanged: (val) {
          controller.taxStatus = val;
          controller.formKey.currentState!.validate();
          controller.update();
        },
        validator: (val) {
          if (val == null) {
            return 'This field is required.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildTaxStatusDropdownItem(String taxStatus, BuildContext context) {
    final accountTypes = accountTypesTextMap[taxStatus] ?? [];
    final taxStatusText = taxStatus.toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorConstants.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taxStatusText,
            style:
                context.headlineMedium?.copyWith(color: ColorConstants.black),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              children: List.generate(
                accountTypes.length,
                (index) {
                  final accountType = accountTypes[index];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        accountType.toUpperCase(),
                        style: context.titleLarge
                            ?.copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      if (accountType != accountTypes.last)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color:
                                ColorConstants.tertiaryBlack.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        )
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: controller.panUsageType == PanUsageType.JOINT
                ? "Primary Member PAN"
                : "PAN Number",
            controller: controller.panController,
            enabled: controller.isEditFlow && !controller.disableEditPanOrName,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[0-9a-zA-Z]',
                ),
              ),
              LengthLimitingTextInputFormatter(10),
              TextInputFormatter.withFunction(
                (oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  );
                },
              )
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PAN Number is required.';
              }

              if (value.length != 10) {
                return 'PAN Number should be 10 characters long';
              }

              return null;
            },
          ),
          if (controller.isEditFlow && controller.disableEditPanOrName)
            CommonClientUI.disabledFieldInfo(context)
        ],
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildGuardianInputs(context, controller) {
    return Column(
      children: [
        _buildGuradianPanInput(context, controller),
        _buildGuardianNameInput(context, controller),
      ],
    );
  }

  Widget _buildGuradianPanInput(
      context, ClientPersonalFormController controller) {
    return InputContainer(
      child: CommonClientUI.borderTextFormField(
        context,
        hintText: "Guardian\'s Pan",
        controller: controller.guardiansPanController,
        enabled: controller.isEditFlow,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(
              '[0-9a-zA-Z]',
            ),
          ),
          LengthLimitingTextInputFormatter(10),
          TextInputFormatter.withFunction(
            (oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.toUpperCase(),
              );
            },
          )
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'PAN Number is required.';
          }

          if (value.length != 10) {
            return 'PAN Number should be 10 characters long';
          }

          return null;
        },
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildGuardianNameInput(
      context, ClientPersonalFormController controller) {
    return InputContainer(
      child: CommonClientUI.borderTextFormField(
        context,
        hintText: 'Guardian\'s Name',
        controller: controller.guardiansNameController,
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildSecondMemberInputs(context, controller) {
    return Column(
      children: [
        InputContainer(
          child: CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: '2nd Member Pan',
            controller: controller.panTwoController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[0-9a-zA-Z]',
                ),
              ),
              LengthLimitingTextInputFormatter(10),
              TextInputFormatter.withFunction(
                (oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  );
                },
              )
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PAN Number is required.';
              }

              if (value.length != 10) {
                return 'PAN Number should be 10 characters long';
              }

              return null;
            },
          ),
          showBorder: !controller.isEditFlow,
        ),
        InputContainer(
          child: CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: '2nd Member Name',
            controller: controller.jointNameTwoController,
          ),
          showBorder: !controller.isEditFlow,
        )
      ],
    );
  }

  Widget _buildThirdMemberInputs(context, controller) {
    return Column(
      children: [
        InputContainer(
          child: CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: '3rd Member Pan',
            controller: controller.panThreeController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[0-9a-zA-Z]',
                ),
              ),
              LengthLimitingTextInputFormatter(10),
              TextInputFormatter.withFunction(
                (oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  );
                },
              )
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PAN Number is required.';
              }

              if (value.length != 10) {
                return 'PAN Number should be 10 characters long';
              }

              return null;
            },
          ),
          showBorder: !controller.isEditFlow,
        ),
        InputContainer(
          child: CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: '3rd Member Name',
            controller: controller.jointNameThreeController,
          ),
          showBorder: !controller.isEditFlow,
        )
      ],
    );
  }
}
