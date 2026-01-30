import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:app/src/controllers/client/nominee_form_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Widget for handling nominee address details in the client profile section.
/// This widget allows users to either select from existing client addresses
/// or create a new address for the nominee.
const String NEW_ADDRESS_ID = "new";

class NomineeAddressDetail extends StatelessWidget {
  /// Controller for managing nominee form data and state
  final clientNomineeController = Get.find<ClientNomineeFormController>();
  final clientAddressController =
      Get.find<ClientAddressController>(tag: 'client_nominee');

  NomineeAddressDetail({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize text style based on current theme
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );

    // Build list of available addresses from client's existing addresses
    // Each address is represented as a map with id and title
    final addressList = List.generate(
        clientAddressController.clientAddressModelList.length, (index) {
      final address = clientAddressController.clientAddressModelList[index];
      return {
        "id": address.externalID ?? '',
        "title": address.title ??
            address.line1 ??
            '', // Fallback to line1 if no title
      };
    });

    // Add option to create a new address
    addressList.add({
      "id": NEW_ADDRESS_ID,
      "title": "Add New Address",
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address section title
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            'Address',
            style: textStyle.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Radio button group for address selection
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 30).copyWith(left: 5),
          child: RadioButtons(
            items: addressList.map((address) => address["id"]).toList(),
            spacing: 20,
            runSpacing: 10,
            direction: Axis.vertical,
            // Custom builder for each radio button item
            itemBuilder: (context, val, index) {
              final isSelected =
                  clientNomineeController.selectedAddressId == val;
              final title = addressList[index]["title"];

              return Text(
                (title ?? 'Address $index')
                    .toCapitalized(), // Fallback title if none provided
                style: textStyle.copyWith(
                  // Highlight selected address with primary color
                  color: isSelected
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.tertiaryBlack,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              );
            },
            selectedValue: clientNomineeController.selectedAddressId,
            onTap: (value) {
              // Update selected address in controller
              clientNomineeController.selectedAddressId = value;

              // Determine if we're editing an existing address or creating new one
              final editIndex = value == NEW_ADDRESS_ID
                  ? null // null means creating new address
                  : addressList.indexWhere((e) => e["id"] == value);

              // Initialize the address form controllers with selected address data
              clientAddressController.initInputController(editIndex: editIndex);

              // Trigger UI update
              clientNomineeController.update();
            },
          ),
        ),

        // Show address form only if an address is selected
        if (clientNomineeController.selectedAddressId.isNotNullOrEmpty)
          _buildNewAddressForm(
            context,
            // Disable editing if existing address is selected (not NEW_ADDRESS_ID)
            clientNomineeController.selectedAddressId != NEW_ADDRESS_ID,
          )
      ],
    );
  }

  /// Builds the address form for creating new address or viewing existing one
  ///
  /// [context] - Build context for UI
  /// [disableField] - Whether to disable form fields (true for existing addresses)
  Widget _buildNewAddressForm(BuildContext context, bool disableField) {
    return GetBuilder<ClientAddressController>(
        tag: 'client_nominee', // Specific tag for nominee address controller
        builder: (controller) {
          // Get available countries from controller
          List<String> availableCountries =
              controller.countries.map((e) => e.name!).toList();
          List<String>? availableStates = [];
          List<String>? availableCities = [];

          // Populate states based on selected country
          if (controller.selectedCountryIndex != null &&
              controller.selectedCountryIndex! >= 0 &&
              controller.selectedCountryIndex! < availableCountries.length) {
            availableStates = controller
                .countries[controller.selectedCountryIndex!].state
                ?.map((e) => e.name!)
                .toList();
          }

          // Populate cities based on selected state
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

          return IgnorePointer(
            ignoring:
                disableField, // Disable interaction if viewing existing address
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Address Line 1 - Primary address field
                CommonClientUI.borderTextFormField(
                  context,
                  hintText: 'Address line 1',
                  isCompulsory: true,
                  controller: controller.addressline1InputController!,
                  maxLength:
                      disableField ? null : controller.addressLineMaxLength,
                  validator: (value) {
                    if (disableField) {
                      return null; // Skip validation if field is disabled
                    }

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

                // Address Line 2 - Secondary address field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: CommonClientUI.borderTextFormField(
                    context,
                    hintText: 'Address line 2',
                    controller: controller.addressline2InputController!,
                    maxLength:
                        disableField ? null : controller.addressLineMaxLength,
                    validator: (value) {
                      if (disableField) {
                        return null; // Skip validation if field is disabled
                      }
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
                    maxLength:
                        disableField ? null : controller.addressLineMaxLength,
                    validator: (value) {
                      if (disableField) {
                        return null; // Skip validation if field is disabled
                      }

                      if ((value?.length ?? 0) >
                          controller.addressLineMaxLength) {
                        return 'Address line 3 cannot exceed ${controller.addressLineMaxLength} characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Pincode field with validation and auto-address lookup
                CommonClientUI.borderTextFormField(
                  context,
                  hintText: 'Pincode',
                  isCompulsory: true,
                  controller: controller.pincodeInputController!,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Auto-fetch address details when pincode is 6 digits
                    if (value.length == 6) {
                      controller.getAddressFromPin(value);
                    }
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6), // Limit to 6 digits
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                ),

                // Country selection dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: CommonClientUI.popupDropDownField(
                    context: context,
                    hint: 'Country',
                    isCompulsory: true,
                    selectedValue:
                        controller.countryInputController?.text ?? '',
                    inputController: controller.countryInputController!,
                    items: controller.countries.map((e) => e.name!).toList(),
                    errorMessage: '',
                    onChanged: (value, index) {
                      // Update country and reset dependent fields
                      controller.onChangeCountry(value, index);
                    },
                  ),
                ),

                // State selection dropdown (depends on country)
                CommonClientUI.popupDropDownField(
                  context: context,
                  hint: 'State',
                  isCompulsory: true,
                  inputController: controller.stateInputController!,
                  selectedValue: controller.stateInputController?.text ?? '',
                  items: availableStates ?? [],
                  errorMessage:
                      'Please first update country before choosing state',
                  onChanged: (value, index) {
                    // Update state and reset city field
                    controller.onChangeState(value, index);
                  },
                ),

                // City selection dropdown (depends on state)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: CommonClientUI.popupDropDownField(
                    context: context,
                    hint: 'City',
                    isCompulsory: true,
                    inputController: controller.cityInputController!,
                    selectedValue: controller.cityInputController?.text ?? '',
                    items: availableCities ?? [],
                    errorMessage:
                        'Please first update country & state before choosing city',
                    onChanged: (value, index) {
                      controller.onChangeCity(value);
                    },
                  ),
                ),

                // Address title field for saving the address with a custom name
                CommonClientUI.borderTextFormField(
                  context,
                  isCompulsory: true,
                  hintText: 'Save Address as',
                  controller: controller.addressTitleController!,
                ),
              ],
            ),
          );
        });
  }
}
