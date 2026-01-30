import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/home/report/business_report/widgets/business_report_card.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DownloadRevenueSheetBottomSheet extends StatefulWidget {
  @override
  State<DownloadRevenueSheetBottomSheet> createState() =>
      _DownloadRevenueSheetBottomSheetState();
}

class _DownloadRevenueSheetBottomSheetState
    extends State<DownloadRevenueSheetBottomSheet> {
  DateTime? revenueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generate Revenue Sheet Report',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: CommonUI.bottomsheetCloseIcon(context),
                ),
              ],
            ),
          ),
          _buildRevenueMonth(context),
          _buildDownloadRevenueSheetUI(context)
        ],
      ),
    );
  }

  Widget _buildRevenueMonth(BuildContext context) {
    return Row(
      children: [
        Text(
          'Revenue Sheet Month ',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall
              ?.copyWith(color: ColorConstants.black),
        ),
        SizedBox(width: 50),
        _buildMonthSelector(context),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );

    return InkWell(
      onTap: () {
        CommonUI.monthYearSelector(
          context,
          selectedDate: revenueDate,
          onDateSelect: (newDate) {
            if (mounted) {
              setState(() {
                revenueDate = newDate;
              });
            }
          },
        );
      },
      child: Row(
        children: [
          Image.asset(
            AllImages().calendarCheckIcon,
            width: 26,
            height: 26,
          ),
          SizedBox(width: 3),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  revenueDate == null
                      ? 'Select Month'
                      : DateFormat('MMM yyyy').format(revenueDate!),
                  style: style!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_outlined,
                color: ColorConstants.primaryAppColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onDownload(DownloadController downloadController) {
    final url =
        '${F.url}/external-apis/revenue-sheet/download/?year=${revenueDate?.year}&month=${revenueDate?.month}';
    final filename = 'revenue_sheet';
    final fileExt = '.xlsx';
    downloadController.downloadFile(
      url: url,
      filename: filename,
      extension: fileExt,
    );
  }

  Widget _buildDownloadRevenueSheetUI(BuildContext context) {
    return GetBuilder<DownloadController>(
      tag: businessReportDownloadTag,
      init: DownloadController(
        authorizationRequired: true,
        shouldOpenDownloadBottomSheet: true,
      ),
      builder: (downloadController) {
        return ActionButton(
          text: 'Download Revenue Sheet',
          onPressed: () async {
            onDownload(downloadController);
          },
          showProgressIndicator: downloadController.isFileDownloading.isTrue,
          isDisabled: revenueDate == null,
          margin: EdgeInsets.symmetric(vertical: 40),
        );
      },
    );
  }
}
