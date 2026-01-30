import 'dart:io';
import 'dart:typed_data';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/utils/local_notification_service.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/src/intl/date_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppResourcesNonPdfActions extends StatefulWidget {
  final CreativeNewModel currentResource;
  final String? tag;

  const AppResourcesNonPdfActions(
      {super.key, required this.currentResource, this.tag});
  @override
  State<AppResourcesNonPdfActions> createState() =>
      _AppResourcesNonPdfActionsState();
}

class _AppResourcesNonPdfActionsState extends State<AppResourcesNonPdfActions> {
  late final AppResourcesController controller;

  bool isDownloading = false;
  bool isSharing = false;
  Uint8List? _fileBytes;

  Future<Uint8List?> _fetchRemoteFile() async {
    if (_fileBytes != null) return _fileBytes;

    try {
      String creativeUrl;
      if ((widget.currentResource.url ?? "").startsWith("http")) {
        creativeUrl = widget.currentResource.url!;
      } else {
        creativeUrl = 'https://${widget.currentResource.url}';
      }

      final response = await http.get(Uri.parse(creativeUrl));

      if (response.statusCode == 200) {
        _fileBytes = response.bodyBytes;
        return _fileBytes;
      }
    } catch (e) {
      debugPrint('Error fetching file: $e');
    }
    return null;
  }

  void initState() {
    controller = Get.find<AppResourcesController>(tag: widget.tag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildNonPdfActions();
  }

  Widget _buildNonPdfActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: ActionButton(
            margin: EdgeInsets.zero,
            text: 'Download',
            bgColor: ColorConstants.secondaryAppColor,
            progressIndicatorColor: ColorConstants.primaryAppColor,
            showProgressIndicator: isDownloading,
            textStyle: context.labelLarge!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w700),
            onPressed: () async {
              String? posterName;

              try {
                posterName = widget.currentResource.name
                    ?.split(RegExp(r'\s|,'))
                    .join("_");
              } catch (error) {
                // LogUtil.printLog(error);
              }

              EventTracker.trackResourcesCTAClicked(
                ctaName:
                    'Download ${widget.currentResource.type?.toUpperCase() ?? ''}',
                resource: widget.currentResource,
              );

              _downloadFile();
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: ActionButton(
            margin: EdgeInsets.zero,
            text: 'Share',
            showProgressIndicator: isSharing,
            onPressed: () async {
              EventTracker.trackResourcesCTAClicked(
                ctaName:
                    'Share ${widget.currentResource.type?.toUpperCase() ?? ''}',
                resource: widget.currentResource,
              );

              _shareFile();
            },
          ),
        ),
      ],
    );
  }

  void _shareFile() async {
    try {
      setState(() {
        isSharing = true;
      });

      final bytes = await _fetchRemoteFile();

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();

        String fileName = widget.currentResource.url!.split("/").last;
        String nameWithoutExtension = fileName;
        String extension = "";

        if (fileName.contains('.')) {
          nameWithoutExtension =
              fileName.substring(0, fileName.lastIndexOf('.'));
          extension = fileName.substring(fileName.lastIndexOf('.'));
        }

        final realFileName = "${nameWithoutExtension}$extension";
        final file = await File('${tempDir.path}/$realFileName').create();
        await file.writeAsBytes(bytes);

        final text = widget.currentResource.description;
        await shareFiles(file.path, text: text);
      } else {
        showToast(context: context, text: 'Sharing failed');
      }
    } catch (error) {
      showToast(
        context: context,
        text: 'Failed to share file.',
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  void _downloadFile() async {
    try {
      setState(() {
        isDownloading = true;
      });

      PermissionStatus permissionStatus = await getStorePermissionStatus();

      if (permissionStatus.isGranted) {
        final bytes = await _fetchRemoteFile();

        if (bytes != null) {
          final downloadDirectory = (await getDownloadPath())!;
          final String fileName = widget.currentResource.url!.split("/").last;
          final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());

          String nameWithoutExtension = fileName;
          String extension = "";

          if (fileName.contains('.')) {
            nameWithoutExtension =
                fileName.substring(0, fileName.lastIndexOf('.'));
            extension = fileName.substring(fileName.lastIndexOf('.'));
          }

          final realFileName = "${nameWithoutExtension}_$date$extension";
          final docFile = File('${downloadDirectory}/$realFileName');

          if (docFile.existsSync()) {
            await docFile.delete();
          }
          docFile.writeAsBytesSync(bytes);

          LocalNotificationService().showResourceDownloadNotification(
            fileName: fileName,
            filePath: docFile.path,
          );

          showToast(context: context, text: 'Download completed');
        } else {
          showToast(context: context, text: 'Download failed');
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        openPermissionDialog(context);
      } else {
        showToast(
          context: context,
          text:
              'Please give permission to access storage / photos for downloading the document',
        );
      }
    } catch (error) {
      showToast(
        context: context,
        text:
            'Failed to download. Please check if permission given for storage / photos access.',
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }
}
