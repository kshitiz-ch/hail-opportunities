import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RefreshArnDetailsBottomSheet extends StatelessWidget {
  const RefreshArnDetailsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        id: GetxId.searchArn,
        builder: (controller) {
          return Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CommonUI.bottomsheetCloseIcon(context),
                ),
                SizedBox(height: 20),
                if (controller.searchPartnerArnResponse.state ==
                    NetworkState.loading)
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      Text(
                        'Please wait up to 1 minute while we fetch your latest ARN details.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(),
                      )
                    ],
                  )
                else if (controller.searchPartnerArnResponse.state ==
                    NetworkState.loaded)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          'ARN Details Updated',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(),
                        ),
                      ),
                      ActionButton(
                        text: 'Close',
                        onPressed: () {
                          AutoRouter.of(context).popForced();
                        },
                      )
                    ],
                  )
                else
                  Column(
                    children: [
                      if (controller.searchPartnerArnResponse.state ==
                          NetworkState.error)
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            controller.searchPartnerArnResponse.message,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(),
                          ),
                        ),
                      ActionButton(
                        text: 'Refresh ARN Details',
                        onPressed: () {
                          controller.searchPartnerArn();
                        },
                      )
                    ],
                  )
              ],
            ),
          );
        });
  }
}
