import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SIPStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientEditSipController>(
      builder: (ClientEditSipController controller) {
        final isActive = controller.isSelectedSipActive;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ColorConstants.borderColor.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  InkWell(
                    child: Icon(
                      !isActive ? Icons.pause : Icons.play_arrow,
                      size: 20,
                      color: !isActive
                          ? ColorConstants.yellowAccentColor
                          : ColorConstants.greenAccentColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    !isActive ? 'SIP Paused' : 'SIP Active',
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 25,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: CupertinoSwitch(
                            trackColor:
                                ColorConstants.primaryAppColor.withOpacity(0.2),
                            value: isActive,
                            activeColor: ColorConstants.primaryAppColor,
                            onChanged: (value) async {
                              controller.isSelectedSipActive = value;
                              controller.update();
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: !isActive
                          ? 'SIP is Paused, Switch to '
                          : 'SIP is Active, Switch to ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge
                          ?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    TextSpan(
                      text: !isActive ? 'Activate ' : 'Pause ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge
                          ?.copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    TextSpan(
                      text: 'now',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge
                          ?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
  }
}
