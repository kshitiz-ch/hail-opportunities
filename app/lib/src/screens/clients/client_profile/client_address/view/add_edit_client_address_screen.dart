import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:app/src/screens/clients/client_profile/client_address/widgets/discard_address_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@RoutePage()
class AddEditClientAddressScreen extends StatelessWidget {
  final int? editIndex;

  const AddEditClientAddressScreen({Key? key, this.editIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isEdit = editIndex != null;
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: isEdit ? 'Edit Address' : 'Add Address',
        onBackPress: () {
          final controller = Get.find<ClientAddressController>();
          if (controller.isInputFieldEmpty) {
            AutoRouter.of(context).popForced();
          } else {
            CommonUI.showBottomSheet(
              context,
              child: DiscardAddressBottomSheet(
                isEdit: isEdit,
              ),
            );
          }
        },
      ),
      body: GetBuilder<ClientAddressController>(
        builder: (ClientAddressController controller) {
          List<String> availableCountries =
              controller.countries.map((e) => e.name!).toList();
          List<String>? availableStates = [];
          List<String>? availableCities = [];

          if (controller.selectedCountryIndex != null &&
              controller.selectedCountryIndex! >= 0 &&
              controller.selectedCountryIndex! < availableCountries.length) {
            availableStates = controller
                .countries[controller.selectedCountryIndex!].state
                ?.map((e) => e.name!)
                .toList();
          }

          if (availableStates.isNotNullOrEmpty &&
              controller.selectedStateIndex != null &&
              controller.selectedStateIndex! >= 0 &&
              controller.selectedStateIndex! < availableStates!.length) {
            availableCities = controller
                .countries[controller.selectedCountryIndex!]
                .state![controller.selectedStateIndex!]
                .city
                ?.map((e) => e.name!)
                .toList();
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 20),
            child: Form(
              key: controller.addressFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonClientUI.borderTextFormField(
                    context,
                    hintText: 'Address line 1',
                    controller: controller.addressline1InputController!,
                    maxLength: controller.addressLineMaxLength,
                    validator: (value) {
                      if (value.isNullOrEmpty) {
                        return 'Address line 1 is required';
                      }
                      if ((value?.length ?? 0) >
                          controller.addressLineMaxLength) {
                        return 'Address line 1 cannot exceed ${controller.addressLineMaxLength} characters';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: CommonClientUI.borderTextFormField(
                      context,
                      hintText: 'Address line 2',
                      controller: controller.addressline2InputController!,
                      maxLength: controller.addressLineMaxLength,
                      validator: (value) {
                        if ((value?.length ?? 0) >
                            controller.addressLineMaxLength) {
                          return 'Address line 2 cannot exceed ${controller.addressLineMaxLength} characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: CommonClientUI.borderTextFormField(
                      context,
                      hintText: 'Address line 3',
                      controller: controller.addressline3InputController!,
                      maxLength: controller.addressLineMaxLength,
                      validator: (value) {
                        if ((value?.length ?? 0) >
                            controller.addressLineMaxLength) {
                          return 'Address line 3 cannot exceed ${controller.addressLineMaxLength} characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  CommonClientUI.borderTextFormField(
                    context,
                    hintText: 'Pincode',
                    controller: controller.pincodeInputController!,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.length == 6) {
                        controller.getAddressFromPin(value);
                      }
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: CommonClientUI.popupDropDownField(
                      context: context,
                      hint: 'Country',
                      selectedValue: controller.countryInputController!.text,
                      inputController: controller.countryInputController!,
                      items: controller.countries.map((e) => e.name!).toList(),
                      errorMessage: '',
                      onChanged: (value, index) {
                        controller.onChangeCountry(value, index);
                      },
                    ),
                  ),
                  CommonClientUI.popupDropDownField(
                    context: context,
                    hint: 'State',
                    inputController: controller.stateInputController!,
                    selectedValue: controller.stateInputController!.text,
                    items: availableStates ?? [],
                    errorMessage:
                        'Please first update country before choosing state',
                    onChanged: (value, index) {
                      controller.onChangeState(value, index);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: CommonClientUI.popupDropDownField(
                      context: context,
                      hint: 'City',
                      inputController: controller.cityInputController!,
                      selectedValue: controller.cityInputController!.text,
                      items: availableCities ?? [],
                      errorMessage:
                          'Please first update country & state before choosing city',
                      onChanged: (value, index) {
                        controller.onChangeCity(value);
                      },
                    ),
                  ),
                  CommonClientUI.borderTextFormField(
                    context,
                    hintText: 'Save Address as',
                    controller: controller.addressTitleController!,
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildAddAddressButton(context),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    final isEdit = editIndex != null;

    return GetBuilder<ClientAddressController>(
      builder: (ClientAddressController controller) {
        return ActionButton(
          showProgressIndicator:
              controller.addEditAddress.state == NetworkState.loading,
          text: isEdit ? 'Edit Address' : 'Add Address',
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          onPressed: () async {
            if (controller.addressFormKey.currentState?.validate() ?? false) {
              if (isEdit) {
                await controller.updateClientAddress(editIndex!);
                showToast(text: controller.addEditAddress.message);
                if (controller.addEditAddress.state == NetworkState.loaded) {
                  controller.getClientAddressDetail();
                  AutoRouter.of(context)
                      .popUntilRouteWithName(ClientAddressRoute.name);
                }
              } else {
                await controller.addClientAddress();
                showToast(text: controller.addEditAddress.message);
                if (controller.addEditAddress.state == NetworkState.loaded) {
                  controller.getClientAddressDetail();
                  AutoRouter.of(context)
                      .popUntilRouteWithName(ClientAddressRoute.name);
                }
              }
            }
          },
        );
      },
    );
  }
}
