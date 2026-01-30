import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/business_report_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

const String businessReportDownloadTag = 'business-report';

class BusinessReportCard extends StatelessWidget {
  final controller = Get.find<BusinessReportController>();

  late TextStyle style;

  @override
  Widget build(BuildContext context) {
    style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: _buildHeader(),
          ),
          CommonUI.buildProfileDataSeperator(color: ColorConstants.borderColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildReportDetail(),
          ),
          _buildDownloadCTA(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          controller.selectedAgentReportTemplate?.displayName ??
              'Business Report',
          style: style.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstants.black,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'as on ${getFormattedDate(controller.selectedTemplateReport?.createdAt)}',
          style: style,
        ),
      ],
    );
  }

  Widget _buildReportData({
    required String title,
    required Widget description,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: style.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 10),
        Expanded(child: description),
      ],
    );
  }

  Widget _buildReportDetail() {
    final generationDate = controller.selectedTemplateReport?.reportGeneratedAt;
    final expirationDate = controller.selectedTemplateReport?.expiresAt;
    final formattedGenerationDate = generationDate == null
        ? 'N/A'
        : DateFormat('MMM dd, yyyy hh:mm:ss a').format(generationDate);
    final isExpired = controller.selectedTemplateReport?.expiresAt
            ?.isBefore(DateTime.now()) ??
        false;
    final shortlink = controller.selectedTemplateReport?.shortLink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: _buildReportData(
            title: 'Generation Date:',
            description: Text(
              formattedGenerationDate,
              style: style,
            ),
          ),
        ),
        _buildReportData(
          title: 'Short Link:',
          description: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "click_report_link",
                    screen: 'business_report',
                    screenLocation:
                        (controller.selectedAgentReportTemplate?.displayName ??
                                '')
                            .toLowerCase()
                            .split(" ")
                            .join("-"),
                  );
                  if (shortlink.isNotNullOrEmpty) {
                    launch(controller.getDownloadURL);
                  }
                },
                child: Text(
                  shortlink ?? 'N/A',
                  style: style.copyWith(
                    color: Color(0xff4B93FF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "copy_report_link",
                    screen: 'business_report',
                    screenLocation:
                        (controller.selectedAgentReportTemplate?.displayName ??
                                '')
                            .toLowerCase()
                            .split(" ")
                            .join("-"),
                  );

                  copyData(data: controller.getDownloadURL);
                },
                child: Icon(
                  Icons.copy_rounded,
                  color: ColorConstants.primaryAppColor,
                  size: 16,
                ),
              )
            ],
          ),
        ),
        // TODO: refresh agent report currently not supported
        // uncomment when its supported
        // currently
        // although report generated might get expired from api
        // but its downloading url won't expired
        // Padding(
        //   padding: const EdgeInsets.only(top: 12),
        //   child: _buildReportData(
        //     title: 'Expiration:',
        //     description: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Text(
        //           isExpired ? 'Expired' : getFormattedDate(expirationDate),
        //           style: style.copyWith(
        //             color: isExpired
        //                 ? ColorConstants.errorColor
        //                 : ColorConstants.greenAccentColor,
        //           ),
        //         ),
        //         if (isExpired)
        //           InkWell(
        //             onTap: () {
        //               // Refresh current report
        //               onRefreshReport();
        //             },
        //             child: Icon(
        //               Icons.refresh,
        //               color: ColorConstants.primaryAppColor,
        //               size: 16,
        //             ),
        //           )
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }

  Future<void> onRefreshReport() async {
    showToast(text: 'Refreshing Report...');
    final newReport = await controller.refreshReportLink(
      controller.selectedTemplateReport?.id ?? '',
    );
    if (controller.refreshReportReponse.state == NetworkState.error) {
      showToast(text: controller.refreshReportReponse.message);
    }
    if (controller.refreshReportReponse.state == NetworkState.loaded) {
      if (newReport != null) {
        showToast(text: 'Report Refreshed Sucessfully');
      } else {
        showToast(text: 'Report Not Refreshed. Please try again');
      }
    }
  }

  Widget _buildDownloadCTA(BuildContext context) {
    return GetBuilder<DownloadController>(
      tag: businessReportDownloadTag,
      init: DownloadController(shouldOpenDownloadBottomSheet: true),
      builder: (downloadController) {
        return ActionButton(
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
          textStyle: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.primaryAppColor,
              ),
          text: 'Download',
          showProgressIndicator: downloadController.isFileDownloading.isTrue,
          showBorder: true,
          borderColor: ColorConstants.primaryAppColor,
          bgColor: ColorConstants.white,
          customLoader: Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
          prefixWidget: Icon(
            Icons.download,
            size: 20,
            color: ColorConstants.primaryAppColor,
          ),
          onPressed: () {
            MixPanelAnalytics.trackWithAgentId(
              "download",
              screen: 'business_report',
              screenLocation:
                  (controller.selectedAgentReportTemplate?.displayName ?? '')
                      .toLowerCase()
                      .split(" ")
                      .join("-"),
            );

            final url = controller.getDownloadURL;
            final templateName =
                controller.selectedAgentReportTemplate?.displayName;
            final date =
                getFormattedDate(controller.selectedTemplateReport?.createdAt);
            final filename = '${templateName ?? 'report'}-$date';
            final fileExt = '.${controller.reportExtension}';

            downloadController.downloadFile(
              url: url,
              filename: filename,
              extension: fileExt,
              viewFileAnalyticFn: () {
                MixPanelAnalytics.trackWithAgentId(
                  "view_report",
                  screen: 'business_report',
                  screenLocation:
                      (controller.selectedAgentReportTemplate?.displayName ??
                              '')
                          .toLowerCase()
                          .split(" ")
                          .join("-"),
                );
              },
              shareFileAnalyticFn: () {
                MixPanelAnalytics.trackWithAgentId(
                  "share_report",
                  screen: 'business_report',
                  screenLocation:
                      (controller.selectedAgentReportTemplate?.displayName ??
                              '')
                          .toLowerCase()
                          .split(" ")
                          .join("-"),
                );
              },
            );
          },
        );
      },
    );
  }
}
