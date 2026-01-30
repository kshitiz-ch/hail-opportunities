import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/select_client/widgets/search_bar_section.dart';
import 'package:app/src/screens/store/select_client/widgets/select_clients_list.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SelectClientScreen extends StatelessWidget {
  final Function(Client?, bool)? onClientSelected;
  final bool showSearchContactSwitch;
  final bool checkIsClientIndividual;
  final Client? lastSelectedClient;
  final bool showClientFamilyList;
  final bool skipSelectClientConfirmation;
  final bool showAddNewClient;
  final bool showTrackerSyncClients;
  final bool enablePartnerOfficeSupport;

  const SelectClientScreen({
    Key? key,
    required this.onClientSelected,
    this.showClientFamilyList = false,
    this.showSearchContactSwitch = true,
    this.lastSelectedClient,
    this.checkIsClientIndividual = false,
    this.skipSelectClientConfirmation = true,
    this.showAddNewClient = true,
    this.showTrackerSyncClients = false,
    this.enablePartnerOfficeSupport = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectClientController>(
      id: GetxId.searchClient,
      init: SelectClientController(
        lastSelectedClient: lastSelectedClient,
        shouldCheckContactPermission: showSearchContactSwitch,
        showTrackerSyncClients: showTrackerSyncClients,
        enablePartnerOfficeSupport: enablePartnerOfficeSupport,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          // AppBar
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Select Client',
            trailingWidgets: [
              if (showAddNewClient == true)
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    // margin: EdgeInsets.symmetric(vertical: 12).copyWith(right: 30),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      '+ Enter a number',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  onTap: () {
                    AutoRouter.of(context).push(AddClientRoute(
                      onClientAdded: (client, isClientNew) async {
                        if (skipSelectClientConfirmation &&
                            onClientSelected != null) {
                          AutoRouter.of(context).popForced();
                          onClientSelected!(client, false);
                        } else {
                          controller.selectedClient = client;
                          controller.addLastSelectedToRecentClients(client);
                          controller.update([GetxId.searchClient]);
                          await onClientSelected!(client, isClientNew);
                        }
                      },
                    ));
                  },
                ),
              if (enablePartnerOfficeSupport)
                PartnerOfficeDropdown(
                  tag: 'Select-Client',
                  title: 'Clients',
                  onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                    controller
                        .updatePartnerEmployeeSelected(partnerOfficeModel);
                  },
                  canSelectAllEmployees: true,
                  canSelectPartnerOffice: true,
                ),
            ],
          ),

          // Body
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                SearchBarSection(
                  lastSelectedClient: lastSelectedClient,
                ),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,

          floatingActionButton: _buildActionButton(controller, context),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildRetryWidget(SelectClientController controller) {
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
    SelectClientController controller,
    BuildContext context,
  ) {
    bool isSearchResultEmpty = controller.searchQuery.isNotEmpty &&
        controller.searchClients!.length == 0;

    final emptyStateText = showTrackerSyncClients
        ? 'Kindly create external tracker sync request for clients you want to generate change of broker form through tracker flow.'
        : 'No Clients Added ';

    if (isSearchResultEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: EmptyScreen(
            imagePath: AllImages().clientEmptyIcon,
            imageSize: 92,
            message: emptyStateText,
            // actionButtonText: 'Add Client',
            onClick: () {
              onClientAdd(context, controller);
            },
          ),
        ),
      );
    }

    bool isInSearchMode = controller.searchQuery.isNotEmpty;
    List<Client?>? clientListToShow =
        isInSearchMode ? controller.searchClients : controller.recentClients;

    //sort by name irrespective of case
    if (isInSearchMode) {
      clientListToShow!.sort(
          ((a, b) => a!.name!.toLowerCase().compareTo(b!.name!.toLowerCase())));
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
                // Search Contact Switch
                //TODO: update its functionality
                // if (showSearchContactSwitch)
                //   SearchContactSwitch(
                //     enableSearchContact: controller.shouldSearchContacts,
                //   ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: clientListToShow != null && clientListToShow.isNotEmpty
                ? SelectClientsList(
                    clients: clientListToShow,
                    onClientSelected: skipSelectClientConfirmation == true
                        ? onClientSelected
                        : null,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: EmptyScreen(
                      imagePath: AllImages().clientEmptyIcon,
                      imageSize: 92,
                      message: emptyStateText,
                      actionButtonText:
                          showTrackerSyncClients ? '' : 'Add Client',
                      onClick: () {
                        onClientAdd(context, controller);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void onClientAdd(
    BuildContext context,
    SelectClientController controller,
  ) {
    AutoRouter.of(context).push(
      AddClientRoute(
        onClientAdded: (client, isClientNew) async {
          if (skipSelectClientConfirmation && onClientSelected != null) {
            AutoRouter.of(context).popForced();
            onClientSelected!(client, false);
          } else {
            controller.selectedClient = client;
            controller.addLastSelectedToRecentClients(client);
            controller.update([GetxId.searchClient]);
            await onClientSelected!(client, isClientNew);
          }
        },
      ),
    );
  }

  Widget _buildActionButton(
    SelectClientController controller,
    BuildContext context,
  ) {
    if (controller.selectedClient == null ||
        skipSelectClientConfirmation == true) {
      return SizedBox.shrink();
    }

    return ActionButton(
      heroTag: kDefaultHeroTag,
      showProgressIndicator:
          controller.fetchFamilyState == NetworkState.loading,
      text: 'Continue',
      onPressed: () async {
        if (checkIsClientIndividual &&
            !controller.selectedClient?.isProposalEnabled) {
          CommonUI.showBottomSheet(
            context,
            child: ClientNonIndividualWarningBottomSheet(),
          );
        } else {
          if (showClientFamilyList) {
            await controller.getClientFamily();

            if (controller.fetchFamilyState == NetworkState.loaded &&
                controller.familyMembers.length > 0) {
              AutoRouter.of(context)
                  .push(ClientFamilyRoute(onClientSelected: onClientSelected));
            } else {
              await onClientSelected!(controller.selectedClient, false);
            }
          } else {
            await onClientSelected!(controller.selectedClient, false);
          }
        }
      },
    );
  }
}
