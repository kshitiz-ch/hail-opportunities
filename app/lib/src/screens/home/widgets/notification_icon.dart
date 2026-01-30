import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/notification_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      id: GetxId.notificationCount,
      builder: (NotificationController notificationController) {
        final notificationCount =
            (notificationController.notificationsCountModel?.count ?? 0);

        return InkWell(
          onTap: () {
            MixPanelAnalytics.trackWithAgentId("notification", properties: {
              "screen_location": "home_header",
              "screen": "Home"
            });
            AutoRouter.of(context).push(NotificationRoute());
          },
          child: Stack(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    AllImages().notificationIcon,
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              (notificationCount > 0)
                  ? Positioned(
                      right: 8,
                      top: 5,
                      child: Container(
                        // height: 15,
                        // width: 15,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Color(0xFFff8b8b),
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(
                          //   40,
                          // ),
                        ),
                        child: Center(
                          child: Text(
                            notificationCount.toString(),
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
