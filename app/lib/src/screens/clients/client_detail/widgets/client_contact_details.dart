import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientContactDetails extends StatelessWidget {
  final Client? client;
  TextStyle? textStyle;

  ClientContactDetails({Key? key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.copyWith(color: ColorConstants.black);
    return GetBuilder<ClientDetailController>(
      id: 'account-details',
      builder: (controller) {
        // Client data has instance from notification data & client list screen
        // for old notifications we get old data
        // so updating latest data from accountDetailsResult in that case

        String? phoneNumber = client?.phoneNumber;
        String? emailId = client?.email;
        // phone number from notification data comes as 'None' sometimes
        if (controller.userDetailsPrefill != null) {
          phoneNumber = controller.userDetailsPrefill?.phoneNumber;
          emailId = controller.userDetailsPrefill?.email;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPhoneNo(phoneNumber, controller),
              SizedBox(width: 20),
              Flexible(child: _buildEmail(emailId, controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneNo(String? phoneNumber, ClientDetailController controller) {
    bool? isVerified;
    if (controller.clientMfProfileResponse.state == NetworkState.loaded) {
      isVerified = controller.isPhoneVerified;
    }

    return Row(
      children: [
        Image.asset(AllImages().mobileIcon, height: 16, width: 16),
        SizedBox(width: 4),
        InkWell(
          onTap: () async {
            if (phoneNumber.isNotNullOrEmpty) {
              MixPanelAnalytics.trackWithAgentId(
                "call",
                screen: 'user_profile',
                screenLocation: 'user_profile',
              );
              await launch("tel://$phoneNumber");
            }
          },
          child: Text(phoneNumber ?? 'NA', style: textStyle),
        ),
        SizedBox(width: 4),
        isVerified == true
            ? Image.asset(AllImages().verifiedIcon, height: 12, width: 12)
            : isVerified == false
                ? Image.asset(AllImages().unverifiedIcon, height: 12, width: 12)
                : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEmail(String? email, ClientDetailController controller) {
    bool? isVerified;
    if (controller.clientMfProfileResponse.state == NetworkState.loaded) {
      isVerified = controller.isEmailVerified;
    }
    return Row(
      children: [
        Image.asset(AllImages().emailOutlinedIcon, height: 16, width: 16),
        SizedBox(width: 4),
        Flexible(
          child: InkWell(
            onTap: () async {
              if (controller.clientMfProfileResponse.state ==
                  NetworkState.loaded) {
                if (!controller.isEmailVerified) {
                  showToast(
                      text: 'Please verify the email from the profile section');
                } else {
                  MixPanelAnalytics.trackWithAgentId(
                    "email",
                    screen: 'user_profile',
                    screenLocation: 'user_profile',
                  );
                  await launch("mailto:$email");
                }
              }
            },
            child: MarqueeWidget(
              child: Text(email ?? 'NA', style: textStyle),
            ),
          ),
        ),
        SizedBox(width: 4),
        isVerified == true
            ? Image.asset(AllImages().verifiedIcon, height: 12, width: 12)
            : isVerified == false
                ? Image.asset(AllImages().unverifiedIcon, height: 12, width: 12)
                : SizedBox.shrink(),
      ],
    );
  }
}
