import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/generate_report_lottie.dart';

@RoutePage()
class ReportDownloadScreen extends StatelessWidget {
  const ReportDownloadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          Get.find<ReportController>().isFileLinkRefreshing.value == false.obs;
          Get.find<ReportController>().updateFileDownloadingStatus(false);
          AutoRouter.of(context).popForced();
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(
          titleText: 'Download Report',
        ),
        body: GenerateReportLottie(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0).copyWith(bottom: 40),
            child: GetBuilder<ReportController>(
              id: GetxId.form,
              builder: (controller) {
                bool isReportGenerated =
                    controller.createReport.state == NetworkState.loaded;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () {
                        return ActionButton(
                          text: 'Download Report',
                          bgColor: ColorConstants.primaryAppColor,
                          showProgressIndicator:
                              controller.isFileDownloading.value == true ||
                                  (controller.isFileLinkRefreshing.value &&
                                      isReportGenerated),
                          isDisabled: !isReportGenerated,
                          onPressed: () async {
                            String groupName = (controller
                                        .selectedReportTemplateGroup
                                        ?.groupName ??
                                    '')
                                .toLowerCase()
                                .split(" ")
                                .join("-");
                            MixPanelAnalytics.trackWithAgentId(
                              "download_report",
                              screen: groupName,
                              screenLocation: 'download_report',
                            );

                            controller.isFileDownloading.value = false;
                            // check if token is expired
                            if (controller.downloadReport?.status != "A_1" ||
                                controller.downloadReport?.expiresAt
                                        ?.isBefore(DateTime.now()) ==
                                    true) {
                              final availabilityData =
                                  await checkReportAvailability(
                                onRefresh: () {
                                  return controller.refreshReportLink(
                                      reportId:
                                          controller.downloadReport?.id ?? '');
                                },
                              );

                              bool isAvailable =
                                  availabilityData['isAvailable'];
                              ReportModel? newReportModel =
                                  availabilityData['newReportModel'];

                              if (isAvailable) {
                                controller.downloadReport?.status =
                                    newReportModel?.status;
                                controller.downloadReport?.urlToken =
                                    newReportModel?.urlToken;
                                controller.downloadReport?.shortLink =
                                    newReportModel?.shortLink;
                              }
                            }

                            if (controller.selectedFileFormat == 'web' &&
                                (controller.downloadReport?.shortLink
                                        ?.isNotNullOrEmpty ??
                                    false)) {
                              launch(controller.downloadReport!.shortLink!);
                            } else {
                              await controller.downloadAsset();
                            }
                          },
                        );
                      },
                    ),
                    if (isReportGenerated &&
                        (controller.downloadReport?.shortLink ?? '')
                            .isNotNullOrEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: ClickableText(
                          text: 'Open Report from Web',
                          fontSize: 14,
                          onClick: () {
                            String groupName = (controller
                                        .selectedReportTemplateGroup
                                        ?.groupName ??
                                    '')
                                .toLowerCase()
                                .split(" ")
                                .join("-");
                            MixPanelAnalytics.trackWithAgentId(
                              "open_report_from_web",
                              screen: groupName,
                              screenLocation: 'download_report',
                            );

                            launch(controller.downloadReport!.shortLink!);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    // return GetBuilder<ReportController>(
    //   id: GetxId.form,
    //   builder: (controller) {
    //     bool isReportGenerated =
    //         controller.createReport.state == NetworkState.loaded;
    //     return ;
    //   },
    // );
  }
}
