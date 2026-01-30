import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/tnc_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class TncBottomSheet extends StatelessWidget {
  const TncBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Text(
                  'Please accept the Terms & Conditions of Empaneled Partner Service',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.tertiaryBlack,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GetBuilder<TncController>(
                init: TncController(),
                builder: (controller) {
                  if (controller.generatePdfResponse.state ==
                      NetworkState.loading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (controller.generatePdfResponse.state ==
                      NetworkState.error) {
                    return Center(
                      child: RetryWidget(
                        controller.generatePdfResponse.message,
                        onPressed: controller.generateTncPdf,
                      ),
                    );
                  } else if (controller.generatePdfResponse.state ==
                      NetworkState.loaded) {
                    return Column(
                      children: [
                        Expanded(
                          // height: MediaQuery.of(context).size.height - 200,
                          child: Container(
                            child: PDFView(
                              pdfData: controller.pdfBytes,
                              enableSwipe: false,
                              swipeHorizontal: true,
                              autoSpacing: false,
                              preventLinkNavigation: true,
                              defaultPage: controller.currentPdfPage,
                              onViewCreated:
                                  (PDFViewController pdfViewController) async {
                                controller.pdfViewController =
                                    pdfViewController;
                                controller.totalPages =
                                    await pdfViewController.getPageCount() ?? 0;
                                controller.update();
                              },
                              onPageChanged: (int? _, int? totalPages) {
                                if (controller.totalPages == 0) {
                                  controller.totalPages = totalPages ?? 0;
                                  controller.update();
                                }
                              },
                            ),
                          ),
                        ),
                        _buildPageControl(context, controller),
                        _buildAction(context, controller)
                      ],
                    );
                  }

                  return SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageControl(BuildContext context, TncController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 20),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              controller.updateCurrentPdfPage(controller.currentPdfPage - 1);
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${controller.currentPdfPage + 1} / ${controller.totalPages}',
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          InkWell(
            onTap: () {
              controller.updateCurrentPdfPage(controller.currentPdfPage + 1);
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, TncController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ActionButton(
        margin: EdgeInsets.zero,
        text: 'Accept & Continue',
        showProgressIndicator:
            controller.uploadPdfResponse.state == NetworkState.loading,
        onPressed: () async {
          MixPanelAnalytics.trackWithAgentId("tnc_accepted");
          await controller.uploadTncPdf();

          if (controller.uploadPdfResponse.state == NetworkState.error) {
            return showToast(text: controller.uploadPdfResponse.message);
          }

          if (controller.uploadPdfResponse.state == NetworkState.loaded) {
            showToast(
              text: 'Terms and Conditions Accepted Successfully',
              duration: Duration(seconds: 3),
            );
            AutoRouter.of(context)
                .popUntil(ModalRoute.withName(BaseRoute.name));
            if (Get.isRegistered<HomeController>()) {
              HomeController homeController = Get.find<HomeController>();
              homeController.getAdvisorOverview();
            }
          }
        },
      ),
    );
  }
}
