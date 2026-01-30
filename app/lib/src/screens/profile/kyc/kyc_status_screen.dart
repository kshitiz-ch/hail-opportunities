import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/kyc_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_result_section.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class KycStatusScreen extends StatefulWidget {
  final Map<String, dynamic>? trackingData;
  final String? fromScreen;
  int? kycStatus;
  final Function(int?)? sendSubmittedAnalytics;

  KycStatusScreen({
    this.trackingData,
    this.fromScreen,
    this.kycStatus,
    this.sendSubmittedAnalytics,
  });

  @override
  _KycStatusScreenState createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends State<KycStatusScreen> {
  late PartnerKycController kycController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PartnerKycController>()) {
      kycController = Get.find<PartnerKycController>();
    } else {
      kycController = Get.put<PartnerKycController>(PartnerKycController());
    }
    if (widget.kycStatus == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          kycController.getAgentDetails(updateKYCStatusScreen: true).then(
            (value) {
              widget.kycStatus = kycController.agent?.kycStatus;
              if (widget.sendSubmittedAnalytics != null) {
                widget.sendSubmittedAnalytics!(widget.kycStatus);
              }
            },
          );
        },
      );
    } else {
      kycController.initKYCStatusScreen(kycStatusData: widget.kycStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerKycController>(
      builder: (kycController) {
        if (widget.fromScreen != null && widget.fromScreen!.isNotEmpty) {
          kycController.fromScreen = widget.fromScreen;
        }
        late Widget dynamicWidget;
        if (widget.kycStatus == null ||
            kycController.getAgentDetailState == NetworkState.loading) {
          dynamicWidget = Center(
            child: CircularProgressIndicator(),
          );
        } else if (kycController.getAgentDetailState == NetworkState.error) {
          dynamicWidget = Center(
            child: RetryWidget(
              genericErrorMessage,
              onPressed: () {
                kycController.getAgentDetails();
              },
            ),
          );
        } else if (kycController.getAgentDetailState == NetworkState.loaded) {
          dynamicWidget = KycResultSection();
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            body: Stack(
              children: [
                if (kycController.kycStatus != AgentKycStatus.APPROVED)
                  Positioned(
                    right: 15,
                    top: getSafeTopPadding(20, context),
                    child: IconButton(
                      onPressed: () {
                        _navigateToDashboard(context);
                      },
                      icon: Icon(Icons.close, size: 24),
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                // kycController.showConfettiKYCStatus
                //     ? Positioned(
                //         right: 20,
                //         top: 70,
                //         child: Stack(
                //           children: [
                //             Container(
                //               height: 10,
                //               width: 10,
                //               child: Align(
                //                 alignment: Alignment.center,
                //                 child: ConfettiWidget(
                //                   confettiController: kycController
                //                       .confettiControllerKYCStatus!,
                //                   blastDirectionality:
                //                       BlastDirectionality.explosive,
                //                   // don't specify a direction, blast randomly
                //                   shouldLoop: true,
                //                   // start again as soon as the animation is finished
                //                   colors: const [
                //                     Colors.green,
                //                     Colors.blue,
                //                     Colors.pink,
                //                     Colors.orange,
                //                     Colors.purple
                //                   ], // manually specify the colors to be used
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       )
                //     : SizedBox.shrink(),
                dynamicWidget,
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDashboard(BuildContext context) {
    AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
    if (Get.isRegistered<HomeController>()) {
      HomeController homeController = Get.find<HomeController>();
      homeController.getAdvisorOverview();
    }
  }
}
