import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/deeplink_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class DeeplinkLoaderScreen extends StatelessWidget {
  const DeeplinkLoaderScreen({
    super.key,
    required this.ntype,
    required this.aggregateId,
  });

  final String ntype;
  final String aggregateId;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: GetBuilder<DeeplinkController>(
            init: DeeplinkController(ntype, aggregateId),
            builder: (controller) {
              if (controller.deeplinkDataResponse.state ==
                  NetworkState.loading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.deeplinkDataResponse.state == NetworkState.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RetryWidget(
                        "Something went wrong. Please try again",
                        onPressed: controller.getDeeplinkData,
                      ),
                      SizedBox(height: 20),
                      ActionButton(
                        text: 'Go Back',
                        margin: EdgeInsets.symmetric(horizontal: 60),
                        onPressed: () {
                          AutoRouter.of(context).popForced();
                        },
                      )
                    ],
                  ),
                );
              }

              if (controller.deeplinkDataResponse.state ==
                  NetworkState.loaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.routeToNavigate == null) {
                    AutoRouter.of(context).popForced();
                  } else {
                    // Check if target page is not already at top of stack to prevent duplicate navigation
                    final routeName = controller.routeToNavigate!.routeName;
                    final moduleName = getModuleName(routeName: routeName);

                    if (!isPageAtTopStack(context, routeName)) {
                      MixPanelAnalytics.trackWithAgentId(
                        "page_viewed",
                        properties: {
                          "page_name":
                              convertRouteToPageName(routeName, ntype: ntype),
                          if (moduleName.isNotNullOrEmpty)
                            "module_name": moduleName,
                          "source": "Deeplink",
                          'ntype': ntype,
                          ...getDefaultMixPanelFields(routeName),
                        },
                      );

                      // Use pushAndPopUntil instead of replace() to ensure DeeplinkLoaderRoute is properly removed from stack
                      // replace() was not working reliably in release mode when app was fully closed,
                      // causing DeeplinkLoaderRoute to remain in navigation stack
                      AutoRouter.of(context).pushAndPopUntil(
                        controller.routeToNavigate!,
                        predicate: (route) =>
                            route.settings.name != DeeplinkLoaderRoute.name,
                      );
                    }
                  }
                });
              }

              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
