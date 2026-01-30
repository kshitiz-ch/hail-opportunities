import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_profile_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/client_forms_list.dart';
import '../widgets/client_phone_email_section.dart';
import '../widgets/delete_client_confirmation.dart';
import '../widgets/investment_status_section.dart';
import '../widgets/update_profile_name.dart';

@RoutePage()
class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({Key? key, required this.client}) : super(key: key);

  final Client client;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientProfileController>(
      init: ClientProfileController(client: client),
      builder: (controller) {
        UserDetailsPrefillModel? userDetailsPrefill;
        ClientDetailController? clientDetailsController;
        if (Get.isRegistered<ClientDetailController>()) {
          clientDetailsController = Get.find<ClientDetailController>();
          userDetailsPrefill =
              Get.find<ClientDetailController>().userDetailsPrefill;
        }
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Profile',
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(context, client),
                InvestmentStatusSection(),
                ClientPhoneEmailSection(
                  client: client,
                  clientDetailsController: clientDetailsController,
                  userDetailsPrefill: userDetailsPrefill,
                ),
                // _buildPhoneEmailDetails(context, client),
                ClientFormsList(client: client),
                if (controller.client?.id != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 50),
                    child: InkWell(
                      onTap: () {
                        CommonUI.showBottomSheet(
                          context,
                          child: DeleteClientConfirmationBottomSheet(),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AllImages().deleteIcon,
                            width: 11,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Delete Account',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.errorTextColor),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Client client) {
    final color = pickColor(Random().nextInt(4));

    TextStyle labelStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(color: ColorConstants.tertiaryBlack);

    return GetBuilder<ClientDetailController>(
      id: 'account-details',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withOpacity(0.6),
              child: Center(
                child: Text(
                  controller.userDetailsPrefill?.name?.initials ??
                      client.name ??
                      '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                ),
              ),
            ),
            SizedBox(height: 33),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: controller.userDetailsPrefill?.name ??
                        client.name ??
                        '-',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displaySmall!
                        .copyWith(fontSize: 18),
                  ),
                  WidgetSpan(
                    child: InkWell(
                      onTap: () {
                        MixPanelAnalytics.trackWithAgentId(
                          'edit_name',
                          screen: 'user_profile_details',
                          screenLocation: 'update_profile_name',
                        );

                        CommonUI.showBottomSheet(
                          context,
                          child: UpdateProfileName(
                              client: client,
                              userDetailsPrefill:
                                  controller.userDetailsPrefill),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 1.0, left: 5),
                              child: Icon(
                                Icons.edit,
                                color: ColorConstants.primaryAppColor,
                                size: 12,
                              ),
                            ),
                            Text(
                              'Edit',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: ColorConstants.primaryAppColor,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // maxLines: 2,
              textAlign: TextAlign.center,
            ),
            // Text(
            //   userDetailsPrefill?.name ?? client.name ?? '-',
            //   style: Theme.of(context)
            //       .primaryTextTheme
            //       .displaySmall!
            //       .copyWith(fontSize: 18),
            // ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'CRN: ${client.crn ?? '-'}',
                      textAlign: TextAlign.center,
                      style: labelStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Account Type: ${AccountType.getTaxStatusAccountType(
                        panUsageSubtype:
                            controller.clientMfProfile?.panUsageSubtype ?? '',
                        panUsagetype:
                            controller.clientMfProfile?.panUsageType ?? '',
                        accountType: true,
                        taxStatus: false,
                      )}',
                      textAlign: TextAlign.center,
                      style: labelStyle,
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
