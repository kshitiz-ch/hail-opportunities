import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/portfolio_review_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/portfolio_review_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottom_sheets/generating_portfolio_review_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const portfolioReviewDownloadTag = 'portfolio_review_download';

@RoutePage()
class PortfolioReviewScreen extends StatelessWidget {
  final NewClientModel client;

  final downloadController = Get.put<DownloadController>(
    DownloadController(shouldOpenDownloadBottomSheet: true),
    tag: portfolioReviewDownloadTag,
  );

  PortfolioReviewScreen({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioReviewController>(
      init: PortfolioReviewController(client: client),
      dispose: (_) {
        Get.delete<DownloadController>(tag: portfolioReviewDownloadTag);
      },
      builder: (controller) {
        final disableCTA = (controller.isTrackerSynced == false) ||
            (controller.selectedPanModel?.hasValidOutsideInvestments == false);
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Portfolio Review Report',
            subtitleText: 'Client : ${(client.name ?? 'N/A').toTitleCase()}',
          ),
          body: controller.syncedPansResponse.isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : controller.syncedPansResponse.isError
                  ? Center(
                      child: RetryWidget(
                        controller.syncedPansResponse.message,
                        onPressed: () {
                          controller.getSyncedPans();
                        },
                      ),
                    )
                  : PortfolioReviewSection(),
          floatingActionButton: controller.syncedPansResponse.isLoaded
              ? ActionButton(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  text: 'Generate Portfolio Review',
                  isDisabled: disableCTA,
                  onPressed: () {
                    controller.generatePortfolioReview();
                    CommonUI.showBottomSheet(
                      context,
                      child:
                          GeneratingPortfolioReviewBottomSheet(client: client),
                    );
                  },
                )
              : SizedBox(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
