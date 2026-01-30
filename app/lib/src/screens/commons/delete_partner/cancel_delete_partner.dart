import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/delete_partner_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancelDeletePartner extends StatelessWidget {
  CancelDeletePartner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeletePartnerController>(
      builder: (controller) {
        return _buildCancelRequest(context, controller);
      },
    );
  }

  Widget _buildCancelRequest(
      BuildContext context, DeletePartnerController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: ColorConstants.lightRedColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AllImages().alertIcon,
                height: 24,
                width: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  'Delete Account in Progress',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.errorTextColor,
                      ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Text(
              'Your Account will be deleted in 1-5 Days',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryGrey,
                  ),
            ),
          ),
          ClickableText(
            text: 'Cancel Request',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            onClick: () {
              CommonUI.showBottomSheet(
                context,
                child: CancelDeleteAccountBottomSheet(),
              );
            },
          )
        ],
      ),
    );
  }
}

class CancelDeleteAccountBottomSheet extends StatelessWidget {
  const CancelDeleteAccountBottomSheet({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  AutoRouter.of(context).popForced();
                },
                icon: Icon(
                  Icons.close,
                  color: ColorConstants.black,
                  size: 24,
                ),
              )
            ],
          ),
          Text(
            'Cancel Delete Account Process ?',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            child: Text(
              'Are you sure you want to cancel the Account\nDelete Request ?',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryGrey,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          GetBuilder<DeletePartnerController>(builder: (controller) {
            return ActionButton(
              showProgressIndicator:
                  controller.cancelDeletePartnerRequestState ==
                      NetworkState.loading,
              text: 'Yes, Cancel',
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              onPressed: () async {
                await controller.cancelPartnerDeleteRequest();
                showToast(
                    text: controller.cancelDeletePartnerRequestMessage,
                    context: context);
                AutoRouter.of(context).popForced();
              },
            );
          })
        ],
      ),
    );
  }
}
