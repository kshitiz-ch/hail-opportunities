import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/utils/local_notification_service.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/src/intl/date_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppResourcesPdfActions extends StatefulWidget {
  final CreativeNewModel currentResource;
  final String? tag;

  const AppResourcesPdfActions(
      {super.key, required this.currentResource, this.tag});
  @override
  State<AppResourcesPdfActions> createState() => _AppResourcesPdfActionsState();
}

class _AppResourcesPdfActionsState extends State<AppResourcesPdfActions> {
  late final AppResourcesController controller;

  bool isDownloading = false;
  bool isAddMyBrand = false;

  void initState() {
    controller = Get.find<AppResourcesController>(tag: widget.tag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = controller.pdfResponse.isLoaded;

    if (isLoaded) {
      final isBrandingLoading = controller.brandingResponse.isLoading;
      if (isBrandingLoading) {
        return SkeltonLoaderCard(height: 100);
      }
      final branding = controller.branding;
      if (branding == null && isAddMyBrand) {
        return _buildNonBrandedActions();
      } else {
        return _buildBrandedActions();
      }
    }
    return SizedBox();
  }

  Widget _buildNonBrandedActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.secondaryAppColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AllImages().pdfBrandingIcon,
                height: 100,
                width: 100,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Unlock your custom-branded version of this report. ',
                      style: context.titleLarge!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    ActionButton(
                      margin: EdgeInsets.zero,
                      text: 'Publish your brand',
                      onPressed: () {
                        AutoRouter.of(context).push(BrandingWebViewRoute());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Not Now, ',
                style: context.headlineMedium!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: ClickableText(
                text: 'Download',
                onClick: () {
                  _downloadFile();
                },
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandedActions() {
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
                ctaName: 'Download PDF',
                resource: widget.currentResource,
                brandingAdded: controller.brandedPdfBytes != null,
              );

              final isFileDataAvailable = controller.pdfResponse.isLoaded &&
                  (controller.pdfBytes != null ||
                      controller.brandedPdfBytes != null);

              if (isFileDataAvailable) {
                _downloadFile();
              } else {
                _downloadFile(downloadViaUrl: true);
              }
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: controller.brandedPdfBytes != null
              ? ActionButton(
                  margin: EdgeInsets.zero,
                  text: 'Share',
                  onPressed: () async {
                    EventTracker.trackResourcesCTAClicked(
                      ctaName: 'Share PDF',
                      resource: widget.currentResource,
                      brandingAdded: controller.brandedPdfBytes != null,
                    );

                    if (controller.brandedPdfBytes != null) {
                      final tempDir = await getTemporaryDirectory();
                      final originalFileName =
                          widget.currentResource.url?.split('/').last ??
                              'document.pdf';
                      // Add "branded_" prefix to indicate this is a branded PDF
                      final fileName = 'branded_$originalFileName';
                      final file =
                          await File('${tempDir.path}/$fileName').create();
                      await file.writeAsBytes(controller.brandedPdfBytes!);
                      final text = widget.currentResource.description;
                      await shareFiles(file.path, text: text);
                    }
                  },
                )
              : ActionButton(
                  margin: EdgeInsets.zero,
                  showProgressIndicator:
                      controller.pdfBrandingResponse.isLoading,
                  text: 'Add my brand',
                  onPressed: () async {
                    EventTracker.trackResourcesCTAClicked(
                      ctaName: 'Add my brand',
                      resource: widget.currentResource,
                    );
                    if (controller.branding == null) {
                      setState(() {
                        isAddMyBrand = true;
                      });
                    } else {
                      await controller.addBrandingToPdf(
                          pdfUrl: widget.currentResource.url ?? '');
                      showToast(text: controller.pdfBrandingResponse.message);
                    }
                  },
                ),
        ),
      ],
    );
  }

  void _downloadFile({bool downloadViaUrl = false}) async {
    try {
      setState(() {
        isDownloading = true;
      });

      PermissionStatus permissionStatus = await getStorePermissionStatus();

      final String fileName = widget.currentResource.url!.split("/").last;

      final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());

      if (permissionStatus.isGranted) {
        var bytes = controller.brandedPdfBytes?.toList() ??
            controller.pdfBytes?.toList() ??
            [];

        if (downloadViaUrl) {
          String creativeUrl;
          if ((widget.currentResource.url ?? "").startsWith("http")) {
            creativeUrl = widget.currentResource.url!;
          } else {
            creativeUrl = 'https://${widget.currentResource.url})';
          }

          final response = await http.get(Uri.parse(creativeUrl));
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          }
        }

        final downloadDirectory = (await getDownloadPath())!;
        String realFileName = '';

        String nameWithoutExtension = fileName;
        if (fileName.toLowerCase().endsWith('.pdf')) {
          nameWithoutExtension = fileName.substring(0, fileName.length - 4);
        }
        // Add "branded_" prefix if using branded PDF bytes
        final isBranded = controller.brandedPdfBytes != null;
        final brandedPrefix = isBranded ? 'branded_' : '';
        realFileName = "$brandedPrefix${nameWithoutExtension}_$date.pdf";

        final docFile = File('${downloadDirectory}/$realFileName');

        // Delete existing file if it exists
        if (docFile.existsSync()) {
          await docFile.delete();
        }
        docFile.writeAsBytesSync(bytes);

        // Show download notification
        LocalNotificationService().showResourceDownloadNotification(
          fileName: fileName,
          filePath: docFile.path,
        );

        showToast(context: context, text: 'Download completed');
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
