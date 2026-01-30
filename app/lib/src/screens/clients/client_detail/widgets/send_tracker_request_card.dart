import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/send_tracker_request_bottom_sheet.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendTrackerRequestCard extends StatelessWidget {
  // Fields
  final Client? client;

  // Constructor
  const SendTrackerRequestCard({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Since this widget is being used as a shimmer,
    // client will be absent in that case. Hence we'll call
    // the Segment Event only if the client is not null

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  AllImages().trackerOutlinedIcon,
                  height: deviceSpecificValue(context, 20, 24),
                  width: deviceSpecificValue(context, 20, 24),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    'Tracker Value',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(
                            color: ColorConstants.black,
                            fontSize: deviceSpecificValue(context, 12, 16)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 24.0),
              child: Text(
                'See your clients external MF and equity investments through Tracker',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontSize: deviceSpecificValue(context, 12, 14)),
              ),
            ),
            GetBuilder<ClientDetailController>(
                id: 'account-details',
                builder: (controller) {
                  String? mfEmail = client?.mfEmail;
                  String? loginEmail = client?.email;
                  // phone number from notification data comes as 'None' sometimes
                  if (controller.userDetailsPrefill != null) {
                    loginEmail = controller.userDetailsPrefill?.email;
                  }

                  if (controller.clientMfProfile != null) {
                    mfEmail = controller.clientMfProfile?.email;
                  }
                  return ActionButton(
                    showBorder: true,
                    margin: EdgeInsets.zero,
                    onPressed: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "send_tracker_request",
                        screen: 'user_profile',
                        screenLocation: 'user_profile',
                      );

                      bool isMfEmailPresent =
                          mfEmail.isNotNullOrEmpty && !isMockEmail(mfEmail);
                      bool isLoginEmailPresent = loginEmail.isNotNullOrEmpty &&
                          !isMockEmail(loginEmail);
                      if (client != null &&
                          (isMfEmailPresent || isLoginEmailPresent)) {
                        // final controller = Get.find<ClientDetailController>();
                        // controller.isEmailVerified;
                        CommonUI.showBottomSheet(
                          context,
                          child: SendTrackerRequestBottomSheet(client: client),
                        );
                      } else {
                        return showToast(
                          text:
                              "Please make sure email is added for this client",
                        );
                      }
                    },
                    text: 'Send Tracker Request',
                    bgColor: ColorConstants.white,
                    borderColor: ColorConstants.primaryAppColor,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w700,
                        ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
