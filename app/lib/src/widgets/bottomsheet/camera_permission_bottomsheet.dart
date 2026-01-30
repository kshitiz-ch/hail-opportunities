import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().camera,
            width: 100,
          ),
          SizedBox(height: 30),
          Text(
            'Provide Permissions',
            style: Theme.of(context)
                .primaryTextTheme
                .displayLarge!
                .copyWith(fontSize: 18, color: ColorConstants.lightBlack),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'To fulfil the requirements of the KYC process, access to your camera and files is necessary for the purposes of photo verification and document upload',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 14, color: ColorConstants.tertiaryBlack),
            ),
          ),
          SizedBox(height: 50),
          ActionButton(
              onPressed: () async {
                AutoRouter.of(context).popForced();
              },
              text: 'Ok, got it!'),
        ],
      ),
    );
  }
}
