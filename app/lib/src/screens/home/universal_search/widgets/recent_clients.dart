import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/home/universal_search_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentClients extends StatelessWidget {
  const RecentClients({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UniversalSearchController>(
      id: GetxId.clients,
      builder: (controller) {
        if (controller.recentClientsState == NetworkState.loading) {
          return Container(
            margin: EdgeInsets.only(left: 20, bottom: 30),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
        }

        if (controller.recentClientsState == NetworkState.loaded &&
            controller.clients.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Clients',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  // viewportFraction: 0.5,
                  itemCount: controller.clients.length,
                  itemBuilder: (context, index) {
                    Client client = controller.clients[index];

                    String clientNameInitial =
                        (client.name ?? '').isNotNullOrEmpty
                            ? client.name.initials
                            : '-';

                    return Container(
                      margin: EdgeInsets.only(right: 20),
                      width: 70,
                      child: InkWell(
                        onTap: () {
                          MixPanelAnalytics.trackWithAgentId(
                            "client_click",
                            screen: 'smart_search',
                            screenLocation: 'recent_clients',
                            properties: {"name": client.name},
                          );
                          AutoRouter.of(context).push(
                            ClientDetailRoute(clientId: client.id),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: getRandomBgColor(index % 7),
                              child: Center(
                                child: Text(
                                  (client.name ?? '').isNotNullOrEmpty
                                      ? client.name.initials
                                      : '-',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displayMedium!
                                      .copyWith(
                                        color: getRandomTextColor(index % 7),
                                        fontSize: clientNameInitial.length > 1
                                            ? 15
                                            : 20,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                              radius: 16,
                            ),
                            SizedBox(height: 8),
                            Text(
                              client.name.toTitleCase(),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return SizedBox();
      },
    );
  }
}
