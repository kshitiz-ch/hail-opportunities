import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientMasterReportBottomSheet extends StatefulWidget {
  const ClientMasterReportBottomSheet({Key? key}) : super(key: key);

  @override
  State<ClientMasterReportBottomSheet> createState() =>
      _ClientMasterReportBottomSheetState();
}

class _ClientMasterReportBottomSheetState
    extends State<ClientMasterReportBottomSheet> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientListController>(
      id: GetxId.clientReport,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          constraints: BoxConstraints(minHeight: 250),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleAndCloseIcon(context),
              SizedBox(height: 40),
              if (controller.clientReportResponse.state == NetworkState.loading)
                _buildLoader(context)
              else if (controller.clientReportResponse.state ==
                  NetworkState.error)
                RetryWidget(
                  controller.clientReportResponse.message,
                  onPressed: () {
                    controller.createAgentReport();
                  },
                )
              else if (controller.clientReportResponse.state ==
                  NetworkState.loaded)
                _buildReportGenerated(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleAndCloseIcon(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Client Master Report',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
          ),
          CommonUI.bottomsheetCloseIcon(context)
        ],
      ),
    );
  }

  Widget _buildLoader(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 30),
        Text('Generating Report...'),
      ],
    );
  }

  Widget _buildReportGenerated(
      BuildContext context, ClientListController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.description_outlined,
          color: ColorConstants.greenAccentColor,
          size: 50,
        ),
        SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'Client Master Report ',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
            children: [
              TextSpan(
                text: '(Excel Format)',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall
                    ?.copyWith(color: ColorConstants.tertiaryBlack),
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ActionButton(
          text: 'Download Report',
          showProgressIndicator:
              controller.downloadReportState == NetworkState.loading ||
                  isDownloading,
          margin: EdgeInsets.zero,
          onPressed: () async {
            MixPanelAnalytics.trackWithAgentId(
              "download_report",
              screen: 'clients',
              screenLocation: 'client_master_report',
            );

            await controller.downloadAgentReport();

            if (controller.downloadReportState == NetworkState.loaded) {
              _saveReportToDevice(controller);
            } else if (controller.downloadReportState == NetworkState.error) {
              showToast(text: 'Download Failed. Please try again');
            }
          },
        ),
        // SizedBox(
        //   width: 200,
        //   child: ActionButton(
        //     text: 'Open Report',
        //     margin: EdgeInsets.zero,
        //     onPressed: () {
        //       launch(controller.reportUrl ?? '');
        //     },
        //   ),
        // )
      ],
    );
  }

  void _saveReportToDevice(ClientListController controller) async {
    try {
      setState(() {
        isDownloading = true;
      });

      PermissionStatus permissionStatus = await getStorePermissionStatus();

      if (permissionStatus.isGranted) {
        String? downloadPath = await getDownloadPath();

        final File docFile;

        String reportExtension = controller.reportExtension;
        String templateName = 'client-master-report';

        final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
        docFile = File('${downloadPath}/$templateName-$date.$reportExtension');

        List<int> bytes = controller.clientReportDocByte?.toList() ?? [];

        await docFile.writeAsBytes(bytes);

        showToast(
          context: context,
          text: 'Report Saved to Device!',
        );
        await CommonUI.showBottomSheet(
          getGlobalContext(),
          child: DownloadedReportBottomSheet(
            onShare: () async {
              try {
                await shareFiles(docFile.path);
              } catch (error) {
                LogUtil.printLog("Failed to share. Please try after some time");
              }
            },
            onView: () async {
              final data = await OpenFile.open(
                docFile.path,
                type: 'application/$reportExtension',
              );
              LogUtil.printLog(data.toString());
            },
            reportName: 'Client Master Report',
          ),
        );
      } else if (permissionStatus.isPermanentlyDenied) {
        openPermissionDialog(context);
      } else {
        showToast(
          context: context,
          text:
              'Please give permission to access storage for downloading the document',
        );
      }
    } catch (error) {
      showToast(
        context: context,
        text:
            'Failed to download. Please check if permission given for storage access.',
      );
    } finally {
      setState(
        () {
          isDownloading = false;
        },
      );
    }
  }
}
