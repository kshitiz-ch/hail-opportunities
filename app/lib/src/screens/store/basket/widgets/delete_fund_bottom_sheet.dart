import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';

class DeleteFundBottomSheet extends StatelessWidget {
  final Function? onDelete;
  final Function? onCancel;

  const DeleteFundBottomSheet({Key? key, this.onDelete, this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30).copyWith(top: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().deleteBasketIcon,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 24),
            child: Text(
              'Are you sure \nyou want to remove this fund?',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black,
                    height: 24 / 14,
                  ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                text: 'Cancel',
                onPressed: onCancel as void Function()?,
                bgColor: ColorConstants.secondaryAppColor,
                borderRadius: 51,
                margin: EdgeInsets.zero,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16,
                        ),
              ),
              SizedBox(
                width: 12,
              ),
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                text: 'Remove',
                onPressed: onDelete as void Function()?,
                borderRadius: 51,
                margin: EdgeInsets.zero,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.white,
                          fontSize: 16,
                        ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
