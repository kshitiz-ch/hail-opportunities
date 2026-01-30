import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DiscardAddressBottomSheet extends StatelessWidget {
  final bool isEdit;

  const DiscardAddressBottomSheet({Key? key, this.isEdit = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? "Discard 'Edit Address'" : "Discard 'Add Address'",
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.black,
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "All unsaved information will be deleted. \nDo you wish to continue?",
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: 'Cancel',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    AutoRouter.of(context).popForced();
                  },
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.primaryAppColor,
                      ),
                  bgColor: ColorConstants.primaryAppv3Color,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  text: 'Continue',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    AutoRouter.of(context)
                        .popUntilRouteWithName(ClientAddressRoute.name);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
