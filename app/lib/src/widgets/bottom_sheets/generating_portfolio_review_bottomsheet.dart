import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/client/portfolio_review_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/clients/reports/view/portfolio_review_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class GeneratingPortfolioReviewBottomSheet extends StatelessWidget {
  final NewClientModel client;

  const GeneratingPortfolioReviewBottomSheet({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioReviewController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Align(
                alignment: Alignment.topRight,
                child: CommonUI.bottomsheetCloseIcon(context),
              ),
            ),

            Container(
              child: Center(
                child: Container(
                  height: 180,
                  child: OverflowBox(
                    minHeight: 230,
                    maxHeight: 230,
                    child: Lottie.asset(
                      AllImages().generateReportLottie,
                      controller: controller.lottieController,
                      onLoaded: (composition) {
                        composition = composition;
                        controller.lottieController!
                          ..duration = composition.duration
                          ..forward();
                        controller.lottieController!.repeat();
                      },
                    ),
                  ),
                ),
              ),
            ),

            if (controller.portfolioReportResponse.isError)
              Center(
                child: RetryWidget(
                  controller.portfolioReportResponse.message,
                  onPressed: () {
                    controller.generatePortfolioReview();
                  },
                ),
              )
            else
              Center(
                child: Text(
                  controller.portfolioReportResponse.isLoading
                      ? 'Generating Portfolio Review \nfor ${client.name ?? ''}'
                      : 'Portfolio Review for \n${client.name ?? ''} Generated!',
                  textAlign: TextAlign.center,
                  style: context.headlineMedium?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),

            // Subtitle
            if (!controller.portfolioReportResponse.isError)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                child: Text(
                  controller.portfolioReportResponse.isLoading
                      ? 'This may take up to 5 minutes.\nYour file will download automatically\nonce ready'
                      : 'Report downloaded successfully. \nYou can now share or view the Portfolio \nReview for ${client.name ?? ''}',
                  textAlign: TextAlign.center,
                  style: context.headlineSmall?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            SizedBox(height: 20),
            _buildDownloadUI(context, controller),
            SizedBox(height: 100)
          ],
        );
      },
    );
  }

  Widget _buildDownloadUI(
    BuildContext context,
    PortfolioReviewController controller,
  ) {
    bool isAvailable = controller.portfolioReportModel?.isGenerated == true;

    if (isAvailable) {
      return GetBuilder<DownloadController>(
        tag: portfolioReviewDownloadTag,
        initState: (_) {
          final downloadController =
              Get.find<DownloadController>(tag: portfolioReviewDownloadTag);
          final url = controller.getDownloadURL;
          final dateString = DateFormat('d MMM yy').format(DateTime.now());

          final filename = 'CRN_${client.crn ?? ''}_${dateString}_Review';
          final fileExt = '.pdf';
          downloadController.downloadFileViaDio(
            url: url,
            filename: filename,
            extension: fileExt,
            addTimeStamp: false,
          );
        },
        builder: (downloadController) {
          final showProgressIndicator =
              downloadController.isFileDownloading.isTrue;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showProgressIndicator
                ? Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.8, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColorConstants.primaryAppColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      color: ColorConstants.primaryAppColor,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  Icon(
                                    Icons.download,
                                    color: ColorConstants.primaryAppColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Text(
                              'Downloading File...',
                              style: context.headlineLarge?.copyWith(
                                color: ColorConstants.primaryAppColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value * 0.7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return AnimatedContainer(
                                  duration: Duration(
                                      milliseconds: 400 + (index * 100)),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: ColorConstants.primaryAppColor
                                        .withOpacity(
                                      (value + index * 0.2).clamp(0.3, 1.0),
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          );
        },
      );
    }
    return SizedBox();
  }
}
