import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/notification_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/notifications/models/notifications_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

@RoutePage()
class DescriptionHtmlScreen extends StatelessWidget {
  const DescriptionHtmlScreen({
    super.key,
    required this.notification,
  });

  final DataNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: ''),
      backgroundColor: ColorConstants.white,
      body: GetBuilder<NotificationController>(
        id: 'description',
        builder: (controller) {
          if (controller.notificationDescriptionHtmlResponse.state ==
              NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorConstants.primaryAppColor,
              ),
            );
          }

          if (controller.notificationDescriptionHtmlResponse.state ==
              NetworkState.error) {
            return RetryWidget(
              controller.notificationDescriptionHtmlResponse.message,
              onPressed: () {
                controller.getNotificationDescriptionHtml(notification);
              },
            );
          }

          if (controller.notificationDescriptionHtmlResponse.state ==
                  NetworkState.loaded &&
              controller.descriptionHtml.isNullOrEmpty) {
            return EmptyScreen(
              message: "Content not found",
            );
          }

          if (controller.notificationDescriptionHtmlResponse.state ==
                  NetworkState.loaded &&
              controller.descriptionHtml.isNotNullOrEmpty) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: HtmlWidget(
                controller.descriptionHtml!,
                // htmlData,
                onTapUrl: (url) {
                  print('url==>$url');
                  if (url.isNotNullOrEmpty) {
                    AutoRouter.of(context).push(VideoRoute(videoUrl: url));
                  }
                  return true;
                },
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
