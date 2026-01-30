import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/kyc_controller.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KycResultSection extends StatefulWidget {
  final PartnerKycController kycController = Get.find<PartnerKycController>();
  Image? statusImage;

  KycResultSection({
    Key? key,
  }) : super(key: key) {
    if (kycController.iconUrlKYCStatus != null) {
      statusImage = Image.asset(
        kycController.iconUrlKYCStatus!,
        height: kycController.kycStatus == AgentKycStatus.APPROVED ? 150 : 100,
        width: kycController.kycStatus == AgentKycStatus.APPROVED ? 150 : 100,
      );
    }
  }

  @override
  State<KycResultSection> createState() => _KycResultSectionState();
}

class _KycResultSectionState extends State<KycResultSection> {
  bool showButtonLoader = false;

  @override
  void didChangeDependencies() {
    if (widget.statusImage != null) {
      precacheImage(widget.statusImage!.image, context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 32).copyWith(top: 230),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.statusImage != null)
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: widget.statusImage,
            ),
          Text(
            widget.kycController.titleKYCStatus,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color:
                      widget.kycController.kycStatus == AgentKycStatus.APPROVED
                          ? ColorConstants.primaryAppColor
                          : ColorConstants.black,
                ),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            widget.kycController.subtitleKYCStatus,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          Spacer(),
          // if (widget.kycController.kycStatus == AgentKycStatus.FAILED ||
          //     widget.kycController.kycStatus == AgentKycStatus.REJECTED ||
          //     widget.kycController.kycStatus == AgentKycStatus.APPROVED)
          ActionButton(
            text: widget.kycController.kycStatus == AgentKycStatus.APPROVED
                ? 'Proceed'
                : 'Retry',
            showProgressIndicator: showButtonLoader,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            borderRadius: 27,
            onPressed: () async {
              if (widget.kycController.kycStatus == AgentKycStatus.APPROVED) {
                //Go To Store if arn detected else go to arn not detected page
                // final NavigationController navController =
                //     Get.find<NavigationController>();
                // navigateToDashboard(context);
                // navController.setCurrentScreen(Screens.STORE);
                AutoRouter.of(context).push(
                  PartnerNomineeRoute(fromKycFlow: true),
                );
              } else if (widget.kycController.kycStatus ==
                  AgentKycStatus.REJECTED) {
                //Retry

                if (widget.kycController.kycUrl != null) {
                  openKycUrl(widget.kycController.kycUrl!, context);

                  // launch(widget.kycController.kycUrl);
                } else {
                  AutoRouter.of(context).popForced();
                }
              } else {
                AutoRouter.of(context).popForced();
              }
            },
          ),

          if (widget.kycController.kycStatus != AgentKycStatus.APPROVED &&
              widget.kycController.kycStatus != AgentKycStatus.SUBMITTED)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'If you are facing issue while doing kyc, please try again from browser',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ClickableText(
                      text: 'Retry via browser',
                      fontSize: 16,
                      fontHeight: 22 / 16,
                      onClick: () {
                        launch(widget.kycController.kycUrl!);
                        // navigateToDashboard(context);
                      },
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  void toggleButtonState() {
    setState(() {
      showButtonLoader = !showButtonLoader;
    });
  }

  void navigateToDashboard(BuildContext context) {
    // widget.kycController.btnController.reset();
    toggleButtonState();
    AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setCurrentScreen(Screens.HOME);
    }
    HomeController homeController = Get.find();
    homeController.getAdvisorOverview();

    // final DashboardBloc dashboardBloc = DashboardBlocController().dashboardBloc;
    // dashboardBloc.add(DashboardRefreshEvent());
  }
}
