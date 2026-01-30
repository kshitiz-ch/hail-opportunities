import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/partner_nominee_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/nominee/widgets/partner_nominee_form.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/partner_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class PartnerNomineeScreen extends StatelessWidget {
  const PartnerNomineeScreen({
    Key? key,
    this.nominee,
    this.fromKycFlow = true,
  }) : super(key: key);

  final bool fromKycFlow;
  final PartnerNomineeModel? nominee;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerNomineeController>(
        init: PartnerNomineeController(
          partnerNominee: nominee,
          fromKycFlow: fromKycFlow,
        ),
        builder: (controller) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(bottom: 50, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nominee Details',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please fill details below',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          ],
                        ),
                        Spacer(),
                        if (!fromKycFlow)
                          InkWell(
                            onTap: () {
                              AutoRouter.of(context).popForced();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.close,
                                color: ColorConstants.tertiaryBlack,
                                size: 24,
                              ),
                            ),
                          )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: controller.formKey,
                          child: PartnerNomineeForm(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                if (isKeyboardVisible) {
                  return SizedBox();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionButton(
                      text: 'Proceed',
                      showProgressIndicator:
                          controller.createNomineeResponse.state ==
                              NetworkState.loading,
                      onPressed: () async {
                        if (!controller.formKey.currentState!.validate()) {
                          return;
                        }

                        await controller.createPartnerNominee();

                        if (controller.createNomineeResponse.state ==
                            NetworkState.loaded) {
                          showToast(text: 'Nominee updated successfully');

                          if (fromKycFlow) {
                            if (controller.isEmpanelmentMissing) {
                              // AutoRouter.of(context)
                              //     .push(EmpanelmentRoute(fromKyc: true));
                              AutoRouter.of(context).push(ProfileUpdateRoute());
                            } else {
                              navigateToDashboard(context);
                            }
                          } else {
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>().partnerNominee =
                                  controller.partnerNominee;
                              Get.find<ProfileController>()
                                  .update(['partner-nominee']);
                            }
                            AutoRouter.of(context).popForced();
                          }
                        } else if (controller.createNomineeResponse.state ==
                            NetworkState.error) {
                          showToast(
                              text: controller.createNomineeResponse.message);
                        }
                      },
                    ),
                    if (fromKycFlow)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: GetBuilder<PartnerNomineeController>(
                          builder: (controller) {
                            return ActionButton(
                              text: 'Skip',
                              progressIndicatorColor:
                                  ColorConstants.primaryAppColor,
                              textStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: ColorConstants.primaryAppColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              showProgressIndicator:
                                  controller.createNomineeResponse.state !=
                                          NetworkState.loading &&
                                      controller.checkEmpanelmentState ==
                                          NetworkState.loading,
                              isDisabled:
                                  controller.createNomineeResponse.state ==
                                          NetworkState.loading ||
                                      controller.checkEmpanelmentState ==
                                          NetworkState.loading,
                              bgColor: ColorConstants.secondaryAppColor,
                              onPressed: () async {
                                if (controller.createNomineeResponse.state ==
                                    NetworkState.loading) {
                                  return;
                                }

                                await controller.checkEmpanelmentStatus();

                                if (controller.isEmpanelmentMissing) {
                                  // AutoRouter.of(context).push(
                                  //   EmpanelmentRoute(fromKyc: true),
                                  // );
                                  AutoRouter.of(context)
                                      .push(ProfileUpdateRoute());
                                } else {
                                  navigateToDashboard(context);
                                }
                              },
                            );
                          },
                        ),
                      )
                  ],
                );
              }),
            ),
          );
        });
  }
}
