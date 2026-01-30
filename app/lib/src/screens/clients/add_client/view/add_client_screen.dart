import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class AddClientScreen extends StatelessWidget {
  final Function(Client, bool)? onClientAdded;
  final showAddContacts;

  TextStyle? hintStyle;
  TextStyle? textStyle;
  AddClientScreen({Key? key, this.onClientAdded, this.showAddContacts = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _countryCode = indiaCountryCode;
    hintStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    textStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
    // Initialize AddClientController
    final controller = Get.put(AddClientController());

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Add Client',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        physics: ClampingScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhoneNumberInput(context, _countryCode),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
                child: InkWell(
                  onTap: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "add_from_contacts",
                      screen: 'clients',
                      screenLocation: 'add_client',
                    );

                    _navigateToSearchContactScreen(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AllImages().contactsBookIcon,
                        width: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Add from phone contacts',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(color: ColorConstants.primaryAppColor),
                      ),
                    ],
                  ),
                ),
              ),
              _buildNameInput(context),
              _buildEmailInput(context),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FixedCenterDockedFabLocation(),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildPhoneNumberInput(
    BuildContext context,
    String countryCode,
  ) {
    //
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: GetBuilder<AddClientController>(
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.phoneNumberController,
            label: 'Client’s Phone Number',
            style: textStyle,
            useLabelAsHint: true,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            textInputAction: TextInputAction.next,
            borderColor: ColorConstants.lightGrey,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                  getPhoneNumberLimitByCountry(controller.countryCode)),
            ],
            prefixIconSize: Size(100, 36),
            prefixIcon: CountryCodePicker(
              padding: EdgeInsets.only(right: 8),
              initialSelection: indiaCountryCode,
              flagWidth: 20.0,
              showFlag: true,
              showFlagDialog: true,
              textStyle:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
              onChanged: (CountryCode countryCode) {
                controller.countryCode = countryCode.dialCode;
                controller.update();
              },
            ),
            suffixIcon: controller.phoneNumberController!.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.phoneNumberController!.clear();
                    },
                  ),
            onChanged: (val) {
              controller.update([GetxId.phoneNumberInput]);
            },
            onTap: () {
              MixPanelAnalytics.trackWithAgentId(
                "phone_number_entered",
                screen: 'clients',
                screenLocation: 'add_client',
              );
            },
            validator: (value) {
              return phoneNumberInputValidation(value, controller.countryCode);
            },
          );
        },
      ),
    );
  }

  void _navigateToSearchContactScreen(BuildContext context) async {
    void onClientSelected(Client client) {
      void updatePhoneNumberController(String phoneNumber) {
        Get.find<AddClientController>().phoneNumberController!.text =
            phoneNumber;
        AutoRouter.of(context).popForced();
      }

      void updateNameController(String name) {
        if (name.isNullOrEmpty || !Get.isRegistered<AddClientController>()) {
          return;
        }

        RegExp regExp = RegExp(r"^[a-zA-Z\s]+$");

        bool hasOnlyAlphabets = regExp.hasMatch(name.trim());

        if (!hasOnlyAlphabets) {
          Get.find<AddClientController>().nameController!.clear();
          return;
        }

        Get.find<AddClientController>().nameController!.text = name.trim();
      }

      if (Get.isRegistered<AddClientController>()) {
        if (client.phoneNumber!.startsWith("+91") &&
            client.phoneNumber!.split("+91")[1].length == 10) {
          updateNameController(client.name!);
          updatePhoneNumberController(client.phoneNumber!.split("+91")[1]);
          return;
        }

        if (client.phoneNumber!.length == 10) {
          updateNameController(client.name!);
          updatePhoneNumberController(client.phoneNumber!);
          return;
        }

        showToast(
            text: "Unable to add the number. Please try to add it manually");
      }
    }

    try {
      bool isContactPermissionGranted = await Permission.contacts.isGranted;
      if (isContactPermissionGranted) {
        AutoRouter.of(context)
            .push(SearchContactsRoute(onClientSelected: onClientSelected));
      } else {
        List<Permission> permissionList = [
          Permission.contacts,
        ];

        Map<Permission, PermissionStatus> permissionStatuses =
            await permissionList.request();

        if (permissionStatuses[Permission.contacts]!.isGranted) {
          AutoRouter.of(context)
              .push(SearchContactsRoute(onClientSelected: onClientSelected));
        } else {
          showToast(text: "Please allow permission to access contacts");
        }
      }
    } catch (error) {
      showToast(text: "Please allow permission to access contacts");
    }
  }

  Widget _buildNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: GetBuilder<AddClientController>(
        id: 'name-input',
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.nameController,
            label: 'Client Name',
            style: textStyle,
            useLabelAsHint: true,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            textInputAction: TextInputAction.next,
            borderColor: ColorConstants.lightGrey,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[a-zA-Z ]",
                ),
              ),
              NoLeadingSpaceFormatter()
            ],
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            suffixIcon: controller.nameController!.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.nameController!.clear();
                      controller.update(['name-input']);
                    },
                  ),
            onChanged: (val) {
              controller.update(['name-input']);
            },
            onTap: () {
              MixPanelAnalytics.trackWithAgentId(
                "client_name_entered",
                screen: 'clients',
                screenLocation: 'add_client',
              );
            },
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Name is required.';
              }

              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildEmailInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: GetBuilder<AddClientController>(
        id: 'email-input',
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.emailController,
            label: 'Client Email ID',
            style: textStyle,
            useLabelAsHint: true,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            textInputAction: TextInputAction.done,
            borderColor: ColorConstants.lightGrey,
            inputFormatters: <TextInputFormatter>[],
            keyboardType: TextInputType.emailAddress,
            suffixIcon: controller.emailController!.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.emailController!.clear();
                      controller.update(['email-input']);
                    },
                  ),
            onChanged: (val) {
              controller.update(['email-input']);
            },
            onTap: () {
              MixPanelAnalytics.trackWithAgentId(
                "client_email_entered",
                screen: 'clients',
                screenLocation: 'add_client',
              );
            },
            validator: (value) {
              if (value.isNotNullOrEmpty && !isEmailValid(value ?? '')) {
                return 'Please enter valid email ID.';
              }

              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<AddClientController>(
      id: 'add-client',
      dispose: (_) {
        // Delete AddClientController
        Get.delete<AddClientController>();
      },
      builder: (controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Add Client',
              showProgressIndicator:
                  controller.addClientState == NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                MixPanelAnalytics.trackWithAgentId(
                  "add_client_click",
                  screen: 'clients',
                  screenLocation: 'add_client',
                );

                await controller.addClient(onClientAdded);
              },
            );
          },
        );
      },
    );
  }
}
