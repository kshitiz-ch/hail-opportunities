import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/report_template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// class SelectTypeBottomSheet extends StatefulWidget {
//   SelectTypeBottomSheet({Key? key, required this.preSelectedReportTemplate})
//       : super(key: key);

//   final ReportTemplateModel? preSelectedReportTemplate;

//   @override
//   State<SelectTypeBottomSheet> createState() => _SelectTypeBottomSheetState();
// }

class SelectTypeBottomSheet extends StatelessWidget {
  SelectTypeBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      id: GetxId.form,
      builder: (controller) {
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
                      'Choose Report Type',
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
              _buildTypeOptions(controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeOptions(ReportController controller) {
    bool isFirstTemplateFamily = controller
            .selectedReportTemplateGroup!.reportTemplates.first.reportCategory
            ?.toLowerCase() ==
        "f";
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        itemCount:
            controller.selectedReportTemplateGroup!.reportTemplates.length,
        shrinkWrap: true,
        // If first template is [Family] option, then reverse it so
        // [Individual] shows first
        reverse: isFirstTemplateFamily,
        itemBuilder: (context, index) {
          ReportTemplateModel reportTemplate =
              controller.selectedReportTemplateGroup!.reportTemplates[index];
          if (reportTemplate.reportCategory.isNullOrEmpty) {
            return SizedBox();
          }

          return _buildTypeTile(
            context,
            controller,
            reportTemplate: reportTemplate,
          );
        },
      ),
    );
  }

  Widget _buildTypeTile(BuildContext context, ReportController controller,
      {required ReportTemplateModel reportTemplate
      // required IconData icon,
      // required ReportCategory type,
      }) {
    bool isSelected = controller.selectedReportTemplate == reportTemplate;
    String reportCategory = reportTemplate.reportCategory ?? '';

    return InkWell(
      onTap: () {
        String? groupName =
            (controller.selectedReportTemplateGroup?.groupName ?? '')
                .toSnakeCase();
        MixPanelAnalytics.trackWithAgentId(
          "report_type_selected",
          screen: groupName,
          screenLocation: groupName,
          properties: {
            "report_type": reportTemplate.displayName,
          },
        );

        controller.updateSelectedReportTemplate(reportTemplate);
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
                reportCategory.toLowerCase() == "i"
                    ? Icons.person
                    : reportCategory.toLowerCase() == "f"
                        ? Icons.groups
                        : Icons.file_copy,
                color: ColorConstants.black,
                size: 16,
              ),
            SizedBox(width: 8),
            Text(
              reportTemplate.reportCategoryDescription,
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
