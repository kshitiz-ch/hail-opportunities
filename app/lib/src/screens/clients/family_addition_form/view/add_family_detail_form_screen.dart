import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/access_code_info.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/member_detail_form.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class AddFamilyDetailFormScreen extends StatelessWidget {
  AddFamilyDetailFormScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Enter Details',
        subtitleText:
            'Add details of the family member to create and add as a new family account. An access code will be sent to the mobile number entered ',
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: GetBuilder<ClientFamilyController>(builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: MemberDetailForm(),
                ),
                if (controller.isDetailFormEnabled)
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: AccessCodeInfo(),
                  ),
                SizedBox(height: 100)
              ],
            ),
          );
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          GetBuilder<ClientFamilyController>(builder: (controller) {
        return ActionButton(
          onPressed: () async {
            if (controller.memberDetailFormKey!.currentState!.validate()) {
              await controller.createFamilyMembers();
              if (controller.createFamilyState == NetworkState.error) {
                showToast(
                  text: controller.createFamilyErrorMessage ??
                      genericErrorMessage,
                );
              } else {
                AutoRouter.of(context).push(AddFamilyVerificationRoute());
              }
            }
          },
          showProgressIndicator:
              controller.createFamilyState == NetworkState.loading,
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          text: 'Get Code',
          isDisabled: !controller.isDetailFormEnabled,
          textStyle:
              Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                    color: !controller.isDetailFormEnabled
                        ? ColorConstants.tertiaryBlack
                        : ColorConstants.white,
                    fontWeight: FontWeight.w700,
                  ),
        );
      }),
    );
  }
}
