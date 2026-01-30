import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/empanelment_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/bonus.dart';
import '../widgets/empanelment_form_bottomsheet.dart';
import '../widgets/goodies.dart';
import '../widgets/inprogress_dialog.dart';
import '../widgets/nism_details.dart';
import '../widgets/pay_onetime_card.dart';
import '../widgets/payment_failed_dialog.dart';
import '../widgets/sales_kit.dart';
import '../widgets/terms_conditions.dart';
import '../widgets/wealthy_platform.dart';

// @RoutePage()
class EmpanelmentScreen extends StatelessWidget {
  const EmpanelmentScreen({
    Key? key,
    this.advisorOverview,
    this.fromKyc = false,
  }) : super(key: key);

  final AdvisorOverviewModel? advisorOverview;
  final bool fromKyc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
      body: GetBuilder<EmpanelmentController>(
        init: EmpanelmentController(
          advisorOverview: advisorOverview,
          context: context,
        ),
        builder: (controller) {
          if (controller.empanelmentState == NetworkState.loading ||
              controller.validateEmpanelmentState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.showPaymentFailedDialog) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                controller.disablePaymentFailedDialog();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PaymenFailedDialog(controller: controller);
                  },
                );
              },
            );
          } else if (controller.showInProgressDialog) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                controller.disableInProgressDialog();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return InProgressDialog(controller: controller);
                  },
                );
              },
            );
          }

          if (controller.empanelmentState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Something went wrong. Please try again',
                onPressed: controller.getAgentEmpanelmentDetails,
              ),
            );
          }

          if (controller.advisorOverview?.agent?.kycStatus !=
              AgentKycStatus.APPROVED) {
            return _buildKycApprovedView(context);
          }

          if (controller.advisorOverview?.partnerArn?.status ==
              ArnStatus.Pending) {
            return _buildArnPendingView(context);
          }

          return Padding(
            padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          AllImages().wealthyPrimaryLogo,
                          width: 83,
                        ),
                        InkWell(
                          onTap: () {
                            AutoRouter.of(context)
                                .popUntil(ModalRoute.withName(BaseRoute.name));
                            if (fromKyc) {
                              if (Get.isRegistered<HomeController>()) {
                                HomeController homeController =
                                    Get.find<HomeController>();
                                homeController.getAdvisorOverview();
                              }
                            }
                          },
                          child: Icon(
                            Icons.close,
                            color: ColorConstants.tertiaryBlack,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  PayOnetimeCard(isArnHolder: controller.isArnHolder),
                  SizedBox(height: 38),
                  if (!controller.isArnHolder)
                    Column(
                      children: [
                        NismDetails(),
                        SizedBox(height: 30),
                        SalesKit(),
                        SizedBox(height: 30),
                        WealthyPlatform(),
                        SizedBox(height: 30),
                        Goodies(),
                      ],
                    )
                  else
                    Column(
                      children: [
                        WealthyPlatform(),
                        SizedBox(height: 30),
                        SalesKit(),
                        SizedBox(height: 30),
                        Goodies(),
                      ],
                    ),
                  SizedBox(height: 30),
                  Bonus(isArnHolder: controller.isArnHolder),
                  TermsConditions(),
                  ActionButton(
                    isDisabled: !controller.isTcAgreed,
                    text: 'Proceed',
                    onPressed: () {
                      if (controller.empanelmentData?.thirdPartyOrderId
                              .isNotNullOrEmpty ??
                          false) {
                        controller.initRazorPay();
                      } else {
                        CommonUI.showBottomSheet(
                          context,
                          child: EmpanelmentFormBottomsheet(),
                        );
                      }
                      // controller.initRazorPay();
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKycApprovedView(BuildContext context) {
    return EmptyScreen(
      message: 'Please complete your KYC',
      actionButtonText: 'Proceed',
      onClick: () {
        // AutoRouter.of(context).push(CompleteKycRoute());
        AutoRouter.of(context).push(ProfileUpdateRoute());
      },
    );
  }

  Widget _buildArnPendingView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your ARN is under review',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Text(
            'Your ARN has been submitted & will be reviewed by our team. We will update you on the next steps soon.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 25),
          ActionButton(
            text: 'Go Back',
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          )
        ],
      ),
    );
  }
}
