import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DeleteNomineeBottomSheet extends StatelessWidget {
  const DeleteNomineeBottomSheet(
      {Key? key, required this.nomineeName, required this.nomineeType})
      : super(key: key);

  final String nomineeName;
  final NomineeType nomineeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'Delete Nominee?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .displaySmall!
                .copyWith(fontSize: 18),
          ),
          SizedBox(height: 6),
          Text(
            'Are you sure you want to delete "$nomineeName" from your ${getNomineeTypeDescription(nomineeType)} nominee list?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ActionButton(
                  responsiveButtonMaxWidthRatio: 0.4,
                  text: 'Cancel',
                  textStyle:
                      Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                  margin: EdgeInsets.zero,
                  bgColor: ColorConstants.secondaryAppColor,
                  onPressed: () async {
                    AutoRouter.of(context).popForced();
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ActionButton(
                    text: 'Delete',
                    margin: EdgeInsets.zero,
                    // showProgressIndicator:
                    //     controller.sendTrackerState == NetworkState.loading,
                    onPressed: () async {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
