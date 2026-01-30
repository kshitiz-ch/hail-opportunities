import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/kyc_controller.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GstDeclarationInput extends StatelessWidget {
  const GstDeclarationInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerKycController>(
      builder: (controller) {
        return Column(
          children: [
            if (controller.verifyGstState != NetworkState.loaded)
              Container(
                // color: Colors.red,
                margin: EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CommonUI.buildCheckbox(
                        value: controller.isGstNotAvailableDeclared,
                        unselectedBorderColor: ColorConstants.darkGrey,
                        onChanged: (bool? value) {
                          controller.toggleGstDeclaration();
                        },
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'I declare that I don\'t have GST registered business',
                        style: Theme.of(context).primaryTextTheme.titleLarge,
                      ),
                    )
                  ],
                ),
              ),
            if (!controller.isGstNotAvailableDeclared)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: InkWell(
                      onTap: () {
                        if (controller.panNumberController.text.length != 10) {
                          showToast(text: 'Please enter a valid PAN first');
                        }
                      },
                      child: IgnorePointer(
                        ignoring:
                            controller.panNumberController.text.length != 10,
                        child: SimpleTextFormField(
                          maxLength: 16,
                          readOnly:
                              controller.verifyGstState == NetworkState.loaded,
                          enabled:
                              controller.verifyGstState != NetworkState.loading,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          hideCounterText: true,
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                                return newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                );
                              },
                            )
                          ],
                          controller: controller.gstNumberController,
                          // keyboardType: keyboardType,
                          label: 'Enter GST number',
                          useLabelAsHint: true,
                          contentPadding: EdgeInsets.only(bottom: 8),
                          borderColor: ColorConstants.lightGrey,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                          labelStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          hintStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            // if (value.isNullOrEmpty &&
                            //     !controller.isGstNotAvailableDeclared) {
                            //   return 'If you do not have a GST number, kindly mark the checkbox above';
                            // }

                            return null;
                          },
                          suffixIconSize: Size(150, 150),
                          suffixIcon: Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: _buildGstSuffixIcon(context, controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (controller.verifyGstState == NetworkState.loaded &&
                      controller.corporateName.isNotNullOrEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        controller.corporateName,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .copyWith(
                                color: ColorConstants.tertiaryBlack,
                                fontSize: 11),
                      ),
                    ),

                  if (controller.verifyGstState == NetworkState.loaded)
                    Container(
                      // color: Colors.red,
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CommonUI.buildCheckbox(
                              value: controller.isGstPanLinkDeclared,
                              unselectedBorderColor: ColorConstants.darkGrey,
                              onChanged: (bool? value) {
                                if (controller.verifyGstState ==
                                    NetworkState.loaded) {
                                  controller.toggleGstPanLinkDeclared();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'I declare that my PAN is associated with GST number provided by me',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: controller.verifyGstState ==
                                              NetworkState.loaded
                                          ? ColorConstants.black
                                          : ColorConstants.tertiaryBlack),
                            ),
                          )
                        ],
                      ),
                    ),
                  // GST Number description text
                  // _buildHelperText(
                  //     context: context,
                  //     text:
                  //         'Please enter your GST number if registering as a business user'),
                ],
              )
          ],
        );
      },
    );
  }

  Widget _buildGstSuffixIcon(
      BuildContext context, PartnerKycController controller) {
    if (controller.verifyGstState == NetworkState.loading) {
      return Container(
        height: 15,
        width: 15,
        child: CircularProgressIndicator(
            color: ColorConstants.primaryAppColor, strokeWidth: 2),
      );
    }

    if (controller.verifyGstState == NetworkState.loaded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller.isDigioGstVerificationFailed)
            Text(
              'Verification Pending',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(color: ColorConstants.redAccentColor),
            )
          else
            Text(
              'Verified',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(color: ColorConstants.greenAccentColor),
            ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: () {
                controller.resetGstInput();
              },
              child: Icon(
                Icons.clear,
                size: 21.0,
                color: ColorConstants.darkGrey,
              ),
            ),
          )
        ],
      );
    }

    return InkWell(
      onTap: () {
        if (controller.gstNumberController.text.isNotEmpty) {
          controller.verifyGst();
        } else {
          showToast(text: "Please enter GST number");
        }
      },
      child: Container(
        child: Text(
          'Verify',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge!
              .copyWith(color: ColorConstants.primaryAppColor),
        ),
      ),
    );
  }
}
