import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'client_card.dart';

class ClientList extends StatelessWidget {
  final TrackerListController controller = Get.find<TrackerListController>();
  final bool? isInSearchMode;
  final FocusNode? searchInputFocusNode;
  ClientList({Key? key, this.isInSearchMode, this.searchInputFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
          child: Text(
            isInSearchMode! ? 'Search Results' : 'All Client(s)',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
          ),
        ),
        Expanded(
          child:
              GetBuilder<TrackerListController>(builder: (trackerController) {
            final clientList = isInSearchMode!
                ? trackerController.clientSearchList
                : trackerController.clientListModel!;

            return clientList.clients.isNotNullOrEmpty
                ? ListView.builder(
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.zero,
                    itemCount: clientList.clients!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final client = clientList.clients![index];
                      return ClientCard(
                        client: client,
                        index: index,
                        isValueSelected:
                            trackerController.isClientSelected(client),
                        onClickHandler: () {
                          trackerController.onClientSelect(client);
                        },
                      );
                    },
                  )
                : EmptyClient(
                    isInSearchMode: isInSearchMode,
                    searchInputFocusNode: searchInputFocusNode,
                  );
          }),
        ),
      ],
    );
  }
}

class EmptyClient extends StatelessWidget {
  final bool? isInSearchMode;
  final FocusNode? searchInputFocusNode;

  const EmptyClient({Key? key, this.isInSearchMode, this.searchInputFocusNode})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No ${isInSearchMode! ? 'Result' : 'Clients'} Found',
              style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                    color: ColorConstants.black.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 10),
            if (isInSearchMode!)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Please make sure the client you are searching has email present',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.darkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              )
            else
              ActionButton(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                text: 'Add New Client',
                onPressed: () async {
                  AutoRouter.of(context).push(
                    AddClientRoute(
                      onClientAdded: (_, __) {
                        AutoRouter.of(context).popForced();
                        Get.find<TrackerListController>().getClients();
                      },
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}

class EmptyTrackerRequest extends StatelessWidget {
  const EmptyTrackerRequest({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_page,
            color: ColorConstants.black.withOpacity(0.5),
            size: 70,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'No Tracker Request Found',
            style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: ColorConstants.black.withOpacity(0.5),
                fontWeight: FontWeight.w600,
                // fontStyle: FontStyle.italic,
                fontSize: 18),
          ),
          SizedBox(height: 16),
          ActionButton(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            text: ('SEND TRACKER REQUEST').toTitleCase(),
            onPressed: () {
              AutoRouter.of(context).push(SendTrackerRequestRoute());
            },
            textStyle: Theme.of(context)
                .primaryTextTheme
                .headlineLarge!
                .copyWith(
                    fontSize: 13,
                    color: ColorConstants.white,
                    fontWeight: FontWeight.w600),
            borderRadius: 130,
          ),
        ],
      ),
    );
  }
}
