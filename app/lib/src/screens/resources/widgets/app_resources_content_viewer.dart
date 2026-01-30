import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/screens/resources/view/resources_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

/// Widget to display the content of resources (images or PDFs)
class AppResourcesContentViewer extends StatelessWidget {
  final String? tag;
  const AppResourcesContentViewer({
    super.key,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppResourcesController>(tag: tag);
    final isImage = controller.activeList[controller.currentIndex].isImage;
    final isPdf = controller.activeList[controller.currentIndex].isPdf;

    if (isImage) {
      return _loadWhiteLabelCreative(controller);
    }

    if (isPdf) {
      return _loadPdfResources(controller, context);
    }

    return _buildResourceThumbnail(controller);
  }

  Widget _loadPdfResources(
      AppResourcesController controller, BuildContext context) {
    final targetList = controller.activeList;

    if (targetList.isEmpty || controller.currentIndex >= targetList.length) {
      return Container(
        height: 60,
        child: Center(
          child: Text('No creative available'),
        ),
      );
    }

    if (controller.pdfResponse.isLoading) {
      return Container(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.pdfResponse.isError) {
      return Center(
        child: RetryWidget(
          controller.pdfResponse.message,
          onPressed: () => controller.getPdfResources(),
        ),
      );
    } else if (controller.pdfResponse.isLoaded) {
      final pdfBytes = controller.brandedPdfBytes ?? controller.pdfBytes;
      final isBranded = controller.brandedPdfBytes != null;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBranded)
            Text(
              'Branding added successfully..',
              style: context.headlineMedium?.copyWith(
                color: ColorConstants.greenAccentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          SizedBox(height: 10),
          Expanded(
            // Using a unique key based on branding state to force PDFView to rebuild
            // when brandedPdfBytes becomes available. Without this, PDFView retains
            // the original unbranded PDF data even after branding is applied.
            child: PDFView(
              key: ValueKey('pdf_view_branded_$isBranded'),
              pdfData: pdfBytes,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              preventLinkNavigation: true,
              pageFling: true,
              onViewCreated: controller.onPdfViewCreated,
              onPageChanged: (int? page, int? total) {
                if (page != null && total != null) {
                  controller.onPdfPageChanged(page, total);
                }
              },
            ),
          ),
          _buildPdfControls(controller, context)
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildPdfControls(
      AppResourcesController controller, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: controller.currentPdfPage > 0
                ? () => controller
                    .updateCurrentPdfPage(controller.currentPdfPage - 1)
                : null,
          ),
          SizedBox(width: 16),
          Text(
            '${controller.currentPdfPage + 1} / ${controller.totalPdfPages}',
            style: context.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: controller.currentPdfPage < controller.totalPdfPages - 1
                ? () => controller
                    .updateCurrentPdfPage(controller.currentPdfPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _loadWhiteLabelCreative(AppResourcesController controller) {
    final targetList = controller.activeList;

    if (targetList.isEmpty || controller.currentIndex >= targetList.length) {
      return Container(
        height: 60,
        child: Center(
          child: Text('No creative available'),
        ),
      );
    }

    final creative = targetList[controller.currentIndex];

    if (creative.blur) {
      return Image.asset(
        AllImages().blurPoster,
        fit: BoxFit.contain,
      );
    }

    if (!creative.isImage) {
      final fileMetaData = getFileMetaData('https://${creative.url!}');

      return SizedBox(
        height: 100,
        width: 100,
        child: Image.asset(fileMetaData['fileIcon']!),
      );
    }

    if (controller.whiteLabelResponse.isLoading) {
      return Container(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.whiteLabelResponse.isLoaded &&
        controller.whiteLabelCreativeBytes != null) {
      /// Loading an image from a file creates an in memory copy of the file,
      /// which is retained in the [ImageCache]. The underlying file is not
      /// monitored for changes. If it does change, the application should evict
      /// the entry from the [ImageCache]
      return Image.memory(
        controller.whiteLabelCreativeBytes!,
        fit: BoxFit.contain,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: 'https://${creative.url}',
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildResourceThumbnail(AppResourcesController controller) {
    final targetList = controller.activeList;

    if (targetList.isEmpty || controller.currentIndex >= targetList.length) {
      return Container(
        height: 60,
        child: Center(
          child: Text('No creative available'),
        ),
      );
    }
    final resource = targetList[controller.currentIndex];

    return CachedNetworkImage(
      imageUrl: resource.thumbnailUrl.isNotNullOrBlank
          ? 'https://${resource.thumbnailUrl}'
          : '',
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) {
        final fileMetaData = getFileMetaData('https://${resource.url!}');
        return Image.asset(fileMetaData['fileIcon']!);
      },
      placeholder: (context, url) {
        return Container(
          color: Color(0xFFF0F0F0),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
