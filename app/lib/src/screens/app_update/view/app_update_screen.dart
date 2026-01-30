import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/app_update_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

@RoutePage()
class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({Key? key, this.releaseNotes}) : super(key: key);

  final String? releaseNotes;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppUpdateController>(
      init: AppUpdateController()..checkForUpdate(context),
      dispose: (_) {
        if (Get.isRegistered<AppUpdateController>()) {
          Get.delete<AppUpdateController>();
        }
      },
      builder: (controller) {
        return PopScope(
          onPopInvoked: (_) {
            showToast(
              context: context,
              text: "Please update the app to continue",
            );
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AllImages().appUpdateNotficationIcon,
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Update Available',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontSize: 20,
                            color: ColorConstants.black,
                          ),
                    ),
                    if (controller.availableVersion.isNotNullOrEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'A New version of wealthy (${controller.availableVersion ?? ''}) is available. \nPlease update your app to enjoy these updates.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                    if (releaseNotes.isNotNullOrEmpty)
                      _buildReleaseNotes(context)
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ActionButton(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              text: 'Update Now',
              onPressed: () async {
                await updateApp(context, fromAppUpdateScreen: true);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildReleaseNotes(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 50),
          child: HtmlWidget(
            releaseNotes!,
            customWidgetBuilder: (element) {
              if (element.localName == "li") {
                return Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bulletPointUnicode  ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                                height: 18 / 12),
                      ),
                      Expanded(
                        child: Text(
                          element.text,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return null;
            },
            // webViewJs: false,
            textStyle: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                    height: 1.5),
          ),
        ),
      ),
    );
  }
}
