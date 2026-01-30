import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';

import 'update_login_email.dart';
import 'update_phone_number.dart';

class ClientPhoneEmailSection extends StatelessWidget {
  const ClientPhoneEmailSection({
    Key? key,
    required this.client,
    required this.userDetailsPrefill,
    required this.clientDetailsController,
  }) : super(key: key);

  final Client client;
  final UserDetailsPrefillModel? userDetailsPrefill;
  final ClientDetailController? clientDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 54, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue(
            context,
            label: 'Phone Number',
            value: (userDetailsPrefill?.phoneNumber?.isNotNullOrEmpty ?? false)
                ? userDetailsPrefill!.phoneNumber!
                : 'NA',
            isVerified: clientDetailsController?.isPhoneVerified ?? false,
            onEdit: () {
              MixPanelAnalytics.trackWithAgentId(
                'edit_phone',
                screen: 'user_profile_details',
                screenLocation: 'update_profile_phone',
              );
              CommonUI.showBottomSheet(
                context,
                child: UpdatePhoneNumber(
                  client: client,
                  userDetailsPrefill: userDetailsPrefill,
                  isVerified: clientDetailsController?.isPhoneVerified ?? false,
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: ColorConstants.borderColor),
          ),
          _buildLabelValue(
            context,
            label: 'Email',
            value: (userDetailsPrefill?.email?.isNotNullOrEmpty ?? false)
                ? userDetailsPrefill!.email!
                : 'NA',
            isVerified: clientDetailsController?.isEmailVerified ?? false,
            onEdit: () {
              MixPanelAnalytics.trackWithAgentId(
                'edit_email',
                screen: 'user_profile_details',
                screenLocation: 'update_profile_email',
              );

              CommonUI.showBottomSheet(
                context,
                child: UpdateLoginEmail(
                  client: client,
                  userDetailsPrefill: userDetailsPrefill,
                  isVerified: clientDetailsController?.isEmailVerified ?? false,
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LineDash(
              width: 2,
              color: ColorConstants.borderColor,
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   child: Center(
          //     child: Text(
          //       '*Above phone number & email will be used for all investments',
          //       style: Theme.of(context)
          //           .primaryTextTheme
          //           .titleMedium!
          //           .copyWith(color: ColorConstants.tertiaryBlack),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildLabelValue(
    BuildContext context, {
    required String label,
    required String value,
    required bool isVerified,
    required void Function() onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  value,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineLarge!
                      .copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          if (isVerified)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: ColorConstants.greenAccentColor,
                ),
                SizedBox(width: 2),
                Text(
                  'Verified',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.greenAccentColor),
                )
              ],
            ),
          InkWell(
            onTap: () {
              onEdit();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0, left: 5),
              child: Icon(
                Icons.edit,
                color: ColorConstants.primaryAppColor,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
