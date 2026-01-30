import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/rounded_loading_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

void arnAttachDialog(context,
    {description,
    buttonText,
    buttonAction,
    btnController,
    isCheckingArn = true,
    showButton = true}) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    barrierColor: Colors.black.withOpacity(0.8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Wrap(
        children: [
          Container(
            margin: EdgeInsets.all(30).copyWith(top: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      size: 30,
                      color: ColorConstants.black,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        description,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 24),
                if (showButton)
                  Column(
                    children: [
                      if (isCheckingArn)
                        Center(
                          child: ClickableText(
                            fontSize: 16,
                            onClick: () {
                              launch(amfi_distributor_url);
                            },
                            text: 'Register/Renew ARN',
                            fontWeight: FontWeight.w600,
                            padding: EdgeInsets.only(bottom: 16),
                          ),
                        ),
                      // updated RoundedLoadingButton theme according to action button new
                      // to replace it fully need some change in profile controller
                      // TODO: later
                      RoundedLoadingButton(
                        height: 54,
                        child: Text(
                          buttonText.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge!
                              .copyWith(
                                color: ColorConstants.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        color: ColorConstants.primaryAppColor,
                        borderRadius: 27,
                        controller: btnController,
                        onPressed: () {
                          buttonAction();
                        },
                        width: SizeConfig().isTabletDevice
                            ? MediaQuery.of(context).size.width * 0.5
                            : MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                if (isCheckingArn)
                  Text(
                    'Please be patient, searching can take 10-15 seconds',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: Colors.black.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
