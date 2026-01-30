import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ClientListTile extends StatelessWidget {
  const ClientListTile({
    Key? key,
    required this.client,
    this.effectiveIndex = 0,
    this.showPartnerName = false,
    this.onTap,
  }) : super(key: key);

  final Client client;
  final int effectiveIndex;
  final bool showPartnerName;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap!();
        } else {
          saveClientToRecentClients(client);
          MixPanelAnalytics.trackWithAgentId(
            "user_profile_click",
            screen: 'clients',
            screenLocation: 'clients',
          );

          AutoRouter.of(context).push(ClientDetailRoute(client: client));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildClientLogo(context),
          SizedBox(width: 12),
          Expanded(child: _buildClientDetails(context)),
          if (client.phoneNumber.isNotNullOrEmpty &&
              (client.phoneVerified ?? false))
            _buildClientContacts()
          // Icon(
          //   Icons.arrow_forward_ios,
          //   color: ColorConstants.tertiaryBlack,
          //   size: 16,
          // ),
        ],
      ),
    );
  }

  Widget _buildClientContacts() {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            MixPanelAnalytics.trackWithAgentId(
              "user_whatsapp_click",
              screen: 'clients',
              screenLocation: 'clients',
            );

            final link = WhatsAppUnilink(
              phoneNumber: client.phoneNumber,
              text: "Hey, ${client.name}",
            );
            await launch('$link');
          },
          child: SvgPicture.asset(
            AllImages().whatsappRoundedIcon,
            width: 20,
          ),
        ),
        SizedBox(width: 20),
        InkWell(
          onTap: () async {
            MixPanelAnalytics.trackWithAgentId(
              "user_call_click",
              screen: 'clients',
              screenLocation: 'clients',
            );

            await launch('tel:${client.phoneNumber}');
          },
          child: SvgPicture.asset(
            AllImages().callRoundedIcon,
            width: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (client.name?.toTitleCase() ?? client.email!),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          'CRN: ${client.crn ?? 'N/A'}',
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.tertiaryBlack,
                height: 1.4,
              ),
        ),
        SizedBox(height: 10),
        if (showPartnerName)
          Text(
            'Partner: ${client.agent?.name}',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.lightBlack.withOpacity(0.8),
                  height: 1.4,
                ),
          )
        // if (client.desig)
        // Padding(
        //   padding: EdgeInsets.only(top: 2),
        //   child: Text.rich(
        //     TextSpan(
        //       text: '${client.phoneNumber}',
        //       style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
        //             color: ColorConstants.tertiaryBlack,
        //             height: 1.4,
        //           ),
        //       children: [
        //         TextSpan(
        //           text:
        //               '${isMockEmail(client.email) ? '' : '\n${client.email}'}',
        //           style: Theme.of(context)
        //               .primaryTextTheme
        //               .titleLarge!
        //               .copyWith(
        //                 color: ColorConstants.tertiaryBlack.withOpacity(0.6),
        //                 height: 1.4,
        //               ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          client.name!.initials,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
      ),
      radius: 21,
    );
  }
}
