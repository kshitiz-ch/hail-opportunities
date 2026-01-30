import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AddFundWarningBottomSheet extends StatelessWidget {
  const AddFundWarningBottomSheet({
    Key? key,
    required this.onProceed,
    this.isAddingNfo = false,
  }) : super(key: key);

  final Function() onProceed;
  final bool isAddingNfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basket Change',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Text(
                  '${getWarningText()}. Please note that NFOs and normal funds cannot be combined in the same basket.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(height: 1.5),
                ),
                SizedBox(height: 20),
                Text(
                  'If you wish to proceed, the existing items from the basket will be cleared.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(height: 1.5),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ActionButton(
                  text: 'Cancel',
                  margin: EdgeInsets.zero,
                  textStyle:
                      Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                  bgColor: ColorConstants.secondaryAppColor,
                  onPressed: () async {
                    AutoRouter.of(context).popForced();
                  },
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: ActionButton(
                  text: 'Proceed',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    AutoRouter.of(context).pop();
                    onProceed();
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String getWarningText() {
    if (isAddingNfo) {
      return "It looks like you\'re trying to add a NFO to your basket that already contains normal funds";
    }

    return "It looks like you\'re trying to add a normal fund to your basket that already contains NFO";
  }
}
