import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_report_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsSection extends StatelessWidget {
  final Client client;

  const ReportsSection({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientReportController>(
      init: ClientReportController(client),
      builder: (ClientReportController controller) {
        if (controller.reportTemplate.state == NetworkState.loading) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.reportTemplate.state == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.reportTemplate.message,
                onPressed: () {
                  controller.getClientReportTemplates();
                },
              ),
            ),
          );
        }
        if (controller.reportTemplateList.isNullOrEmpty) {
          return Center(
            child: EmptyScreen(
              message: 'No Report Template found for the client',
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraint) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SingleChildScrollView(
                child: Wrap(
                  children: List<Widget>.generate(
                    controller.reportTemplateList!.length,
                    (index) {
                      final displayName =
                          controller.reportTemplateList![index].displayName ??
                              '';
                      return InkWell(
                        onTap: () {
                          controller.getClientReportList(
                              controller.reportTemplateList![index].name!);
                          AutoRouter.of(context).push(
                            ClientReportRoute(
                              displayName: displayName,
                              templateIndex: index,
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 50),
                          width: constraint.maxWidth / 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AllImages().clientReportIcon,
                                height: 26,
                                width: 26,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5)
                                        .copyWith(top: 10),
                                child: Text(
                                  displayName,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: ColorConstants.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
