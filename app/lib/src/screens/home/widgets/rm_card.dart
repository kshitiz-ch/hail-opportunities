import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/bottomsheet/contact_rm_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class RMCard extends StatelessWidget {
  final AdvisorOverviewModel? advisorModel;

  RMCard({this.advisorModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: ContactRmBottomSheetScreen(
            advisorModel: advisorModel,
            fromScreen: "Home-Card",
          ),
        );
      },
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          color: ColorConstants.secondaryCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Image.network(
                      advisorModel?.agent?.manager?.imageUrl ??
                          managerAvatarPlaceholder,
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   "Get tips from expert's",
                        //   style: Theme.of(context)
                        //       .primaryTextTheme
                        //       .headline5
                        //       .copyWith(
                        //         color: ColorConstants.darkBlack,
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w600,
                        //         height: 19 / 16,
                        //       ),
                        // ),
                        Text.rich(
                          TextSpan(
                              text: 'Contact your relationship manager\n',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    height: 18 / 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                              children: [
                                TextSpan(
                                  text: advisorModel?.agent?.manager?.name ??
                                      "RM",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: ColorConstants.black,
                                        fontWeight: FontWeight.w500,
                                        height: 18 / 12,
                                      ),
                                )
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CommonUI.buildProfileDataSeperator(
              width: double.infinity,
              color: Color(0xffF4E4C2),
            ),
            Container(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await launch(
                            'tel:${advisorModel!.agent?.manager?.phoneNumber}');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AllImages().callRoundedIcon,
                            height: 24,
                            width: 24,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              'Call',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      color: Color(0xff7D41FF)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final link = WhatsAppUnilink(
                          phoneNumber:
                              advisorModel?.agent?.manager?.phoneNumber,
                          text: "Hey, ${advisorModel?.agent?.manager?.name}",
                        );
                        await launch('$link');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AllImages().whatsappIcon,
                            height: 24,
                            width: 24,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              'Message',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    color: Color(0xff25D366),
                                  ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
