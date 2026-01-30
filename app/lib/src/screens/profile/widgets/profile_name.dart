import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/widgets/partner_name_update_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileName extends StatelessWidget {
  const ProfileName({Key? key, required this.profileName}) : super(key: key);

  final String? profileName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: "name",
      builder: (controller) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profileName ?? '',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.darkCharcoalColor,
                      ),
            ),
            SizedBox(width: 4),
            ClickableText(
              text: 'Edit',
              fontSize: 12,
              onClick: () {
                MixPanelAnalytics.trackWithAgentId(
                  "edit_name",
                  screen: 'partner_profile',
                  screenLocation: 'partner_profile',
                );
                AutoRouter.of(context).push(
                  ChangeDisplayNameRoute(
                    currentDisplayName:
                        controller.advisorOverview?.agent?.displayName,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
