import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/store/insurance/insurance_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

@RoutePage()
class InsuranceGenerateQuotesScreen extends StatefulWidget {
  final InsuranceModel? insuranceData;
  final Client? selectedClient;
  final String? productVariant;

  const InsuranceGenerateQuotesScreen({
    Key? key,
    this.insuranceData,
    this.selectedClient,
    @pathParam this.productVariant,
  }) : super(key: key);

  @override
  State<InsuranceGenerateQuotesScreen> createState() =>
      _InsuranceGenerateQuotesScreenState();
}

class _InsuranceGenerateQuotesScreenState
    extends State<InsuranceGenerateQuotesScreen> {
  late InsuranceController controller;
  late String? productVariant;

  // Flag to ensure quote generation is triggered only once
  bool _hasTriggeredQuoteGeneration = false;

  @override
  void initState() {
    super.initState();

    // Initialize or retrieve existing insurance controller
    if (Get.isRegistered<InsuranceController>()) {
      controller = Get.find<InsuranceController>();
      // Fetch insurance data if not provided via widget
      if (widget.insuranceData == null) {
        controller.getInsuranceData(widget.productVariant!);
      } else {
        controller.insuranceData = widget.insuranceData;
      }
    } else {
      controller = Get.put(InsuranceController(
          insuranceData: widget.insuranceData,
          productVariant: widget.productVariant));
    }

    // Set product variant from widget or insurance data
    productVariant = widget.productVariant ??
        widget.insuranceData?.productVariant?.toString().toLowerCase();

    // Fetch insurance product details after first frame
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await controller.getInsuranceProductDetail(productVariant!);
    });
  }

  /// Checks if both insurance data and product details are loaded, then triggers quote generation
  Future<void> _checkAndTriggerQuoteGeneration(BuildContext context) async {
    // Prevent duplicate quote generation
    if (_hasTriggeredQuoteGeneration) return;

    // Check if insurance data is loaded (either fetched or provided via widget)
    final isInsuranceDataLoaded =
        controller.getInsuranceDataState == NetworkState.loaded ||
            widget.insuranceData != null;
    // Check if product details are loaded
    final isProductDetailLoaded =
        controller.insuranceProductDetailState == NetworkState.loaded;

    // Trigger quote generation only when both data sources are ready
    if (isInsuranceDataLoaded && isProductDetailLoaded && mounted) {
      _hasTriggeredQuoteGeneration = true;
      await onGenerateQuote(context, controller);
    }
  }

  /// Handles quote generation flow - either client selection or direct webview
  Future<void> onGenerateQuote(
      BuildContext context, InsuranceController controller) async {
    // Flow for products requiring client selection
    if (controller.insuranceData?.selectClient == true) {
      // Check if kyc is approved
      int? agentKycStatus = await getAgentKycStatus();
      if (agentKycStatus != AgentKycStatus.APPROVED) {
        CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
        return null;
      }

      // Use pre-selected client if available
      if (widget.selectedClient != null) {
        controller.setSelectedClient(widget.selectedClient);
        await onCreateProposal(context, controller, shouldPop: false);
      } else {
        // Navigate to client selection screen
        AutoRouter.of(context).push(SelectClientRoute(
          onClientSelected: (Client? client, bool? isClientNew) async {
            controller.setSelectedClient(client);
            await onCreateProposal(context, controller,
                shouldPop: isClientNew ?? false);
          },
        ));
      }
    } else {
      // Flow for products that don't require client selection
      bool viaWebView = true;

      // Check if product uses new insurance flow (Term/Savings)
      bool isNewInsuranceFlow = controller.insuranceData!.productVariant ==
              InsuranceProductVariant.TERM ||
          controller.insuranceData!.productVariant ==
              InsuranceProductVariant.SAVINGS;

      // Fallback check for new flow from product detail model
      if (!isNewInsuranceFlow) {
        isNewInsuranceFlow = controller.insuranceDetailModel != null &&
            (controller.insuranceDetailModel?.isNewFlow ?? false);
      }

      await controller.getProposalUrl(controller.insuranceData!, context,
          viaWebView: viaWebView);

      if (controller.proposalUrlState == NetworkState.error) {
        // Ensure widget is still mounted before accessing context
        if (mounted) AutoRouter.of(context).popForced();
        return;
      }

      if (controller.proposalUrlState == NetworkState.loaded) {
        // Navigate to webview if not already open
        if (!isPageAtTopStack(context, InsuranceWebViewRoute.name)) {
          // Old flow handles app bar, new flow doesn't
          bool shouldHandleAppBar = !isNewInsuranceFlow;

          AutoRouter.of(context).push(
            InsuranceWebViewRoute(
              url: controller.proposalUrl,
              shouldHandleAppBar: shouldHandleAppBar,
              onWebViewExit: () {
                // Ensure widget is still mounted before accessing context
                if (!mounted) return;
                // Close InsuranceWebViewRoute
                AutoRouter.of(context).popForced();
                // Close GenerateQuotesScreen
                AutoRouter.of(context).popForced();
              },
              onNavigationRequest: (
                InAppWebViewController controller,
                NavigationAction action,
              ) async {
                final navigationUrl = action.request.url.toString();

                // Handle deep links for new insurance flow
                if (isNewInsuranceFlow &&
                    navigationUrl.contains("applinks.buildwealth.in")) {
                  if (navigationUrl ==
                      "https://applinks.buildwealth.in/proposals") {
                    // Ensure widget is still mounted before accessing context
                    if (mounted) navigateToProposalScreen(context);
                  } else {
                    // Ensure widget is still mounted before accessing context
                    if (!mounted) return NavigationActionPolicy.CANCEL;
                    // Close InsuranceWebViewRoute
                    AutoRouter.of(context).popForced();
                    // Close GenerateQuotesScreen
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

    // Track the event
    MixPanelAnalytics.trackWithAgentId(
      "Generate_Quote",
      screen: 'Insurance',
      screenLocation: 'Insurance',
      properties: {"product": productVariant},
    );
  }

  /// Creates insurance proposal for client-based products
  Future<void> onCreateProposal(
      BuildContext context, InsuranceController controller,
      {bool shouldPop = false}) async {
    await controller.createProposal(controller.insuranceData);

    // Pop screen if client was newly created
    if (shouldPop && mounted) {
      AutoRouter.of(context).popForced();
    }

    if (controller.createProposalState == NetworkState.error) {
      // Show error toast
      showToast(context: context, text: controller.createProposalErrorMessage);
      // Pop to base screen
      AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
      // Set current screen to store
      Get.find<NavigationController>().setCurrentScreen(Screens.STORE);
      return;
    }

    if (controller.createProposalState == NetworkState.loaded) {
      showToast(
        text:
            'Opening ${controller.insuranceData!.title!.toTitleCase()} insurance',
        context: context,
      );
      // Navigate to webview if not already open
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceController>(
      id: GetxId.createProposal,
      builder: (controller) {
        // Check if insurance data is being fetched
        final isInsuranceDataLoading =
            controller.getInsuranceDataState == NetworkState.loading;
        // Check if product details are being fetched
        final isProductDetailLoading =
            controller.insuranceProductDetailState == NetworkState.loading;

        // Show loader if either data source is loading
        final isLoading = isInsuranceDataLoading || isProductDetailLoading;

        // Trigger quote generation once both are loaded
        if (!isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndTriggerQuoteGeneration(context);
          });
        }

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(),
          // Show loader while data is being fetched, empty container otherwise
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(),
        );
      },
    );
  }
}
