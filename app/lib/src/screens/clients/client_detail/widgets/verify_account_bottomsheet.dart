import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyAccountBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
              height: 18 / 12,
            );
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: GetBuilder<ClientDetailController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'Please complete following actions before adding family members to your account:',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
              ),
              if (!controller.isFirstNameAdded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12)
                      .copyWith(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bulletPointUnicode  ',
                        style: textStyle,
                      ),
                      Expanded(
                        child: Text(
                          'Add First Name',
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!controller.isEmailVerified)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12)
                      .copyWith(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bulletPointUnicode  ',
                        style: textStyle,
                      ),
                      Expanded(
                        child: Text(
                          'Verify Email ID',
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!controller.isPhoneVerified)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12)
                      .copyWith(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bulletPointUnicode  ',
                        style: textStyle,
                      ),
                      Expanded(
                        child: Text(
                          'Verify Phone Number',
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ActionButton(
                text: 'Close',
                margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 50),
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.white,
                        ),
                onPressed: () {
                  AutoRouter.of(context).popForced();
                },
              )
            ],
          );
        },
      ),
    );
  }
}


 
                //