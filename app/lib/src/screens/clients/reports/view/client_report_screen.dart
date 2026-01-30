import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/generate_report_bottomsheet.dart';
import 'package:app/src/screens/clients/reports/widgets/report_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientReportScreen extends StatelessWidget {
  final String displayName;
  final int templateIndex;

  const ClientReportScreen(
      {Key? key, required this.displayName, required this.templateIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: displayName),
      body: GetBuilder<ClientReportController>(
        builder: (ClientReportController controller) {
          if (controller.reportList.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.reportList.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.reportList.message,
                onPressed: () {
                  controller.getClientReportList(
                    controller.reportTemplateList![templateIndex].name!,
                  );
                },
              ),
            );
          }
          if (controller.reportList.state == NetworkState.loaded) {
            if (controller.reportModelList.isNullOrEmpty) {
              return _buildEmptyScreen(controller.client.name ?? '', context);
            }
            return ListView.separated(
              padding: EdgeInsets.only(bottom: 100),
              itemBuilder: (BuildContext context, int index) {
                return ReportCard(
                  reportIndex: index,
                  templateIndex: templateIndex,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 20);
              },
              itemCount: controller.reportModelList.length,
            );
          }

          return SizedBox();
        },
      ),
      floatingActionButton: _buildGenerateReportButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildGenerateReportButton(BuildContext context) {
    return GetBuilder<ClientReportController>(
      builder: (ClientReportController controller) {
        return ActionButton(
          text: 'Generate Report',
          onPressed: () {
            controller.initInputFields();
            CommonUI.showBottomSheet(
              context,
              child: GenerateReportBottomSheet(
                reportTemplateModel:
                    controller.reportTemplateList![templateIndex],
              ),
            );
          },
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        );
      },
    );
  }

  Widget _buildEmptyScreen(String clientName, BuildContext context) {
    return EmptyScreen(
      imagePath: AllImages().clientNoReportIcon,
      customWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No Reports Found',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Seems like you do not have any reports generated for $clientName yet. Tap to Generate Holding report now',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
