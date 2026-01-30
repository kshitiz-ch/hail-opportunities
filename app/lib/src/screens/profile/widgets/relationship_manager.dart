import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ManagerCard extends StatelessWidget {
  final Manager? manager;
  final String? title;
  final Color? bgColor;
  final double? horizontalPadding;

  const ManagerCard(
      {Key? key,
      this.manager,
      this.title,
      this.bgColor,
      this.horizontalPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotNullOrEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 16),
              child: Text(
                title ?? '',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundImage: CachedNetworkImageProvider(
                          manager!.imageUrl ?? managerAvatarPlaceholder),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              manager!.name ?? '',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: ColorConstants.black,
                                  ),
                            ),
                            if (manager!.email.isNotNullOrEmpty ||
                                manager!.phoneNumber.isNotNullOrEmpty)
                              Padding(
                                // color: Colors.red,
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: manager!.email.isNotNullOrEmpty
                                            ? manager!.email
                                            : manager!.phoneNumber,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleLarge!
                                            .copyWith(
                                              color:
                                                  ColorConstants.tertiaryBlack,
                                            ),
                                      ),
                                      WidgetSpan(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 9.0),
                                          child: InkWell(
                                            onTap: () {
                                              if (manager!
                                                  .email.isNotNullOrEmpty) {
                                                MixPanelAnalytics
                                                    .trackWithAgentId(
                                                  "copy_email",
                                                  screen: 'partner_profile',
                                                  screenLocation: 'rm_card',
                                                );
                                                copyData(data: manager!.email);
                                              } else if (manager!.phoneNumber!
                                                  .isNotNullOrEmpty) {
                                                MixPanelAnalytics
                                                    .trackWithAgentId(
                                                  "copy_phone",
                                                  screen: 'partner_profile',
                                                  screenLocation: 'rm_card',
                                                );
                                                copyData(
                                                    data: manager!.phoneNumber);
                                              }
                                            },
                                            child: Image.asset(
                                              AllImages().copyIcon,
                                              height: 16,
                                              width: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (manager!.phoneNumber.isNotNullOrEmpty) {
                            MixPanelAnalytics.trackWithAgentId(
                              "call_now",
                              screen: 'partner_profile',
                              screenLocation: 'rm_card',
                            );
                            callNumber(number: manager!.phoneNumber);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AllImages().callIcon,
                              height: 24,
                              width: 24,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                'Call Now ',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: ColorConstants.black,
                                    ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ResponsiveVisibility(hiddenConditions: const [
                        Condition.largerThan(name: TABLET),
                      ], child: Spacer()),
                      ResponsiveVisibility(hiddenConditions: const [
                        Condition.smallerThan(name: TABLET),
                      ], child: SizedBox(width: width / 3)),
                      InkWell(
                        onTap: () async {
                          if (manager!.phoneNumber.isNotNullOrEmpty) {
                            bool isCountryCodeMissing =
                                manager!.phoneNumber != null &&
                                    manager!.phoneNumber!.length == 10;

                            final link = WhatsAppUnilink(
                              phoneNumber:
                                  '${isCountryCodeMissing ? '+91' : ''}${manager!.phoneNumber}',
                              text: "Hey, ${manager?.name ?? 'there'}",
                            );

                            MixPanelAnalytics.trackWithAgentId(
                              "whatsapp",
                              screen: 'partner_profile',
                              screenLocation: 'rm_card',
                            );

                            await launch('$link');
                          } else {
                            showToast(text: 'Phone number not available');
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AllImages().whatsappIconNew,
                                  height: 24,
                                  width: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Text(
                                    'WhatsApp',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: ColorConstants.black,
                                        ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
