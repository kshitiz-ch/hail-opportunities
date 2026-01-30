import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/resources/view/resources_screen.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AppResourcesImageActions extends StatefulWidget {
  final CreativeNewModel? currentResource;
  final String? tag;

  const AppResourcesImageActions({
    super.key,
    required this.currentResource,
    this.tag,
  });
  @override
  State<AppResourcesImageActions> createState() =>
      _AppResourcesImageActionsState();
}

class _AppResourcesImageActionsState extends State<AppResourcesImageActions> {
  late final AppResourcesController controller;
  late final HomeController homeController;

  bool isDownloading = false;

  void initState() {
    controller = Get.find<AppResourcesController>(tag: widget.tag);
    homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final targetList = controller.activeList;

    // Handle empty list or invalid index
    if (targetList.isEmpty || controller.currentIndex >= targetList.length) {
      return SizedBox();
    }

    // Get the current creative from controller or use the provided one
    CreativeNewModel currentCreative =
        widget.currentResource ?? targetList[controller.currentIndex];

    // Show empanelment section if image is blurred
    if (currentCreative.blur) {
      return buildPostersEmpanelmentSection(
        context,
        pageName: 'Posters',
      );
    }

    final isDisabled = controller.whiteLabelResponse.isLoading;
    String? onboardingLink =
        homeController.advisorOverviewModel?.agent?.referralUrl;

    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (onboardingLink.isNotNullOrEmpty &&
            !controller.isOnboardingLinkAutoCopied) {
          Clipboard.setData(
            ClipboardData(text: onboardingLink ?? ''),
          );
          controller.setOnboardingLinkAutoCopied();
        }
      });
    }

    return Column(
      children: [
        if (Platform.isAndroid && onboardingLink.isNotNullOrEmpty)
          _buildCheckbox(context),
        if (Platform.isIOS && onboardingLink.isNotNullOrEmpty)
          _buildOnboardingLinkText(
            context,
            onboardingLink!,
            controller.isOnboardingLinkAutoCopied,
          ),
        Row(
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
                isDisabled: isDisabled,
                textStyle: context.labelLarge!.copyWith(
                    color: isDisabled
                        ? ColorConstants.tertiaryBlack
                        : ColorConstants.primaryAppColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700),
                onPressed: () async {
                  String? posterName;

                  try {
                    posterName =
                        currentCreative.name?.split(RegExp(r'\s|,')).join("_");
                  } catch (error) {
                    // LogUtil.printLog(error);
                  }

                  EventTracker.trackResourcesCTAClicked(
                    ctaName: 'Download Poster',
                    resource: currentCreative,
                  );

                  final isFileDataAvailable =
                      controller.whiteLabelResponse.isLoaded &&
                          controller.whiteLabelCreativeBytes != null;

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
              child: ActionButton(
                margin: EdgeInsets.zero,
                text: 'Share',
                isDisabled: isDisabled,
                onPressed: () async {
                  String? posterName;
                  try {
                    posterName =
                        currentCreative.name?.split(RegExp(r'\s|,')).join("_");
                  } catch (error) {}

                  EventTracker.trackResourcesCTAClicked(
                    ctaName: 'Share Poster',
                    resource: currentCreative,
                    onboardingLink: controller.shareWithOnboardingLink,
                  );

                  _shareFile();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Transform.scale(
              scale: 0.8,
              child: CommonUI.buildCheckbox(
                value: controller.shareWithOnboardingLink,
                unselectedBorderColor: ColorConstants.darkGrey,
                onChanged: (bool? value) {
                  if (controller.whiteLabelResponse.state ==
                      NetworkState.loading) {
                    return;
                  }

                  if (!controller.shareWithOnboardingLink) {}
                  controller.toggleShareWithOnboardingLink();
                },
              ),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.toggleShareWithOnboardingLink();
              },
              child: Text(
                'Include onboarding link while sharing',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOnboardingLinkText(BuildContext context, String onboardingLink,
      bool isOnboardingLinkAutoCopied) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.borderColor),
              borderRadius: BorderRadius.circular(2),
            ),
            child: CommonUI.onboardingLinkClipBoard(context, onboardingLink,
                fromScreen: 'poster_gallery'),
          ),
          if (isOnboardingLinkAutoCopied)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Your Client Onboarding link is copied. You can paste it in Whatsapp while sharing this image',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.primaryAppColor, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  String getShareText() {
    String text = widget.currentResource?.description ?? '';

    final onboardingLink =
        controller.homeController.advisorOverviewModel?.agent?.referralUrl;

    if (onboardingLink.isNotNullOrBlank && controller.shareWithOnboardingLink) {
      text +=
          '\nStart your investing journey with me by clicking here - ${onboardingLink}';
    }

    return text;
  }

  Future<void> _shareFile() async {
    final shareText = getShareText();

    final file = controller.isMarketingKitSelected
        ? controller.whiteLabelFile
        : controller.pdfFile;

    if (file != null) {
      await shareFiles(
        file.path,
        text: shareText,
      );
    } else {
      final currentResource = controller.isMarketingKitSelected
          ? controller.creativesList[controller.currentIndex]
          : controller.resources[controller.currentIndex];
      await shareImage(
        context: context,
        creativeUrl: (currentResource.url ?? "").startsWith("http")
            ? currentResource.url
            : 'https://${currentResource.url}',
        text: shareText,
      );
    }
  }

  void _downloadFile({bool downloadViaUrl = false}) async {
    try {
      setState(() {
        isDownloading = true;
      });

      PermissionStatus permissionStatus = await getStorePermissionStatus();

      if (permissionStatus.isGranted) {
        var bytes = controller.whiteLabelCreativeBytes?.toList() ?? [];

        if (downloadViaUrl) {
          final currentCreative = widget.currentResource ??
              controller.activeList[controller.currentIndex];
          String creativeUrl;
          if ((currentCreative.url ?? "").startsWith("http")) {
            creativeUrl = currentCreative.url!;
          } else {
            creativeUrl = 'https://${currentCreative.url})';
          }

          final response = await http.get(Uri.parse(creativeUrl));
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          }
        }

        await FlutterImageGallerySaver.saveImage(Uint8List.fromList(bytes));

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
