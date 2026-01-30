import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/business_report_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/report/business_report/widgets/business_report_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class BusinessReportGenerateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText:
                controller.selectedAgentReportTemplate?.displayName ?? '',
          ),
          body: _buildBody(context, controller),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            isDisabled:
                controller.agentReportResponse.state != NetworkState.loaded,
            showProgressIndicator:
                controller.createReportResponse.state == NetworkState.loading,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            text: 'Generate New Report',
            onPressed: () {
              MixPanelAnalytics.trackWithAgentId(
                "generate_new_report",
                screen: 'business_report',
                screenLocation:
                    (controller.selectedAgentReportTemplate?.displayName ?? '')
                        .toLowerCase()
                        .split(" ")
                        .join("-"),
              );

              onGeneratedReport(controller);
            },
          ),
        );
      },
    );
  }

  Future<void> onGeneratedReport(BusinessReportController controller) async {
    showToast(text: 'Generating Report...');
    await controller.createAgentReport();
    if (controller.createReportResponse.state == NetworkState.error) {
      showToast(text: controller.agentReportResponse.message);
    }
    if (controller.createReportResponse.state == NetworkState.loaded) {
      if (controller.isReportGenerated == true) {
        showToast(text: 'Report Generated Sucessfully');
        controller.getAgentReport();
      } else {
        showToast(text: 'Report Not Generated. Please try again');
      }
    }
  }

  Widget _buildBody(BuildContext context, BusinessReportController controller) {
    if (controller.agentReportResponse.state == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.agentReportResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          controller.agentReportResponse.message,
          onPressed: () {
            controller.getAgentReport();
          },
        ),
      );
    }
    if (controller.agentReportResponse.state == NetworkState.loaded) {
      if (controller.selectedTemplateReport == null) {
        return Center(
          child: EmptyScreen(message: 'No Reports Found'),
        );
      }
      // show only last report
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BusinessReportCard(),
      );
    }
    return SizedBox();
  }
}
