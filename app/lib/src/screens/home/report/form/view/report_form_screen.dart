import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/choose_download_file_format.dart';
import '../widgets/date_selector_bottomsheet.dart';
import '../widgets/select_type_bottomsheet.dart';

@RoutePage()
class ReportFormScreen extends StatelessWidget {
  final reportController = Get.find<ReportController>();

  ReportFormScreen({Key? key}) : super(key: key) {
    if (reportController.isSoaFolioReport) {
      Get.put(SOADownloadController(), tag: reportController.soaControllerTag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      id: GetxId.form,
      initState: (_) {
        try {
          String? templateName = reportController
              .selectedReportTemplateGroup?.groupName!
              .toLowerCase()
              .split("")
              .join("_");
          if (templateName != null) {
            MixPanelAnalytics.trackWithAgentId(
              templateName,
              screen: 'client report',
              screenLocation: 'client report',
            );
          }
        } catch (error) {
          LogUtil.printLog(error);
        }
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: controller.selectedReportTemplateGroup?.groupName ?? '-',
            // subtitleText: controller.selectedReportTemplate?.description,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                if (!controller.disableSelectClient)
                  _buildDropdown(
                    context,
                    label: 'Choose Client',
                    imagePath: AllImages().userOutline,
                    value: controller.selectedClient?.name,
                    onTap: () {
                      if (controller.disableSelectClient) {
                        return;
                      }

                      AutoRouter.of(context).push(
                        SelectClientRoute(
                          showClientFamilyList: false,
                          showSearchContactSwitch: false,
                          showAddNewClient: false,
                          skipSelectClientConfirmation: true,
                          onClientSelected: (Client? client, _) {
                            controller.updateSelectedClient(client!);
                            AutoRouter.of(context).popForced();
                          },
                        ),
                      );
                    },
                  ),
                if (controller.selectedClient != null)
                  Column(
                    children: [
                      _buildDropdown(
                        context,
                        label: 'Choose Report Type',
                        imagePath: AllImages().filesOutline,
                        value: controller
                            .selectedReportTemplate?.reportCategoryDescription,
                        onTap: () {
                          CommonUI.showBottomSheet(
                            context,
                            child: SelectTypeBottomSheet(),
                          );
                        },
                      ),
                      if (controller.dateType != ReportDateType.None)
                        _buildDropdown(
                          context,
                          label:
                              controller.dateType == ReportDateType.SingleDate
                                  ? 'Choose investment date'
                                  : controller.dateType ==
                                          ReportDateType.IntervalDate
                                      ? 'Choose Interval'
                                      : controller.dateType ==
                                              ReportDateType.SingleYear
                                          ? 'Choose Financial year'
                                          : 'Choose Date',
                          value: _getDateValue(controller),
                          imagePath: AllImages().calendarOutline,
                          onTap: () async {
                            CommonUI.showBottomSheet(
                              context,
                              child: DateSelectorBottomSheet(
                                  controller: controller),
                            );
                          },
                        ),
                      if (controller.selectedReportTemplate?.reportType
                              .isNotNullOrEmpty ??
                          false)
                        _buildDropdown(
                          context,
                          label: 'Choose File Format',
                          value: (controller.selectedFileFormat ?? '')
                              .toUpperCase(),
                          imagePath: AllImages().filesOutline,
                          onTap: () async {
                            CommonUI.showBottomSheet(
                              context,
                              child: ChooseDownloadFileFormat(),
                            );
                          },
                        ),
                      if (controller.isSoaFolioReport)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: GetBuilder<SOADownloadController>(
                            tag: controller.soaControllerTag,
                            builder: (soaController) {
                              return _buildDropdown(
                                context,
                                label: 'Select Folio Number',
                                imagePath: AllImages().soaFolioIcon,
                                value: controller.folioNumber,
                                onTap: () {
                                  if (controller.selectedClient == null) {
                                    return showToast(
                                        text: 'Please select the Client');
                                  } else {
                                    soaController.selectedClient =
                                        controller.selectedClient;
                                    soaController.amcSearchController.clear();
                                    soaController.getSoaFolioList();
                                    AutoRouter.of(context).push(
                                      SoaFolioListRoute(
                                        tag: controller.soaControllerTag,
                                        onDone: () async {
                                          controller.folioNumber = soaController
                                              .selectedFolio?.folioNumber;
                                          controller.update();
                                          soaController.update();
                                          AutoRouter.of(context).popForced();
                                        },
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  )
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionButton(
                  isDisabled: !controller.isFormValid,
                  text: 'Generate Report',
                  onPressed: () {
                    String groupName =
                        (controller.selectedReportTemplateGroup?.groupName ??
                                '')
                            .toLowerCase()
                            .split(" ")
                            .join("-");
                    MixPanelAnalytics.trackWithAgentId(
                      "generate_report",
                      screen: groupName,
                      screenLocation: groupName,
                    );

                    controller.createClientReport();
                    AutoRouter.of(context).push(ReportDownloadRoute());
                  },
                ),
                // SizedBox(height: 25),
                // ClickableText(
                //   text: 'Email Report to Client',
                // )
              ],
            ),
          ),
        );
      },
    );
  }

  String? _getDateValue(ReportController controller) {
    if (controller.dateType == ReportDateType.SingleYear &&
        controller.financialYear != null) {
      return controller.financialYear;
    }

    if (controller.dateType == ReportDateType.SingleDate &&
        controller.investmentDate1 != null) {
      return DateFormat('dd MMM yyyy').format(controller.investmentDate1!);
    }

    if (controller.dateType == ReportDateType.IntervalDate &&
        controller.investmentDate1 != null &&
        controller.investmentDate2 != null) {
      return '${DateFormat('dd MMM yyyy').format(controller.investmentDate1!)} - ${DateFormat('dd MMM yyyy').format(controller.investmentDate2!)}';
    }

    return null;
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String imagePath,
    required void Function() onTap,
    String? value,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (value.isNullOrEmpty)
              Image.asset(
                imagePath,
                width: 20,
              )
            else
              SvgPicture.asset(
                AllImages().verifiedRoundedIcon,
                width: 20,
              ),
            SizedBox(width: 6),
            if (value.isNullOrEmpty)
              Text(
                label,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            Spacer(),
            Image.asset(
              AllImages().downArrow,
              width: 16,
            ),
          ],
        ),
      ),
    );
  }
}
