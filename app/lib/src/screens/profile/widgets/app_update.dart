import 'dart:ui' as ui;

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/common/app_update_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppUpdate extends StatelessWidget {
  final String? appVersion;

  const AppUpdate({Key? key, this.appVersion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppUpdateController>(
        init: AppUpdateController()..checkForUpdate(context),
        builder: (updateController) {
          return Column(
            children: [
              SizedBox(
                height: 16,
              ),
              if (appVersion != null)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'App Version ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                      TextSpan(
                        text: 'V${appVersion ?? ''}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.black,
                            ),
                      )
                    ],
                  ),
                ),
              if (updateController.isUpdateAvailable &&
                  updateController.availableVersion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: ui.PlaceholderAlignment.top,
                          child: ClickableText(
                            text: 'Update'.toUpperCase(),
                            onClick: () {
                              if (updateController.isUpdateAvailable) {
                                updateController.updateVersion(context);
                              }
                            },
                          ),
                        ),
                        TextSpan(
                          text: '(v${updateController.availableVersion})',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleMedium!
                              .copyWith(
                                color: ColorConstants.black,
                              ),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
  }
}
