import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

String soaReportDownloadTag = 'soa_download';

class SOAReportCard extends StatelessWidget {
  final controller = Get.find<SOADownloadController>();
  final Function onRetry;

  late TextStyle style;

  SOAReportCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    final reportModel = controller.soaReportModel;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          if (reportModel?.isFailure != true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildReportDetail(),
            ),
          if (reportModel?.isGenerated == true) _buildDownloadCTA(context),
          if (reportModel?.isInitiated == true)
            _buildAutoRefreshOrRefreshCTA(context),
          if (reportModel?.isFailure == true) _buildRetryCTA(context),
          _buildNote(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SOA Report',
          style: style.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstants.black,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'as on ${getFormattedDate(controller.soaReportModel?.updatedAt)}',
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
    final generationDate = controller.soaReportModel?.reportGeneratedAt;
    final expirationDate = controller.soaReportModel?.expiresAt;
    final formattedGenerationDate = generationDate == null
        ? 'N/A'
        : DateFormat('MMM dd, yyyy hh:mm:ss a').format(generationDate);
    final isExpired =
        controller.soaReportModel?.expiresAt?.isBefore(DateTime.now()) ?? false;
    final shortlink = controller.soaReportModel?.shortLink;

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
              SizedBox(width: 4),
              InkWell(
                onTap: () {
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
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _buildReportData(
            title: 'Expiration:',
            description: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpired ? 'Expired' : getFormattedDate(expirationDate),
                  style: style.copyWith(
                    color: isExpired
                        ? ColorConstants.errorColor
                        : ColorConstants.greenAccentColor,
                  ),
                ),
                if (isExpired)
                  InkWell(
                    onTap: () {
                      // Refresh current report
                      onRefreshReport();
                    },
                    child: Icon(
                      Icons.refresh,
                      color: ColorConstants.primaryAppColor,
                      size: 16,
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> onRefreshReport() async {
    showToast(text: 'Refreshing Report...');
    final newReport = await controller.refreshReportLink(
      controller.soaReportModel?.id ?? '',
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

  Widget _buildCTA({
    required BuildContext context,
    required String text,
    required bool showProgressIndicator,
    required IconData icon,
    required Function onPressed,
    bool isEnabled = true,
  }) {
    return ActionButton(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
      textStyle: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isEnabled
                ? ColorConstants.primaryAppColor
                : ColorConstants.tertiaryBlack.withOpacity(0.5),
          ),
      text: text,
      showProgressIndicator: showProgressIndicator,
      showBorder: true,
      borderColor: isEnabled
          ? ColorConstants.primaryAppColor
          : ColorConstants.borderColor,
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
        icon,
        size: 20,
        color: isEnabled
            ? ColorConstants.primaryAppColor
            : ColorConstants.tertiaryBlack.withOpacity(0.5),
      ),
      onPressed: isEnabled
          ? () {
              onPressed();
            }
          : null,
    );
  }

  Widget _buildAutoRefreshOrRefreshCTA(BuildContext context) {
    return GetBuilder<SOADownloadController>(
      builder: (soaDownloadController) {
        // Show auto-refresh progress if active
        if (controller.isAutoRefreshActive) {
          return _buildCTA(
            context: context,
            text: 'Auto-refreshing...',
            showProgressIndicator: true,
            icon: Icons.schedule,
            onPressed: () {
              // Disabled during auto-refresh
            },
            isEnabled: false,
          );
        }

        // Show manual refresh button after timeout or if auto-refresh not active
        return _buildCTA(
          context: context,
          text: 'Refresh',
          showProgressIndicator: controller.reportAvailabilityReponse.state ==
              NetworkState.loading,
          icon: Icons.refresh,
          onPressed: () async {
            await controller.checkAvailability();
          },
        );
      },
    );
  }

  Widget _buildRetryCTA(BuildContext context) {
    return _buildCTA(
      context: context,
      text: 'Retry',
      showProgressIndicator: false,
      icon: Icons.replay_rounded,
      onPressed: () async {
        onRetry();
      },
    );
  }

  Widget _buildDownloadCTA(BuildContext context) {
    return GetBuilder<DownloadController>(
      tag: soaReportDownloadTag,
      init: DownloadController(shouldOpenDownloadBottomSheet: true),
      builder: (downloadController) {
        final showProgressIndicator =
            downloadController.isFileDownloading.isTrue;
        return _buildCTA(
          context: context,
          text: 'Download',
          showProgressIndicator: showProgressIndicator,
          icon: Icons.download,
          onPressed: () async {
            final url = controller.getDownloadURL;
            final filename = 'soa_report';
            final fileExt = '.${controller.reportExtension}';
            downloadController.downloadFile(
              url: url,
              filename: filename,
              extension: fileExt,
            );
          },
        );
      },
    );
  }

  Widget _buildNote(BuildContext context) {
    final reportModel = controller.soaReportModel;
    final showNote = reportModel != null &&
        !reportModel.isGenerated &&
        controller.reportAvailabilityReponse.state != NetworkState.loading;

    if (!showNote) {
      return SizedBox();
    }

    String msg = '';
    Color color = ColorConstants.primaryAppColor;

    if (reportModel.isInitiated) {
      if (controller.isAutoRefreshActive) {
        msg = 'SOA generation in progress… This may take up to one minute.';
      } else {
        msg = 'File is being prepared. Click refresh to fetch file';
      }
    } else if (reportModel.isFailure) {
      color = ColorConstants.errorTextColor;
      msg = 'RTA/CAMS Service is currently down. Please try after sometime';
    }

    if (msg.isNullOrEmpty) {
      return SizedBox();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
      child: Text(
        '$msg',
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
