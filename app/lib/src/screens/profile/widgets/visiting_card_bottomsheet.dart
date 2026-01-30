import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/visiting_card_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'download_visiting_card.dart';

class VisitingCardBottomSheet extends StatelessWidget {
  VisitingCardBottomSheet({required this.templateName});

  final String templateName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30).copyWith(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _buildCloseIcon(context),
          ),
          SizedBox(height: 20),
          GetBuilder<VisitingCardController>(
            init: VisitingCardController(templateName: templateName),
            builder: (controller) {
              if (controller.visitingCardBrochureState ==
                  NetworkState.loading) {
                return Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: ColorConstants.lightBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).toShimmer(
                  baseColor: ColorConstants.lightBackgroundColor,
                  highlightColor: ColorConstants.white,
                );
              }

              if (controller.visitingCardBrochureState == NetworkState.loaded) {
                return Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 300,
                      child: PDFView(
                        pdfData: controller.visitingCardBrochurePdfByte,
                        enableSwipe: false,
                        swipeHorizontal: true,
                        autoSpacing: false,
                        preventLinkNavigation: true,
                        defaultPage: controller.currentPdfPage,
                        onViewCreated:
                            (PDFViewController pdfViewController) async {
                          controller.pdfViewController = pdfViewController;
                          controller.totalPages =
                              await pdfViewController.getPageCount() ?? 0;
                          controller.update();
                        },
                        onPageChanged: (int? _, int? totalPages) {
                          if (controller.totalPages == 0) {
                            controller.totalPages = totalPages ?? 0;
                            controller.update();
                          }
                        },
                      ),
                    ),
                    if (controller.pdfViewController != null &&
                        controller.totalPages > 0)
                      _buildPageControl(context, controller),
                    _buildActions(context, controller)
                  ],
                );
              }

              return Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Failed to load. \nPlease try after some time',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageControl(
      BuildContext context, VisitingCardController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 20),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              controller.updateCurrentPdfPage(controller.currentPdfPage - 1);
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${controller.currentPdfPage + 1} / ${controller.totalPages}',
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          InkWell(
            onTap: () {
              controller.updateCurrentPdfPage(controller.currentPdfPage + 1);
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, VisitingCardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DownloadVisitingCard(
            templateName: templateName, controller: controller),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: ActionButton(
            margin: EdgeInsets.zero,
            text: 'Share',
            onPressed: () async {
              MixPanelAnalytics.trackWithAgentId(
                "share_click",
                screen: 'partner_profile',
                screenLocation: templateName == "PARTNER-VISITING-CARD"
                    ? 'visiting_card'
                    : 'brochure',
              );
              _sharePdf(context, controller);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCloseIcon(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Container(
        alignment: Alignment.topRight,
        height: 32,
        width: 32,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: ColorConstants.secondaryLightGrey,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _sharePdf(
      BuildContext context, VisitingCardController controller) async {
    try {
      CommonUI.showBottomSheet(
        context,
        child: SizedBox(
          height: 100,
          child: Center(
              child: CircularProgressIndicator(
            color: ColorConstants.primaryAppColor,
          )),
        ),
      );

      final String fileName = templateName.toLowerCase();
      final Directory temp = await getTemporaryDirectory();

      final File pdfFile = File('${temp.path}/$fileName.pdf');
      bool isPdfExists = await pdfFile.exists();

      if (isPdfExists) {
        pdfFile.delete();
      }

      List<int> bytes = controller.visitingCardBrochurePdfByte?.toList() ?? [];
      pdfFile.writeAsBytesSync(bytes);

      await shareFiles(pdfFile.path);
    } catch (error) {
      showToast(text: 'Failed to share. Please try again');
    } finally {
      AutoRouter.of(context).popForced();
    }
  }
}
