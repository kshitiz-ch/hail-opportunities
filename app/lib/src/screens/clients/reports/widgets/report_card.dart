import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/choose_download_format.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

class ReportCard extends StatelessWidget {
  final int templateIndex;
  final int reportIndex;
  ClientReportController controller = Get.find<ClientReportController>();
  late ReportDateType inputType;
  late String displayName;
  List<String> dateStr = [];
  List<String> fieldStr = [];

  ReportCard({
    Key? key,
    required this.templateIndex,
    required this.reportIndex,
  }) : super(key: key) {
    inputType =
        getInputType(controller.reportTemplateList![templateIndex].name ?? '');
    displayName = (controller.reportModelList[reportIndex].displayName ?? '')
        .split('(')
        .first;
    final dateData =
        controller.reportModelList[reportIndex].name?.split('/').toList();

    dateStr = [];
    fieldStr = [];
    if (dateData.isNotNullOrEmpty) {
      if (inputType == ReportDateType.SingleDate) {
        dateStr.add(parseDate(dateData!.last));
        fieldStr.add('Investments as on');
      }
      if (inputType == ReportDateType.IntervalDate) {
        dateStr.add(parseDate(dateData![1]));
        dateStr.add(parseDate(dateData.last));
        fieldStr.add('Investments from');
        fieldStr.add('Investments till');
      }
      if (inputType == ReportDateType.SingleYear) {
        dateStr.add(dateData!.last);
        fieldStr.add('Financial year');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              displayName,
              textAlign: TextAlign.left,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (inputType == ReportDateType.IntervalDate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text.rich(
                TextSpan(
                  text: 'Created on  ',
                  style: titleStyle,
                  children: [
                    TextSpan(
                      text: getDateMonthYearFormat(
                          controller.reportModelList[reportIndex].createdAt),
                      style: subtitleStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: inputType == ReportDateType.IntervalDate
                        ? fieldStr.first
                        : 'Created at',
                    subtitle: inputType == ReportDateType.IntervalDate
                        ? dateStr.first
                        : getDateMonthYearFormat(
                            controller.reportModelList[reportIndex].createdAt),
                    titleStyle: titleStyle,
                    subtitleStyle: subtitleStyle,
                  ),
                ),
                if (inputType != ReportDateType.None)
                  Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: fieldStr.last,
                      subtitle: dateStr.last,
                      titleStyle: titleStyle,
                      subtitleStyle: subtitleStyle,
                    ),
                  )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              AllImages().clientReportImage,
              height: 310,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCTA(
                  iconUrl: AllImages().downloadTabIcon,
                  text: 'Download Report',
                  context: context,
                  onTap: () async {
                    final downloadController = Get.find<DownloadController>();
                    // reset
                    downloadController.isFileDownloading.value = false;
                    await CommonUI.showBottomSheet(
                      context,
                      child: ChooseDownloadFormat(
                        client: controller.client,
                        reportModel: controller.reportModelList[reportIndex],
                        reportType: controller
                            .reportTemplateList![templateIndex].reportType!,
                      ),
                    );
                    if (downloadController.isFileDownloading.value) {
                      LogUtil.printLog('FlutterDownloader cancel');
                      FlutterDownloader.cancelAll();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCTA({
    required String iconUrl,
    required String text,
    required BuildContext context,
    required Function onTap,
    bool showLoader = false,
  }) {
    return Expanded(
      child: showLoader
          ? Center(
              child: CircularProgressIndicator(),
            )
          : InkWell(
              onTap: () {
                onTap();
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(14),
                  color: ColorConstants.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        iconUrl,
                        color: ColorConstants.primaryAppColor,
                        height: 14,
                        width: 14,
                      ),
                      SizedBox(width: 7),
                      Text(
                        text,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.primaryAppColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String parseDate(String date) {
    try {
      final listDate = date
          .split('-')
          .toList()
          .map<int>((str) => int.parse(str.trim()))
          .toList();
      final dateTime = DateTime(
        listDate[0],
        listDate[1],
        listDate[2],
      );
      return getDateMonthYearFormat(dateTime);
    } catch (e) {
      return '';
    }
  }
}
