import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/network_offline_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class NetworkOfflineScreen extends StatelessWidget {
  const NetworkOfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NetworkOfflineController>(
        // initialised in splash screen
        // init: NetworkOfflineController(),
        builder: (controller) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AllImages().networkOfflineImage,
                  width: 160,
                ),
                SizedBox(height: 12),
                Text(
                  'Oops, you’re offline!',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Container(
                  width: 240,
                  child: Text(
                    'Please try again after you have a connection',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w400,
                          color: hexToColor(
                            "#797979",
                          ),
                        ),
                  ),
                ),
                SizedBox(height: 30),
                ActionButton(
                  text: 'Retry',
                  showProgressIndicator:
                      controller.checkNetworkResponse.state ==
                          NetworkState.loading,
                  onPressed: () async {
                    await controller.checkNetworkConnection();

                    if (controller.checkNetworkResponse.state ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).popForced();
                    } else {
                      showToast(text: "Network not available");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
