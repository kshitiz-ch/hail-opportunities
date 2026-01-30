import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/common/notification_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/times_ago.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/notifications/models/notifications_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

@RoutePage()
class NotificationScreen extends StatefulWidget {
  final bool fromPushNotification;

  NotificationScreen({this.fromPushNotification = false});
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();

    notificationController = Get.find<NotificationController>();
    notificationController.getNotifications();
    notificationController.resetNotificationUnReadCount();
  }

  Future<void> _refreshData() async {
    notificationController.getNotificationModelData();
  }

  void goBackHandler() {
    AutoRouter.of(context).popUntilRouteWithName(BaseRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Notifications',
      ),
      body: GetBuilder<NotificationController>(
          id: GetxId.notificationData,
          builder: (NotificationController controller) {
            if (controller.notificationsDataResponse.state ==
                    NetworkState.loading &&
                !controller.isPaginating) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.notificationsDataResponse.state ==
                NetworkState.error) {
              return Center(
                child: RetryWidget(
                  controller.notificationsDataResponse.message,
                  onPressed: controller.getNotifications,
                ),
              );
            }

            if (controller.notificationsDataResponse.state ==
                    NetworkState.loaded &&
                controller.notifications.isEmpty) {
              return Center(
                child: EmptyScreen(
                  message: 'No Notifications',
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.notifications.length,
                      shrinkWrap: true,
                      controller: controller.scrollController,
                      separatorBuilder: (context, index) {
                        DataNotificationModel notification =
                            controller.notifications[index];

                        if (notification.notificationUIModel == null) {
                          return SizedBox();
                        }

                        return SizedBox();
                      },
                      itemBuilder: (context, index) {
                        DataNotificationModel notification =
                            controller.notifications[index];

                        if (notification.notificationUIModel == null) {
                          return SizedBox();
                        }

                        if (notification.dnRenderType == "image") {
                          if (notification.summary!.contains("http")) {
                            return Image.network(notification.summary ?? "");
                          } else {
                            return SizedBox();
                          }
                        }

                        return _buildNotificationCard(
                          notification: notification,
                          controller: controller,
                          onDismiss: () {
                            onDismiss(notification, controller, index);
                          },
                        );
                      },
                    ),
                  ),
                  if (controller.isPaginating) CommonUI.infinityLoader()
                ],
              ),
            );
          }),
    );
  }

  Widget _buildNotificationCard({
    required DataNotificationModel notification,
    required NotificationController controller,
    required Function onDismiss,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead == true ? Color(0xffF7F4FE) : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 10, 12),
      child: InkWell(
        onTap: () {
          controller.markNotificationRead(notification);
          if (notification.descriptionHtmlId.isNotNullOrEmpty) {
            controller.getNotificationDescriptionHtml(notification);
            AutoRouter.of(context)
                .push(DescriptionHtmlRoute(notification: notification));
          } else if (notification.ntype.isNotNullOrEmpty) {
            RemoteMessage message = RemoteMessage(
              data: {
                'ntype': notification.ntype,
                'wcontext': notification.attrs
              },
            );
            PageRouteInfo? routeToNavigate = Get.find<NavigationController>()
                .pushNotificationHandler(message);

            final moduleName =
                getModuleName(routeName: routeToNavigate?.routeName ?? '');

            if (routeToNavigate != null) {
              MixPanelAnalytics.trackWithAgentId(
                "page_viewed",
                properties: {
                  "page_name": convertRouteToPageName(
                    routeToNavigate.routeName,
                    ntype: notification.ntype,
                  ),
                  if (moduleName.isNotNullOrEmpty) "module_name": moduleName,
                  "source": "Notification",
                  'ntype': notification.ntype,
                  ...getDefaultMixPanelFields(routeToNavigate.routeName),
                },
              );
              AutoRouter.of(context).push(routeToNavigate);
            }
          }
          // navigation
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(
                  notification.notificationUIModel!.imageSrc!,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notification.notificationUIModel!.headerText ?? '',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Center(
                  child: _buildLeadingIcon(
                    notification: notification,
                    onDismiss: () {
                      onDismiss();
                    },
                  ),
                ),
              ],
            ),
            if (notification
                .notificationUIModel!.descriptionText.isNotNullOrEmpty)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  '${notification.notificationUIModel!.descriptionText ?? ''}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500),
                ),
              ),
            if (notification.createdAt != null ||
                notification.expiryTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    if (notification.createdAt != null)
                      Text(
                        notificationDateFormat(
                          notification.createdAt!,
                        ),
                        style: context.titleLarge!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                        ),
                      ),
                    if (expiryDateFormat(notification.expiryTime) != null)
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Expiring in ${expiryDateFormat(notification.expiryTime)}',
                          style: context.titleLarge!.copyWith(
                            color: ColorConstants.secondaryRedAccentColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon({
    required DataNotificationModel notification,
    required Function onDismiss,
  }) {
    if (notification.isRead == false) {
      return Container(
        margin: EdgeInsets.only(left: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: hexToColor("#F8F7F7"),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Text(
          'Unread',
          style:
              context.titleLarge!.copyWith(color: ColorConstants.tertiaryBlack),
        ),
      );
    } else if (notification.isRead == true &&
        notification.isDismissible == true) {
      return InkWell(
        onTap: () {
          onDismiss();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 119, 119, 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                AllImages().deleteIcon,
                height: 16,
                width: 16,
                // fit: BoxFit.fitWidth,
              ),
            ),
            // Text(
            //   ' Delete',
            //   style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            //         color: ColorConstants.tertiaryBlack,
            //       ),
            // )
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildImage(String src) {
    if (src.isNotNullOrEmpty) {
      if (src.endsWith('svg')) {
        return SvgPicture.network(
          src,
          height: 24,
          width: 24,
          alignment: Alignment.center,
        );
      }
      return Image.network(
        src,
        height: 24,
        width: 24,
        alignment: Alignment.center,
        errorBuilder: (cxt, obj, stack) {
          return Image.asset(
            AllImages().notificationPlaceholderIcon,
            height: 24,
            width: 24,
            alignment: Alignment.center,
          );
        },
      );
    }
    return Image.asset(
      AllImages().notificationPlaceholderIcon,
      height: 24,
      width: 24,
      alignment: Alignment.center,
    );
  }

  void onDismiss(
    DataNotificationModel notification,
    NotificationController controller,
    int index,
  ) {
    final isNotDismissable =
        notification.groupDn == true || notification.isDismissible == false;
    if (isNotDismissable) {
      return showToast(text: "This notification cannot be removed");
    }

    // Remove item from list and update UI immediately
    controller.notifications.removeAt(index);
    controller.update([GetxId.notificationData]);

    // Then handle background operations
    controller.dismissDataNotification(notification);
    showToast(text: "Notification Removed");
  }
}
