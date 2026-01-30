import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/report_form_section.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/report_template_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenerateReportBottomSheet extends StatelessWidget {
  final ReportTemplateModel reportTemplateModel;
  late ReportDateType inputType;

  GenerateReportBottomSheet({Key? key, required this.reportTemplateModel})
      : super(key: key) {
    inputType = getInputType(reportTemplateModel.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientReportController>(
      builder: (controller) {
        String subtitle = getReportInputTitle(inputType);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 8),
                child: Text(
                  'Generate ${reportTemplateModel.displayName}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                subtitle,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w500,
                        ),
              ),
              if (inputType != ReportDateType.None)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: ReportFormSection(inputType: inputType),
                ),
              _buildGenerateReportButton(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenerateReportButton(
      BuildContext context, ClientReportController controller) {
    return ActionButton(
      text: 'Generate Report',
      onPressed: () async {
        if (inputType == ReportDateType.IntervalDate) {
          if (controller.investmentDate1!
              .isAfter(controller.investmentDate2!)) {
            showToast(text: 'From date should be before after date');
            return;
          }
        }
        await controller.createClientReport(
          templateName: reportTemplateModel.name!,
          inputType: inputType,
        );
        if (controller.createReport.state == NetworkState.loaded) {
          controller.getClientReportList(reportTemplateModel.name!);
        }
        if (controller.createReport.state == NetworkState.error) {
          showToast(text: controller.createReport.message);
        }
        AutoRouter.of(context).popForced();
      },
      showProgressIndicator:
          controller.createReport.state == NetworkState.loading,
      isDisabled: !isValid(controller),
      margin: EdgeInsets.symmetric(vertical: 24),
    );
  }

  bool isValid(ClientReportController controller) {
    if (inputType == ReportDateType.IntervalDate) {
      return controller.investmentDate1Controller!.text.isNotNullOrEmpty &&
          controller.investmentDate2Controller!.text.isNotNullOrEmpty;
    }
    if (inputType == ReportDateType.SingleDate) {
      return controller.investmentDate1Controller!.text.isNotNullOrEmpty;
    }
    if (inputType == ReportDateType.SingleYear) {
      return controller.financialYear.isNotNullOrEmpty;
    }
    return true;
  }
}
