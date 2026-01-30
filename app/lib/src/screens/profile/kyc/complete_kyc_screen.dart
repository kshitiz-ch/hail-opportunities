import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/kyc_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/screens/profile/kyc/kyc_form.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/camera_permission_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// @RoutePage()
class CompleteKycScreen extends StatefulWidget {
  final AgentModel? agent;
  final bool fromPushNotification;
  final fromScreen;
  final isResetKycFlow;

  CompleteKycScreen({
    this.agent,
    this.fromScreen = '',
    this.fromPushNotification = false,
    this.isResetKycFlow = false,
  });

  @override
  _CompleteKycScreenState createState() => _CompleteKycScreenState();
}

class _CompleteKycScreenState extends State<CompleteKycScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // PartnerKycController? kycController;

  @override
  void initState() {
    super.initState();
  }

  void initiateKyc(PartnerKycController kycController,
      {bool? isAadharLinked = false}) async {
    bool isCamerPermissionGranted = await Permission.camera.isGranted;
    if (!isCamerPermissionGranted) {
      await CommonUI.showBottomSheet(context,
          child: CameraPermissionBottomSheet());
    }

    int? kycStatus = await kycController.startKYC(
        kycController.panNumberController.text.toString(),
        kycController.agent?.phoneNumber,
        kycController.emailController.text.toString(),
        isAadharLinked);
    LogUtil.printLog('kycUrl==>${kycController.kycUrl}');
    if (kycStatus == AgentKycStatus.INITIATED) {
      openKycUrl(kycController.kycUrl!, context);
    } else {
      if (kycStatus == AgentKycStatus.FAILED) {
        if (kycController.kycInitMsg.isNotNullOrEmpty) {
          showToast(
            context: context,
            text: kycController.kycInitMsg,
          );
        }
      } else {
        kycController.kycInitMsg = '';
        AutoRouter.of(context).push(
          KycStatusRoute(
            kycStatus: kycStatus,
            fromScreen: widget.fromScreen,
          ),
        );
      }
    }
  }

  void goBackHandler() {
    AutoRouter.of(context).push(BaseRoute());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerKycController>(
        init: PartnerKycController(agentDetail: widget.agent),
        dispose: (_) => Get.delete<PartnerKycController>(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorConstants.white,
            // AppBar
            appBar: controller.getAgentDetailState == NetworkState.loaded
                ? CustomAppBar(
                    showBackButton: true,
                    titleText: 'Complete your KYC',
                    subtitleText:
                        'Enter your details below for instant verification',
                    onBackPress: () {
                      if (widget.fromPushNotification) {
                        goBackHandler();
                      } else {
                        AutoRouter.of(context).popForced();
                      }
                    },
                  )
                : null,
            body: Builder(
              builder: (context) {
                if (widget.fromScreen != null && widget.fromScreen.isNotEmpty) {
                  controller.fromScreen = widget.fromScreen;
                }

                if (controller.getAgentDetailState == NetworkState.loading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.getAgentDetailState == NetworkState.error) {
                  return Center(
                    child: Text(genericErrorMessage),
                  );
                }

                if (!widget.isResetKycFlow &&
                    controller.agent?.kycStatus == AgentKycStatus.APPROVED) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      AutoRouter.of(context).replace(
                        KycStatusRoute(kycStatus: controller.agent?.kycStatus),
                      );
                    },
                  );
                }

                if (controller.getAgentDetailState != NetworkState.loaded ||
                    (!widget.isResetKycFlow &&
                        controller.agent?.kycStatus ==
                            AgentKycStatus.APPROVED)) {
                  return SizedBox();
                } else {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 120),
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Form(
                          key: _formKey,
                          child: KycForm(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                if (controller.getAgentDetailState != NetworkState.loaded) {
                  return SizedBox();
                }

                bool isFormValid =
                    controller.emailController.text.isNotNullOrEmpty &&
                        controller.panNumberController.text.isNotNullOrEmpty;
                return ActionButton(
                  isDisabled: !isFormValid,
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  borderRadius: 30.0,
                  text: 'Start KYC',
                  showProgressIndicator:
                      controller.getStartKYCState == NetworkState.loading,
                  onPressed: () {
                    bool isPanNumberNotChanged = controller.agent!.panNumber ==
                        controller.panNumberController.text;

                    if (widget.isResetKycFlow && isPanNumberNotChanged) {
                      return showToast(
                          text: "Please use another PAN to reset KYC");
                    }

                    startKYC(controller);
                  },
                );
                // return GetBuilder<PartnerKycController>(
                //     builder: (PartnerKycController controller) {

                // });
              },
            ),
          );
        });
  }

  void startKYC(PartnerKycController? controller) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState!.validate()) {
      void onActionClick({bool? isUserAadharLinked}) async {
        controller!.isAadharLinked = isUserAadharLinked;
        AutoRouter.of(context).popForced();

        initiateKyc(controller, isAadharLinked: isUserAadharLinked);
      }

      initiateKyc(controller!);
    }
  }
}
