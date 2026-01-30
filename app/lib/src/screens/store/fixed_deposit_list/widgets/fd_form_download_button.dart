import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class FDFormDownloadButton extends StatelessWidget {
  final String? pdfUrl;
  final FixedDepositsController fixedDepositsController =
      Get.find<FixedDepositsController>();

  FDFormDownloadButton({Key? key, this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      tag: 'fd',
      builder: (downloadController) {
        return InkWell(
          onTap: () {
            if (pdfUrl.isNotNullOrEmpty) {
              if (isDownloadableUrl(pdfUrl!)) {
                downloadAsset(pdfUrl);
              } else {
                launch(pdfUrl!);
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: ColorConstants.secondaryAppColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Form',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.primaryAppColor,
                      ),
                ),
                SizedBox(width: 8),
                SvgPicture.asset(
                  AllImages().downloadIcon,
                  width: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void downloadAsset(String? downloadUrl) async {
    DownloadController downloadController =
        Get.find<DownloadController>(tag: 'fd');
    final fileName = getFileName(downloadUrl!);
    String fileExt = fileName.substring(fileName.lastIndexOf('.'));

    downloadController.downloadFile(
      url: downloadUrl,
      filename: fileName,
      extension: fileExt,
    );
  }
}
