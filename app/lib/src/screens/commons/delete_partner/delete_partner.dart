import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/common/delete_partner_controller.dart';
import 'package:app/src/screens/commons/delete_partner/delete_partner_bottomsheets.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeletePartner extends StatefulWidget {
  @override
  State<DeletePartner> createState() => _DeletePartnerState();
}

class _DeletePartnerState extends State<DeletePartner> {
  bool showDeleteButton = false;

  final deletePartnerController = Get.isRegistered<DeletePartnerController>()
      ? Get.find<DeletePartnerController>()
      : Get.put<DeletePartnerController>(DeletePartnerController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeletePartnerController>(
      builder: (controller) {
        if (controller.isAccountDeletionRequestOpen) {
          return SizedBox(
            height: 16,
          );
        } else {
          return _buildDeleteRequest();
        }
      },
    );
  }

  Widget _buildDeleteRequest() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            showDeleteButton = !showDeleteButton;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Delete Partner Account',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    showDeleteButton
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: ColorConstants.tertiaryBlack,
                    size: 24,
                  ),
                ),
              ],
            ),
            if (showDeleteButton)
              Container(
                margin: EdgeInsets.only(top: 15),
                child:
                    GetBuilder<DeletePartnerController>(builder: (controller) {
                  if (controller.deletePartnerRequestState ==
                      NetworkState.loading) {
                    return Center(
                      child: SizedBox(
                        height: 25,
                        child: CircularProgressIndicator(
                          color: ColorConstants.errorTextColor,
                        ),
                      ),
                    );
                  }
                  return ClickableText(
                    text: 'Delete Account',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: ColorConstants.errorTextColor,
                    onClick: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "delete_account",
                        screen: 'partner_profile',
                        screenLocation: 'partner_profile',
                      );
                      CommonUI.showBottomSheet(context,
                          child: AccountDeleteConfirmationBottomSheet());
                    },
                  );
                }),
              )
          ],
        ),
      ),
    );
  }
}
