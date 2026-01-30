import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/times_ago.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ClientCard extends StatelessWidget {
  final NewClientModel client;
  final int effectiveIndex;

  const ClientCard({
    super.key,
    required this.client,
    required this.effectiveIndex,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          ClientDetailRoute(client: client.getHydraClientModel()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorConstants.secondarySeparatorColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientDetail(context),
            _buildClientMetrics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetail(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xffFAFBFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Client Logo
          CircleAvatar(
            backgroundColor: getRandomBgColor(effectiveIndex),
            child: Center(
              child: Text(
                client.name!.initials,
                style: context.displayMedium!.copyWith(
                  color: getRandomTextColor(effectiveIndex),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            radius: 18,
          ),
          // Client Name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (client.name?.toTitleCase() ?? client.email!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.headlineSmall!.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'CRN ${client.crn ?? 'N/A'}',
                      style: context.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    'Last Login : ${client.lastSeenAtDate != null ? timeAgo(client.lastSeenAtDate!) : 'N/A'}',
                    style: context.titleLarge!.copyWith(
                      color: ColorConstants.tertiaryBlack,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Client Contacts

          // Whatsapp
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
              width: 24,
            ),
          ),

          // Call
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: () async {
                MixPanelAnalytics.trackWithAgentId(
                  "user_call_click",
                  screen: 'clients',
                  screenLocation: 'clients',
                );

                await launch('tel:${client.phoneNumber}');
              },
              child: Icon(
                Icons.call,
                color: ColorConstants.primaryAppColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientMetrics(BuildContext context) {
    final metricsMap = {
      'Total Current':
          WealthyAmount.currencyFormat(client.totalCurrentValue, 0),
      'Total Invested':
          WealthyAmount.currencyFormat(client.totalCurrentInvestedValue, 0),
    }.entries;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: metricsMap.first.key,
              subtitle: metricsMap.first.value,
              titleStyle: context.titleLarge?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w400,
              ),
              subtitleStyle: context.headlineSmall?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: metricsMap.last.key,
              subtitle: metricsMap.last.value,
              titleStyle: context.titleLarge?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w400,
              ),
              subtitleStyle: context.headlineSmall?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
