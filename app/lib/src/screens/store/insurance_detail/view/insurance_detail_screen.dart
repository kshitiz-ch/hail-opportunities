import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/store/insurance/insurance_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/product_video_card.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../widgets/insurance_product_details.dart';

@RoutePage()
class InsuranceDetailScreen extends StatelessWidget {
  final InsuranceModel? insuranceData;
  final Client? selectedClient;
  String? productVariant;
  final bool isOffline;

  InsuranceDetailScreen({
    Key? key,
    this.insuranceData,
    this.selectedClient,
    @pathParam this.productVariant,
    this.isOffline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<InsuranceController>()) {
      final InsuranceController controller = Get.find<InsuranceController>();
      if (insuranceData == null) {
        controller.getInsuranceData(productVariant!);
      } else {
        controller.insuranceData = insuranceData;
      }
    } else {
      Get.put(InsuranceController(
          insuranceData: insuranceData, productVariant: productVariant));
    }

    productVariant = productVariant ??
        insuranceData?.productVariant?.toString().toLowerCase();

    return Scaffold(
      backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
      body: GetBuilder<InsuranceController>(
        id: GetxId.createProposal,
        dispose: (_) => Get.delete<InsuranceController>(),
        initState: (_) async {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _.controller!.getInsuranceProductDetail(productVariant!);
          });
        },
        builder: (controller) {
          if (controller.getInsuranceDataState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.getInsuranceDataState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                genericErrorMessage,
                onPressed: () {
                  controller.getInsuranceData(productVariant!);
                },
              ),
            );
          }

          if (controller.insuranceData != null) {
            return Padding(
              padding: EdgeInsets.only(
                top: getSafeTopPadding(50, context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // App Bar
                  // It quite complex to add custom app bar here so created separate
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBackButton(context),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              insuranceSectionData[productVariant]!['title'],
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.black,
                                  ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 24.0),
                              child: Text(
                                insuranceSectionData[productVariant]![
                                    'description'],
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: ColorConstants.tertiaryBlack,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 20),
                        child: Image.asset(
                          insuranceSectionData[productVariant]!['image_path'],
                          alignment: Alignment.topRight,
                          height: 96,
                          width: 96,
                        ),
                      )
                    ],
                  ),
                  if (productVariant == InsuranceProductVariant.HEALTH)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: ProductVideoCard(
                        productType: "insurance",
                        isProductVideoViewed: false,
                        onTap: () {
                          MixPanelAnalytics.trackWithAgentId(
                            "Health_Flow_video",
                            screen: 'Insurance',
                            screenLocation: 'Insurance',
                          );
                        },
                        video: AdvisorVideoModel.fromJson(
                          {"link": "https://youtu.be/BFAcrd8ZJRQ"},
                        ),
                        currentRoute: InsuranceHomeRoute.name,
                      ),
                    ),
                  Expanded(
                    child: InsuranceProductDetails(),
                  )
                ],
              ),
            );
          }
          return SizedBox();
        },
      ),
      floatingActionButton: productVariant == InsuranceProductVariant.QUOTE
          ? null
          : isOffline
              ? GetBuilder<InsuranceController>(
                  id: GetxId.insuranceProductDetail,
                  builder: (controller) {
                    return ActionButton(
                      onPressed: () async {
                        String? contactPhoneNumber;
                        String? contactName = '';
                        if (Get.isRegistered<HomeController>()) {
                          AgentModel? agentModel = Get.find<HomeController>()
                              .advisorOverviewModel!
                              .agent;
                          if (agentModel?.pst != null &&
                              agentModel?.pst?.name != null) {
                            contactName = agentModel?.pst?.name;
                          }

                          if (agentModel?.pst != null &&
                              agentModel?.pst?.phoneNumber != null) {
                            contactPhoneNumber = agentModel?.pst?.phoneNumber;
                          }
                        }

                        if (contactPhoneNumber.isNullOrEmpty) {
                          contactPhoneNumber = insuranceDefaultContactNumber;
                        }

                        final link = WhatsAppUnilink(
                          phoneNumber: contactPhoneNumber,
                          text: 'Hey, $contactName',
                        );
                        await launch('$link');
                      },
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                      height: 56,
                      borderRadius: 51,
                      text: 'Contact us',
                      prefixWidget: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SvgPicture.asset(
                          AllImages().whatsappInsuranceIcon,
                          height: 24,
                          width: 24,
                          color: Colors.white,
                          alignment: Alignment.center,
                        ),
                      ),
                    );
                  },
                )
              : GetBuilder<InsuranceController>(
                  id: GetxId.createProposal,
                  builder: (controller) {
                    return ActionButton(
                      text: 'Generate Quotes',
                      isDisabled: controller.insuranceProductDetailState ==
                              NetworkState.loading ||
                          controller.getInsuranceDataState !=
                                  NetworkState.loaded &&
                              controller.insuranceData == null,
                      height: 56,
                      borderRadius: 51,
                      showProgressIndicator: controller.createProposalState ==
                          NetworkState.loading,
                      onPressed: () {
                        MixPanelAnalytics.trackWithAgentId(
                          "Generate_Quote",
                          screen: 'Insurance',
                          screenLocation: 'Insurance',
                          properties: {"product": productVariant},
                        );
                        onGenerateQuote(context, controller);
                      },
                      textStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            color: ColorConstants.white,
                            fontWeight: FontWeight.w700,
                          ),
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                    );
                  }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  onGenerateQuote(BuildContext context, InsuranceController controller) async {
    if (controller.insuranceData?.selectClient == true) {
      // Check if kyc is approved
      int? agentKycStatus = await getAgentKycStatus();
      if (agentKycStatus != AgentKycStatus.APPROVED) {
        CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
        return null;
      }

      if (selectedClient != null) {
        AutoRouter.of(context).pushNativeRoute(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
          ),
        );
        controller.setSelectedClient(selectedClient);

        await onCreateProposal(context, controller, shouldPop: true);
      } else {
        AutoRouter.of(context).push(SelectClientRoute(
          onClientSelected: (Client? client, bool? isClientNew) async {
            controller.setSelectedClient(client);

            await onCreateProposal(context, controller,
                shouldPop: isClientNew ?? false);
          },
        ));
      }
    } else {
      // bool viaWebView = webViewEnabledProductVariants
      //     .contains(controller.insuranceData!.productVariant);
      bool viaWebView = true;

      bool isNewInsuranceFlow = controller.insuranceData!.productVariant ==
              InsuranceProductVariant.TERM ||
          controller.insuranceData!.productVariant ==
              InsuranceProductVariant.SAVINGS;

      if (!isNewInsuranceFlow) {
        isNewInsuranceFlow = controller.insuranceDetailModel != null &&
            (controller.insuranceDetailModel?.isNewFlow ?? false);
      }

      // Temporary Hack
      // if (isSavingsOrTermInsurance) {
      //   viaWebView = controller.insuranceDetailModel != null &&
      //       controller.insuranceDetailModel!.viaWebView! &&
      //       !SizeConfig().isTabletDevice;
      // }

      await controller.getProposalUrl(controller.insuranceData!, context,
          viaWebView: viaWebView);

      if (controller.proposalUrlState == NetworkState.loaded) {
        if (!isPageAtTopStack(context, InsuranceWebViewRoute.name)) {
          bool shouldHandleAppBar = !isNewInsuranceFlow;

          AutoRouter.of(context).push(
            InsuranceWebViewRoute(
              url: controller.proposalUrl,
              shouldHandleAppBar: shouldHandleAppBar,
              onNavigationRequest: (
                InAppWebViewController controller,
                NavigationAction action,
              ) async {
                final navigationUrl = action.request.url.toString();

                if (isNewInsuranceFlow &&
                    navigationUrl.contains("applinks.buildwealth.in")) {
                  if (navigationUrl ==
                      "https://applinks.buildwealth.in/proposals") {
                    navigateToProposalScreen(context);
                  } else {
                    AutoRouter.of(context).popForced();
                  }
                  return NavigationActionPolicy.CANCEL;
                } else {
                  return NavigationActionPolicy.ALLOW;
                }
              },
            ),
          );
        }
      }
    }
  }

  Future<void> onCreateProposal(
      BuildContext context, InsuranceController controller,
      {bool shouldPop = false}) async {
    await controller.createProposal(controller.insuranceData);

    if (shouldPop) {
      AutoRouter.of(context).popForced();
    }

    if (controller.createProposalState == NetworkState.error) {
      return showToast(
        context: context,
        text: controller.createProposalErrorMessage,
      );
    }

    if (controller.createProposalState == NetworkState.loaded) {
      showToast(
        text:
            'Opening ${controller.insuranceData!.title!.toTitleCase()} insurance',
        context: context,
      );
      if (!isPageAtTopStack(context, WebViewRoute.name)) {
        AutoRouter.of(context).push(WebViewRoute(
          url: controller.proposalUrl,
          onWebViewExit: () {
            AutoRouter.of(context)
                .popUntil(ModalRoute.withName(BaseRoute.name));
            Get.find<NavigationController>().setCurrentScreen(Screens.STORE);
          },
        ));
      }
    }
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).popForced();
        },
        child: Image.asset(
          AllImages().appBackIcon,
          height: 32,
          width: 32,
        ),
      ),
    );
  }
}
