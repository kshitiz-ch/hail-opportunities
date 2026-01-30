import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/gst_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GstFormBottomSheet extends StatelessWidget {
  GstFormBottomSheet({
    Key? key,
    this.gstNumber,
    this.panNumber,
    required this.gstFormMode,
    this.onFormSubmit,
  }) : super(key: key);

  final String? gstNumber;
  final String? panNumber;
  final Function? onFormSubmit;
  final GstFormMode gstFormMode;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GstController>(
      init: GstController(savedGstNumber: gstNumber!),
      dispose: (_) => {
        if (Get.isRegistered<GstController>()) {Get.delete<GstController>()}
      },
      builder: (controller) {
        String actionText = '';
        if (gstFormMode == GstFormMode.Add) {
          actionText = 'Add';
        } else if (gstFormMode == GstFormMode.Edit) {
          actionText = 'Edit';
        } else if (gstFormMode == GstFormMode.Verify) {
          actionText = 'Verify';
        }

        return Container(
          padding: EdgeInsets.only(
              top: 30,
              left: 30,
              right: 30,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$actionText GST',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                ),
                SizedBox(height: 20),
                if (gstFormMode == GstFormMode.Verify)
                  _buildGstVerifyText(context)
                else
                  _buildGstInput(context, controller),
                Container(
                  padding: EdgeInsets.only(top: 30, bottom: 16),
                  child: ActionButton(
                    isDisabled: gstFormMode == GstFormMode.Verify
                        ? false
                        : controller.gstNumberController.text.isNullOrEmpty ||
                            !controller.isGstPanLinkDeclared,
                    showProgressIndicator:
                        controller.saveGstState == NetworkState.loading,
                    margin: EdgeInsets.zero,
                    text:
                        gstFormMode == GstFormMode.Edit ? 'Update' : actionText,
                    onPressed: () async {
                      if (gstFormMode == GstFormMode.Edit &&
                          gstNumber == controller.gstNumberController.text) {
                        return showToast(text: 'Please enter new GST number');
                      }

                      await controller.saveGst(panNumber: panNumber);

                      if (controller.saveGstState == NetworkState.loaded) {
                        if (controller.isDigioGstVerificationFailed) {
                          showToast(
                              text:
                                  'Failed to verify. Please try after sometime');
                        }

                        if (controller.isDigioGstVerificationFailed &&
                            gstFormMode == GstFormMode.Verify) {
                          // Don't do anything
                        } else {
                          AutoRouter.of(context).popForced();
                          onFormSubmit!();
                        }
                      } else if (controller.saveGstState ==
                          NetworkState.error) {
                        showToast(text: controller.saveGstErrorMessage);
                      }
                    },
                  ),
                ),
                // if (gstFormMode == GstFormMode.Edit ||
                //     gstFormMode == GstFormMode.Verify)
                Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Center(
                    child: ClickableText(
                      text: 'Reset KYC',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      onClick: () {
                        // AutoRouter.of(context).push(
                        //   CompleteKycRoute(isResetKycFlow: true),
                        // );
                        AutoRouter.of(context).push(ProfileUpdateRoute());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGstVerifyText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Please make sure your PAN ',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w300),
          ),
          TextSpan(
            text: panNumber ?? '',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
          ),
          TextSpan(
            text: ' is associated with GST ',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w300),
          ),
          TextSpan(
            text: gstNumber ?? '',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
          )
        ],
      ),
    );
    // return Text(
    //   'Please make sure your PAN $panNumber is associated with GST $gstNumber',
    //   style: Theme.of(context).primaryTextTheme.headlineMedium.copyWith(color: ColorConstants.tertiaryBlack),
    // );
  }

  Widget _buildGstInput(BuildContext context, GstController controller) {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        children: [
          SimpleTextFormField(
            maxLength: 16,
            hideCounterText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: controller.gstNumberController,
            // keyboardType: keyboardType,
            label: 'Enter GST number',
            useLabelAsHint: true,
            inputFormatters: [
              TextInputFormatter.withFunction(
                (oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  );
                },
              )
            ],
            contentPadding: EdgeInsets.only(bottom: 8),
            borderColor: ColorConstants.lightGrey,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
            labelStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: ColorConstants.tertiaryBlack,
                      height: 0.7,
                    ),
            hintStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
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
          ),
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
                    selectedBorderColor: ColorConstants.primaryAppColor,
                    unselectedBorderColor: ColorConstants.primaryAppColor,
                    onChanged: (bool? value) {
                      controller.toggleGstPanLinkDeclared();
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
                        .copyWith(color: ColorConstants.black),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
