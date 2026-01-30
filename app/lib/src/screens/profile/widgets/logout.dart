import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Logout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30).copyWith(top: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 34),
            child: Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.black,
                        fontSize: 18,
                        height: 24 / 14,
                      ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                text: 'Cancel',
                onPressed: () {
                  AutoRouter.of(context).popForced();
                },
                bgColor: ColorConstants.secondaryAppColor,
                borderRadius: 51,
                margin: EdgeInsets.zero,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16,
                        ),
              ),
              SizedBox(
                width: 12,
              ),
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                text: 'Confirm',
                onPressed: () async {
                  // Delete Recent Clients List
                  try {
                    final directory = await getApplicationDocumentsDirectory();
                    final path = directory.path;
                    await File('$path/recent_clients.json').delete();
                  } catch (error) {
                    LogUtil.printLog("error====$error");
                  }

                  AuthenticationBlocController()
                      .authenticationBloc
                      .add(UserLogOut());
                },
                borderRadius: 51,
                margin: EdgeInsets.zero,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.white,
                          fontSize: 16,
                        ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
