import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class EmpanelmentFormBottomsheet extends StatelessWidget {
  const EmpanelmentFormBottomsheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmpanelmentController>(
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Address',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineLarge!
                              .copyWith(fontSize: 18),
                        ),
                        InkWell(
                          onTap: () {
                            AutoRouter.of(context).popForced();
                          },
                          child: Icon(
                            Icons.close,
                            color: ColorConstants.tertiaryBlack,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your sales kit will be delivered to this address. Please review before proceeding to payment.',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                    )
                  ],
                ),
                SizedBox(height: 30),
                _buildForm(context, controller),
                ActionButton(
                  margin: EdgeInsets.zero,
                  showProgressIndicator:
                      controller.storeEmpanelmentAddressResponse.state ==
                              NetworkState.loading ||
                          controller.payEmpanelmentFeeResponse.state ==
                              NetworkState.loading,
                  text:
                      'Proceed to Pay ${controller.empanelmentData?.totalFees != null ? '${WealthyAmount.currencyFormat(controller.empanelmentData?.totalFees, 2)}' : ''}',
                  onPressed: () async {
                    if (!controller.formKey.currentState!.validate()) {
                      return;
                    }

                    await controller.storeEmpanelmentAddress();

                    if (controller.storeEmpanelmentAddressResponse.state ==
                        NetworkState.error) {
                      return showToast(
                          text: controller
                              .storeEmpanelmentAddressResponse.message);
                    }

                    if (controller.payEmpanelmentFeeResponse.state ==
                        NetworkState.loaded) {
                      if (controller.empanelmentData != null) {
                        AutoRouter.of(context).popForced();
                        controller.initRazorPay();
                      } else {
                        showToast(
                            text: "Something went wrong. Please try again");
                      }
                    } else if (controller.payEmpanelmentFeeResponse.state ==
                        NetworkState.error) {
                      showToast(
                          text: controller.payEmpanelmentFeeResponse.message);
                    }
                  },
                ),
                if (controller.empanelmentData?.totalFees != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Note:  The final value includes the 18% GST Amount of ${WealthyAmount.currencyFormat(controller.empanelmentData?.gst, 2)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, EmpanelmentController controller) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 50),
        children: [
          CommonClientUI.borderTextFormField(
            context,
            controller: controller.addressLineOneController,
            hintText: 'Address Line One',
            validator: (value) {
              if (value?.isNullOrEmpty ?? false) {
                return 'Address Line One is required.';
              }

              return null;
            },
          ),
          SizedBox(height: 16),
          CommonClientUI.borderTextFormField(
            context,
            controller: controller.addressLineTwoController,
            hintText: 'Address Line Two',
            validator: (value) {
              if (value?.isNullOrEmpty ?? false) {
                return 'Address Line Two is required.';
              }

              return null;
            },
          ),
          SizedBox(height: 16),
          CommonClientUI.borderTextFormField(
            context,
            controller: controller.stateController,
            hintText: 'State',
            validator: (value) {
              if (value?.isNullOrEmpty ?? false) {
                return 'State is required.';
              }

              return null;
            },
          ),
          SizedBox(height: 16),
          CommonClientUI.borderTextFormField(
            context,
            controller: controller.cityController,
            hintText: 'City',
            validator: (value) {
              if (value?.isNullOrEmpty ?? false) {
                return 'City is required.';
              }

              return null;
            },
          ),
          SizedBox(height: 16),
          CommonClientUI.borderTextFormField(
            context,
            hintText: 'Pincode',
            controller: controller.pincodeController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // if (value.length == 6) {
              //   controller.getAddressFromPin(value);
              // }
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          SizedBox(height: 16),
          CommonClientUI.popupDropDownField(
            context: context,
            hint: 'Country',
            selectedValue: controller.countryController.text,
            inputController: controller.countryController,
            items: controller.countries.map((e) => e.name!).toList(),
            errorMessage: '',
            onChanged: (value, index) {
              controller.onChangeCountry(value);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, top: 5),
            child: Text(
              'Note:- We do not deliver outside of India',
              style: Theme.of(context).primaryTextTheme.titleLarge,
            ),
          )
        ],
      ),
    );
  }
}
