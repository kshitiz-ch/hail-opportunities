import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/demat_select_client_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/client_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/referral_link_share.dart';
import '../widgets/search_bar_section.dart';

@RoutePage()
class DematSelectClientScreen extends StatelessWidget {
  const DematSelectClientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematSelectClientController>(
      init: DematSelectClientController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Select Client',
            trailingWidgets: [
              _buildAddClientButton(context, controller),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                SearchBarSection(),

                // Demat account opening referral link
                ReferralLinkShare(),
                const SizedBox(height: 24),

                if (controller.searchState == NetworkState.loading)
                  _buildLoadingIndicator()
                else if (controller.searchState == NetworkState.loaded)
                  _buildClientsList(controller, context)
                else
                  _buildRetryWidget(controller)
              ],
            ),
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: FloatingActionButtonSection(),
        );
      },
    );
  }

  Widget _buildAddClientButton(
      BuildContext context, DematSelectClientController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                width: 1,
                color: ColorConstants.primaryAppColor,
              ),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Add Client',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.primaryAppColor,
                  fontWeight: FontWeight.w600,
                  height: 1),
            ),
          ),
          onTap: () {
            onClientAdd(context, controller);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildRetryWidget(DematSelectClientController controller) {
    return Expanded(
      child: Center(
        child: RetryWidget(
          controller.searchErrorMessage,
          onPressed: () {
            controller.getRecentClients();
          },
        ),
      ),
    );
  }

  Widget _buildClientsList(
    DematSelectClientController controller,
    BuildContext context,
  ) {
    bool isSearchResultEmpty = controller.searchQuery.isNotEmpty &&
        controller.searchClients!.length == 0;

    if (isSearchResultEmpty) {
      return Expanded(
        child: EmptyScreen(
          imagePath: AllImages().clientEmptyIcon,
          imageSize: 92,
          message: 'No Clients Found ',
          // actionButtonText: 'Add Client',
          onClick: () {
            onClientAdd(context, controller);
          },
        ),
      );
    }

    bool isInSearchMode = controller.searchQuery.isNotEmpty;
    List<Client>? clientListToShow =
        isInSearchMode ? controller.searchClients : controller.recentClients;

    //sort by name irrespective of case
    if (isInSearchMode) {
      clientListToShow!.sort(((a, b) => (a.name ?? '')
          .toLowerCase()
          .compareTo((b.name ?? '').toLowerCase())));
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isInSearchMode ? 'Search Results' : 'Recent Clients',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: clientListToShow != null && clientListToShow.isNotEmpty
                ? ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 100),
                    itemCount: clientListToShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      Client client = clientListToShow[index];

                      bool isSelected = controller.selectedClients
                              .firstWhereOrNull((Client selectedClient) =>
                                  selectedClient.taxyID == client.taxyID) !=
                          null;

                      return ClientCard(
                        client: client,
                        isSelected: isSelected,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        effectiveIndex: index % 7,
                        onClick: () {
                          controller.updateSelectedClients(
                              client, SelectedClientsUpdateType.Add);
                          AutoRouter.of(context).push(
                            DematOverviewRoute(
                                selectedClients: controller.selectedClients),
                          );
                          // controller.updateSelectedClients(
                          //     client,
                          //     isSelected
                          //         ? SelectedClientsUpdateType.Remove
                          //         : SelectedClientsUpdateType.Add);
                        },
                      );
                    },
                  )
                : EmptyScreen(
                    imagePath: AllImages().clientEmptyIcon,
                    imageSize: 92,
                    message: 'No Clients Added ',
                    actionButtonText: 'Add Client',
                    onClick: () {
                      onClientAdd(context, controller);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void onClientAdd(
      BuildContext context, DematSelectClientController controller) {
    AutoRouter.of(context).push(
      AddClientRoute(
        onClientAdded: (client, _) async {
          AutoRouter.of(context).popForced();
          controller.refetchRecentClients();
        },
      ),
    );
  }
}
