import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/visiting_card_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadVisitingCard extends StatefulWidget {
  const DownloadVisitingCard(
      {Key? key, required this.templateName, required this.controller})
      : super(key: key);

  final String templateName;
  final VisitingCardController controller;
  @override
  State<DownloadVisitingCard> createState() => _DownloadVisitingCardState();
}

class _DownloadVisitingCardState extends State<DownloadVisitingCard> {
  bool isDownloading = false;

  void _downloadPdf(VisitingCardController controller,
      {bool isRetrying = false}) async {
    try {
      setState(() {
        isDownloading = true;
      });

      PermissionStatus permissionStatus = await getStorePermissionStatus();

      if (permissionStatus.isGranted) {
        String? downloadPath = await getDownloadPath();

        final File pdfFile;

        if (isRetrying) {
          final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
          pdfFile = File('${downloadPath}/$date.pdf');
        } else {
          pdfFile =
              File('${downloadPath}/${widget.templateName.toLowerCase()}.pdf');
        }

        List<int> bytes =
            controller.visitingCardBrochurePdfByte?.toList() ?? [];

        await pdfFile.writeAsBytes(bytes);

        showToast(
          context: context,
          text: 'Download completed',
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
      int? errorCode;
      if (error is FileSystemException) {
        errorCode = error.osError?.errorCode;
      }

      // In case overwriting an existing file fails
      // We Retry downloading by creating a new file
      if (!isRetrying && (errorCode == 13 || errorCode == 2)) {
        _downloadPdf(controller, isRetrying: true);
      } else {
        showToast(
          context: context,
          text:
              'Failed to download. Please check if permission given for storage access.',
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ActionButton(
        bgColor: ColorConstants.secondaryAppColor,
        margin: EdgeInsets.zero,
        text: 'Download',
        showProgressIndicator: isDownloading,
        progressIndicatorColor: ColorConstants.primaryAppColor,
        textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
            color: ColorConstants.primaryAppColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w700),
        onPressed: () async {
          MixPanelAnalytics.trackWithAgentId(
            "download_click",
            screen: 'partner_profile',
            screenLocation: widget.templateName == "PARTNER-VISITING-CARD"
                ? 'visiting_card'
                : 'brochure',
          );
          _downloadPdf(widget.controller);
        },
      ),
    );
  }
}
