import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/business_report_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/report/business_report/widgets/download_revenue_sheet_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class BusinessReportTemplateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      init: BusinessReportController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildTemplateListing(context, controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(maxHeight: 270),
          decoration: BoxDecoration(
            color: Color(0xffCA5EF4),
            image: DecorationImage(
              image: AssetImage(AllImages().businessReportBg),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 5),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    AutoRouter.of(context).popForced();
                  },
                  child: Image.asset(
                    AllImages().appBackIcon,
                    color: Colors.white,
                    height: 32,
                    width: 32,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'My Business Reports',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Reports',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
              ),
              SizedBox(height: 8),
              Text(
                'You can download following reports for yourself.\nClick on a report to start',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: Colors.white),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTemplateListing(
    BuildContext context,
    BusinessReportController controller,
  ) {
    if (controller.agentReportTemplateResponse.state == NetworkState.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (controller.agentReportTemplateResponse.state == NetworkState.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: RetryWidget(
            controller.agentReportTemplateResponse.message,
            onPressed: () {
              controller.getAgentReportTemplates();
            },
          ),
        ),
      );
    }
    if (controller.agentReportTemplateResponse.state == NetworkState.loaded) {
      if (controller.agentReportTemplateList.isNullOrEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: EmptyScreen(message: 'No Business Report Template Found'),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(
            controller.agentReportTemplateList.length,
            (index) {
              final template = controller.agentReportTemplateList[index];
              return InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    template.name ?? '',
                    screen: 'business_report',
                    screenLocation: 'business_report',
                  );

                  if (template.name == 'REVENUE-SHEET') {
                    CommonUI.showBottomSheet(
                      context,
                      child: DownloadRevenueSheetBottomSheet(),
                    );
                  } else {
                    controller.selectedAgentReportTemplate = template;
                    controller.getAgentReport();
                    AutoRouter.of(context).push(BusinessReportGenerateRoute());
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
                        getBusinessReportTemplateIcon(template.name!),
                        height: 24,
                        // width: 26,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          template.displayName ?? '-',
                          maxLines: 3,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return SizedBox();
  }
}
