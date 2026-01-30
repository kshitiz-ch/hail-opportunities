import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/report_template_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportTemplateSection extends StatelessWidget {
  const ReportTemplateSection({Key? key, this.client}) : super(key: key);

  final Client? client;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      init: ReportController(selectedClient: client),
      id: GetxId.contentList,
      autoRemove: client == null,
      builder: (controller) {
        if (controller.reportTemplatesResponse.state == NetworkState.loading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.reportTemplatesResponse.state == NetworkState.loaded) {
          List<MapEntry<String, ReportTemplateGroupModel>>
              reportTemplateGroups =
              controller.reportTemplateGroups.entries.toList();
          return GridView.count(
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(
              reportTemplateGroups.length,
              (index) {
                MapEntry<String, ReportTemplateGroupModel> reportTemplateGroup =
                    reportTemplateGroups[index];
                return InkWell(
                  onTap: () {
                    controller.resetForm();
                    controller.updateSelectedReportTemplateGroup(
                        reportTemplateGroup.value);
                    if (reportTemplateGroup.value.reportTemplates.isNotEmpty) {
                      List<ReportTemplateModel> reporTemplates =
                          reportTemplateGroup.value.reportTemplates;

                      bool isIndividualTemplatePresent = false;
                      for (ReportTemplateModel template in reporTemplates) {
                        if (template.reportCategory?.toLowerCase() == "i") {
                          isIndividualTemplatePresent = true;
                          controller.updateSelectedReportTemplate(template);
                          break;
                        }
                      }

                      if (!isIndividualTemplatePresent) {
                        controller.updateSelectedReportTemplate(
                            reportTemplateGroup.value.reportTemplates.first);
                      }

                      controller.updateSelectedFileFormat(reportTemplateGroup
                          .value.reportTemplates.first.reportTypeList.first);
                    }

                    if (reportTemplateGroup.key ==
                        "Tracker Investment AI Report") {
                      if (client != null) {
                        AutoRouter.of(context).push(
                          PortfolioReviewRoute(
                            client: client!.toNewClientModel(),
                          ),
                        );
                      } else {
                        AutoRouter.of(context).push(ChooseClientRoute());
                      }
                    } else {
                      AutoRouter.of(context).push(ReportFormRoute());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorConstants.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          getReportIcon(reportTemplateGroup.key),
                          // AllImages().clientReportIcon,
                          height: 24,
                          // width: 26,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reportTemplateGroup.value.groupName ?? '-',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Text('Report Templates not Found');
      },
    );
  }
}
