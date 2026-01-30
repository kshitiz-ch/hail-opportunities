import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class SelectClientSection extends StatelessWidget {
  const SelectClientSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final BasketController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.selectedClient == null) {
      return ActionButton(
        text: 'Select Client',
        margin: EdgeInsets.zero,
        onPressed: () {
          AutoRouter.of(context).push(
            SelectClientRoute(
              checkIsClientIndividual: true,
              lastSelectedClient: controller.selectedClient,
              onClientSelected: (client, isClientNew) {
                // If client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
                if (isClientNew ||
                    (client?.isSourceContacts ?? false) ||
                    client?.taxyID != controller.selectedClient?.taxyID) {
                  controller.similarProposalsList = [];
                  controller.hasCheckedSimilarProposals = false;
                }

                if (isClientNew) {
                  AutoRouter.of(context).popForced();
                }

                AutoRouter.of(context)
                    .popUntilRouteWithName(BasketOverViewRoute.name);

                controller.selectedClient = client;
                if (!isClientNew) {
                  controller.getUserFolios();
                }
                controller.update(['basket']);
              },
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Client',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: getRandomBgColor(1),
              child: Center(
                child: Text(
                  controller.selectedClient?.name?.initials ?? '',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displayMedium!
                      .copyWith(
                        color: getRandomTextColor(1),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              radius: 21,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (controller.selectedClient?.name?.toTitleCase() ??
                        controller.selectedClient?.email ??
                        ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  if (controller.selectedClient?.crn.isNotNullOrEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'CRN ${controller.selectedClient?.crn}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryGrey,
                              fontSize: 12,
                              height: 1.4,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 12,
            ),
            if (!(controller.isUpdateProposal || controller.isTopUpPortfolio))
              Row(
                children: [
                  ClickableText(
                    text: 'Change',
                    fontHeight: 1,
                    onClick: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "change_client",
                        screen: 'fund_basket',
                        screenLocation: 'fund_basket',
                      );

                      AutoRouter.of(context).push(
                        SelectClientRoute(
                          checkIsClientIndividual: true,
                          lastSelectedClient: controller.selectedClient,
                          onClientSelected: (client, isClientNew) {
                            // If client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
                            if (isClientNew ||
                                (client?.isSourceContacts ?? false) ||
                                client?.taxyID !=
                                    controller.selectedClient?.taxyID) {
                              controller.similarProposalsList = [];
                              controller.hasCheckedSimilarProposals = false;
                            }

                            if (isClientNew) {
                              AutoRouter.of(context).popForced();
                            }

                            AutoRouter.of(context).popUntilRouteWithName(
                                BasketOverViewRoute.name);
                            controller.selectedClient = client;
                            if (!isClientNew) {
                              controller.getUserFolios();
                            }
                            controller.update(['basket']);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      controller.selectedClient = null;
                      controller.update(['basket']);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 119, 119, 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        AllImages().deleteIcon,
                        height: 12,
                        width: 10,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              )
          ],
        )
      ],
    );
  }
}
