import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseDownloadFormat extends StatefulWidget {
  final Client client;
  final String reportType;
  final ReportModel reportModel;

  ChooseDownloadFormat({
    Key? key,
    required this.reportType,
    required this.reportModel,
    required this.client,
  }) : super(key: key);

  @override
  State<ChooseDownloadFormat> createState() => _ChooseDownloadFormatState();
}

class _ChooseDownloadFormatState extends State<ChooseDownloadFormat> {
  String? selectedFileFormat;

  final clientReportController = Get.find<ClientReportController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Report File Format',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                CommonUI.bottomsheetCloseIcon(context)
              ],
            ),
          ),
          _buildFileFormatDropDown(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: GetBuilder<DownloadController>(
              builder: (downloadController) {
                return Obx(
                  () {
                    // Listen from multiple controllers
                    return ActionButton(
                      showProgressIndicator:
                          downloadController.isFileDownloading.value ||
                              clientReportController.isFileLinkRefreshing.value,
                      text: 'Download Now',
                      margin: EdgeInsets.zero,
                      onPressed: () async {
                        if (selectedFileFormat == null) {
                          return showToast(text: 'Choose a file format');
                        }

                        // check if token is expired
                        if (widget.reportModel.expiresAt
                                ?.isBefore(DateTime.now()) ==
                            true) {
                          final newReportModel =
                              await clientReportController.refreshReportLink(
                                  reportId: widget.reportModel.id ?? '');
                          widget.reportModel.urlToken =
                              newReportModel?.urlToken;
                          widget.reportModel.shortLink =
                              newReportModel?.shortLink;
                        }
                        if (selectedFileFormat == 'web' &&
                            widget.reportModel.shortLink.isNotNullOrEmpty) {
                          launch(widget.reportModel.shortLink!);
                        } else {
                          _downloadAsset(downloadController);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileFormatDropDown() {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return SimpleDropdownFormField<String>(
      hintText: 'File Format',
      dropdownMaxHeight: 500,
      items: widget.reportType.split(',').toList(),
      value: selectedFileFormat,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      borderRadius: 15,
      label: 'File Format',
      onChanged: (val) {
        if (val.isNotNullOrEmpty) {
          selectedFileFormat = val;
          setState(() {});
        }
      },
      validator: (val) {
        if (val.isNullOrEmpty) {
          return 'File Format is required.';
        }
        return null;
      },
    );
  }

  void _downloadAsset(DownloadController controller) async {
    final baseUrl = F.urlTaxy;
    final url =
        '$baseUrl/entreat-reports/v0/view-report/?token=${widget.reportModel.urlToken}&report_type=${selectedFileFormat}';
    final fileName = widget.reportModel.displayName;
    String fileExt = '.$selectedFileFormat';

    controller.downloadFile(
      url: url,
      filename: fileName!,
      extension: fileExt,
      customLaunchUrl: widget.reportModel.shortLink ?? url,
    );
  }
}
