import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/cob_steps.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class GenerateCobSuccessfulScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
          height: 1.4,
        );
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Form generated Successfully',
        onBackPress: () {
          AutoRouter.of(context).popUntilRouteWithName(TicobRoute.name);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AllImages().cobFormSuccessIcon,
              height: 84,
              width: 84,
            ),
            SizedBox(height: 16),
            Text(
              'Form generated Successfully',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium
                  ?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 30),
              child: Text.rich(
                TextSpan(
                  text:
                      'Generated Form include change of Broker form \nof all Folios. Please get all forms signed by \nclient & Courier to ',
                  children: [
                    TextSpan(
                      text: 'Wealthy Office',
                      style: style?.copyWith(color: ColorConstants.black),
                    )
                  ],
                ),
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
            ClickableText(
              mainAxisAlignment: MainAxisAlignment.center,
              prefixIcon: Icon(
                Icons.copy,
                color: ColorConstants.primaryAppColor,
              ),
              text: '  Copy Wealthy Address',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              onClick: () {
                copyData(data: wealthyAddress);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCTA(),
    );
  }

  Widget _buildCTA() {
    final controller = Get.find<TicobController>();

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        bool isDownloading = false;

        void _saveReportToDevice() async {
          try {
            setState(() {
              isDownloading = true;
            });

            PermissionStatus permissionStatus =
                await getStorePermissionStatus();

            if (permissionStatus.isGranted) {
              String? downloadPath = await getDownloadPath();

              final File docFile;

              String reportExtension = 'pdf';
              String fileName = 'cob_form';

              final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
              docFile =
                  File('${downloadPath}/$fileName-$date.$reportExtension');

              List<int> bytes = controller.cobFormDocByte?.toList() ?? [];

              await docFile.writeAsBytes(bytes);

              showToast(
                context: context,
                text: 'Form Saved to Device!',
              );

              await CommonUI.showBottomSheet(
                getGlobalContext(),
                child: DownloadedReportBottomSheet(
                  onShare: () async {
                    try {
                      await shareFiles(docFile.path);
                    } catch (error) {
                      LogUtil.printLog(
                          "Failed to share. Please try after some time");
                    }
                  },
                  onView: () async {
                    final data = await OpenFile.open(
                      docFile.path,
                      type: 'application/pdf',
                    );
                    LogUtil.printLog(data.toString());
                  },
                  reportName: fileName,
                ),
              );
            } else if (permissionStatus.isPermanentlyDenied) {
              openPermissionDialog(context);
            } else {
              showToast(
                  context: context,
                  text:
                      'Please give permission to access storage for downloading the document');
            }
          } catch (error) {
            showToast(
                context: context,
                text:
                    'Failed to download. Please check if permission given for storage access.');
          } finally {
            setState(
              () {
                isDownloading = false;
              },
            );
          }
        }

        return ActionButton(
          text: 'Download Form',
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          showProgressIndicator: isDownloading,
          onPressed: () {
            _saveReportToDevice();
          },
        );
      },
    );
  }
}
