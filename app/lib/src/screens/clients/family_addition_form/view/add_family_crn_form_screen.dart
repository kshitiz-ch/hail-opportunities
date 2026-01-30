import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/access_code_info.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/member_crn_form.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class AddFamilyCrnFormScreen extends StatelessWidget {
  AddFamilyCrnFormScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Add Family Members',
        subtitleText:
            "Search your Family member to add  via access code. Access code will be sent to your client's registered mobile number ",
        onBackPress: () {
          Get.find<ClientFamilyController>().clearSearchBar();
          AutoRouter.of(context).popForced();
        },
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
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: MemberCRNForm(),
                ),
                if (controller.isCRNFormEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: AccessCodeInfo(),
                  ),
              ],
            ),
          );
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          GetBuilder<ClientFamilyController>(builder: (controller) {
        return ActionButton(
          showProgressIndicator:
              controller.createFamilyState == NetworkState.loading,
          onPressed: () async {
            if (controller.memberCRNFormKey!.currentState!.validate()) {
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
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          text: 'Get Code',
          isDisabled: !controller.isCRNFormEnabled,
          textStyle:
              Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                    color: !controller.isCRNFormEnabled
                        ? ColorConstants.tertiaryBlack
                        : ColorConstants.white,
                    fontWeight: FontWeight.w700,
                  ),
        );
      }),
    );
  }
}
