import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/screens/commons/delete_partner/delete_partner.dart';
import 'package:app/src/screens/profile/widgets/app_update.dart';
import 'package:app/src/screens/profile/widgets/logout.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_advisor_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:app/src/utils/size_utils.dart';

class ProfileFooter extends StatelessWidget {
  final String? appVersion;

  const ProfileFooter({
    Key? key,
    this.appVersion,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          child: ActionButton(
            bgColor: ColorConstants.lightRedColor,
            height: 42,
            borderRadius: 8,
            margin: EdgeInsets.only(top: 16),
            text: 'Log Out',
            textStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.errorColor,
                    ),
            onPressed: () {
              MixPanelAnalytics.trackWithAgentId(
                "logout",
                screen: 'partner_profile',
                screenLocation: 'partner_profile',
              );
              CommonUI.showBottomSheet(
                context,
                child: Logout(),
              );
            },
          ),
        ),
        AppUpdate(
          appVersion: appVersion,
        ),
        DeletePartner(),
        CommonAdvisorUI.buildWealthyArnDetails(context),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
