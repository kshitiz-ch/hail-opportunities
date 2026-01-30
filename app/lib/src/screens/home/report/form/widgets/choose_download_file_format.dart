import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// class ChooseDownloadFileFormat extends StatefulWidget {
//   const ChooseDownloadFileFormat(
//       {Key? key, required this.preSelectedFileFormat})
//       : super(key: key);

//   final String? preSelectedFileFormat;

//   @override
//   State<ChooseDownloadFileFormat> createState() =>
//       _ChooseDownloadFileFormatState();
// }

class ChooseDownloadFileFormat extends StatelessWidget {
  // String? fileFormat;

  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback(
  //     (_) => {
  //       setState(() {
  //         fileFormat = widget.preSelectedFileFormat;
  //       })
  //     },
  //   );
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      id: GetxId.form,
      builder: (controller) {
        final reportTypeList =
            controller.selectedReportTemplate?.reportTypeList ?? [];
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Download File Format',
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
              Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  itemCount: reportTypeList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final fileFormat = reportTypeList[index];

                    return _buildTypeTile(
                      context,
                      controller,
                      fileFormat: fileFormat,
                    );
                  },
                ),
              ),
              // SimpleDropdownFormField(
              //   hintText: 'File Format',
              //   dropdownMaxHeight: 500,
              //   items: (controller.selectedReportTemplate?.reportType ?? '')
              //       .split(',')
              //       .toList(),
              //   value: controller.selectedFileFormat,
              //   contentPadding: EdgeInsets.only(bottom: 8),
              //   borderColor: ColorConstants.lightGrey,
              //   style: textStyle,
              //   labelStyle: hintStyle,
              //   hintStyle: hintStyle,
              //   borderRadius: 15,
              //   label: 'File Format',
              //   onChanged: (val) {
              //     fileFormat = val;
              //   },
              // ),
              // Padding(
              //   padding: EdgeInsets.only(top: 30),
              //   child: ActionButton(
              //     margin: EdgeInsets.zero,
              //     text: 'Save',
              //     isDisabled: fileFormat == null,
              //     onPressed: () {
              //       controller.updateSelectedFileFormat(fileFormat);
              //       AutoRouter.of(context).popForced();
              //     },
              //   ),
              // )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeTile(BuildContext context, ReportController controller,
      {required String fileFormat
      // required IconData icon,
      // required ReportCategory type,
      }) {
    bool isSelected = controller.selectedFileFormat == fileFormat;

    return InkWell(
      onTap: () {
        String groupName =
            (controller.selectedReportTemplateGroup?.groupName ?? '')
                .toLowerCase()
                .split(" ")
                .join("-");
        MixPanelAnalytics.trackWithAgentId(
          "file_format_selected",
          screen: groupName,
          screenLocation: 'file_format',
          properties: {
            "file_format": fileFormat,
          },
        );

        controller.updateSelectedFileFormat(fileFormat);
        AutoRouter.of(context).popForced();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSelected)
              SvgPicture.asset(
                AllImages().verifiedRoundedIcon,
                width: 16,
              )
            else
              Icon(
                Icons.file_copy,
                color: ColorConstants.black,
                size: 16,
              ),
            SizedBox(width: 8),
            Text(
              fileFormat,
              style: Theme.of(context).primaryTextTheme.headlineMedium!,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: ColorConstants.primaryAppColor,
                size: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
