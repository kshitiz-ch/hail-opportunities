import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/unauthorised_access_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TargetScreenType { PortfolioReview, WealthCaseProposal }

@RoutePage()
class ChooseClientScreen extends StatefulWidget {
  TargetScreenType targetScreenType;
  final String? type;
  Map<String, String> defaultFilters = {};

  final Function(
    NewClientModel, {
    List<String> agentExternalIds,
  })? onClientSelected;

  ChooseClientScreen({
    Key? key,
    this.targetScreenType = TargetScreenType.PortfolioReview,
    @pathParam this.type,
    this.onClientSelected,
  }) : super(key: key) {
    // Determine the target screen type based on the 'type' path parameter
    if (type != null) {
      switch (type!.toLowerCase()) {
        case 'portfolio-review':
          targetScreenType = TargetScreenType.PortfolioReview;
          break;
        case 'wealthcase-proposal':
          targetScreenType = TargetScreenType.WealthCaseProposal;
          break;
        default:
          targetScreenType = TargetScreenType.PortfolioReview;
      }
    }
    if (targetScreenType == TargetScreenType.WealthCaseProposal) {
      defaultFilters = {
        "key": "trading_enabled",
        "operation": "eq",
        "value": "1"
      };
    }
  }

  @override
  State<ChooseClientScreen> createState() => _ChooseClientScreenState();
}

class _ChooseClientScreenState extends State<ChooseClientScreen> {
  bool multiselect = false;
  String title = 'Choose Client';
  String? subtitle = 'To Generate Portfolio Review';

  final commonController = Get.find<CommonController>();

  /// Stores the IDs of currently selected clients for O(1) lookup/add/remove operations
  /// Used for fast selection state checking without iterating through full objects
  /// Performance: O(1) contains/add/remove vs O(n) with List.any() or Set<Object>.contains()
  Set<String> selectedClientIds = <String>{};

  /// Maps client IDs to their corresponding full client model objects for O(1) retrieval
  /// Used to quickly get full client data when needed without searching through lists
  /// Performance: O(1) retrieval vs O(n) searching through controller.clientList
  Map<String, NewClientModel> clientMap = <String, NewClientModel>{};

  /// Extracts unique identifier from client model for consistent key generation
  /// Performance: O(1) - simple null coalescing operation
  String _getClientId(NewClientModel client) {
    return client.customerId ?? client.userId ?? '';
  }

  PartnerOfficeModel? partnerOfficeModel;

  /// Converts selected client IDs back to full client model objects
  /// Performance: O(n) where n = number of selected clients (typically small)
  /// Much faster than searching through full client list for each selected ID
  List<NewClientModel> get selectedClients {
    return selectedClientIds
        .map((id) => clientMap[id])
        .where((client) => client != null)
        .cast<NewClientModel>()
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller and query the client list
    switch (widget.targetScreenType) {
      case TargetScreenType.PortfolioReview:
        multiselect = false;
        subtitle = 'To Generate Portfolio Review';
        break;
      case TargetScreenType.WealthCaseProposal:
        multiselect = false;
        subtitle = 'To Generate Wealthcase Proposal';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fix for GetX "improper use" error:
    // Only wrap with Obx when we actually need reactive behavior for observable variables.
    // The _buildChooseClient method uses GetBuilder which manages its own state,
    // so wrapping the entire build method with Obx was causing GetX to detect
    // improper usage since no observable variables were being tracked in that scope.

    // For users coming from deeplinks - only use Obx for PortfolioReview authorization check
    if (widget.targetScreenType == TargetScreenType.PortfolioReview) {
      return Obx(() {
        // Reactively check portfolio review section flag
        if (!commonController.portfolioReviewSectionFlag.value) {
          return UnauthorisedAccessScreen(title: 'Portfolio Review');
        }
        return _buildChooseClient(context);
      });
    }

    // For other screen types, no reactive wrapper needed
    return _buildChooseClient(context);
  }

  Widget _buildChooseClient(BuildContext context) {
    return GetBuilder<ClientListController>(
      init: ClientListController(defaultFilters: widget.defaultFilters),
      tag: 'select-client',
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: title,
            subtitleText: subtitle ?? '',
            trailingWidgets: [
              PartnerOfficeDropdown(
                tag: 'Choose-Client-${widget.targetScreenType.name}',
                title: 'Choose Client',
                onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                  controller.updatePartnerEmployeeSelected(partnerOfficeModel);
                  this.partnerOfficeModel = partnerOfficeModel;
                },
                canSelectAllEmployees: true,
                canSelectPartnerOffice: true,
              ),
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: NewSearchBar(
                  searchController: controller.searchController,
                  hintText: 'Search by name, phone, CRN and email',
                  onClear: () {
                    controller.clearSearchBar();
                  },
                  onChanged: (value) {
                    if (value != controller.searchQuery) {
                      controller.searchQuery = value;
                      selectedClientIds.clear();
                      clientMap.clear();
                      controller.searchClientList(value);
                    }
                  },
                ),
              ),
              Expanded(child: _buildClientList(controller)),
              if (controller.clientResponse.isLoading &&
                  controller.isPaginating)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(child: CircularProgressIndicator()),
                ),
              SizedBox(height: 100),
            ],
          ),
          floatingActionButton: controller.clientList.isNotNullOrEmpty
              ? ActionButton(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  isDisabled: selectedClientIds.isEmpty,
                  text: 'Continue',
                  onPressed: () {
                    onContinue();
                  },
                )
              : SizedBox(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildClientList(ClientListController controller) {
    if (controller.clientResponse.isLoading && !controller.isPaginating) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.clientResponse.isError && !controller.isPaginating) {
      return Center(
        child: RetryWidget(
          controller.clientResponse.message,
          onPressed: () {
            controller.queryClientList();
          },
        ),
      );
    }
    if (controller.clientList.isNullOrEmpty) {
      return EmptyScreen(
        imagePath: AllImages().clientSearchEmptyIcon,
        imageSize: 92,
        message: widget.targetScreenType == TargetScreenType.WealthCaseProposal
            ? 'No Clients with Broking Profile Found!'
            : 'No Clients Found!',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 24),
      controller: controller.scrollController,
      itemCount: controller.clientList.length,
      itemBuilder: (context, index) => _buildClientTile(
        client: controller.clientList[index],
        effectiveIndex: index % 7,
      ),
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CommonUI.buildProfileDataSeperator(
            color: ColorConstants.borderColor),
      ),
    );
  }

  /// Returns the client status information including text, color, and background color
  Map<String, dynamic> _getClientStatusInfo(NewClientModel client) {
    // Check individual status flags
    final bool isTrakSynced = client.trakMfLastSyncedOnDate != null;

    switch (widget.targetScreenType) {
      case TargetScreenType.PortfolioReview:
        return {
          'text': isTrakSynced ? 'Tracker Synced' : 'Tracker Not Synced',
          'color': isTrakSynced
              ? ColorConstants.greenAccentColor
              : ColorConstants.tangerineColor,
          'backgroundColor': isTrakSynced
              ? ColorConstants.greenAccentColor.withOpacity(0.1)
              : ColorConstants.tangerineColor.withOpacity(0.1),
        };

      default:
        return {};
    }
  }

  Widget _buildClientTile({
    required NewClientModel client,
    required int effectiveIndex,
  }) {
    void onTap() {
      if (mounted) {
        setState(() {
          final clientId = _getClientId(client);
          clientMap[clientId] =
              client; // Store client for later retrieval - O(1)

          if (multiselect) {
            // Handle multiselect with checkboxes
            // Performance: All operations are O(1) - no iteration through collections
            if (selectedClientIds.contains(clientId)) {
              // O(1) lookup
              selectedClientIds.remove(clientId); // O(1) removal
            } else {
              selectedClientIds.add(clientId); // O(1) addition
            }
          } else {
            // Handle single select
            // Performance: O(1) operations vs O(n) with previous Set<NewClientModel> approach
            if (selectedClientIds.contains(clientId)) {
              // O(1) lookup
              selectedClientIds
                  .clear(); // O(k) where k = selected items (usually 1)
            } else {
              selectedClientIds
                  .clear(); // O(k) where k = selected items (usually 1)
              selectedClientIds.add(clientId); // O(1) addition
            }
          }
        });
      }
    }

    final statusInfo = _getClientStatusInfo(client);
    final clientId = _getClientId(client);
    // Performance: O(1) selection state check vs O(n) with Set<NewClientModel>.any()
    final isSelected = selectedClientIds.contains(clientId);

    return InkWell(
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          // Radio Button with padding for single select mode
          if (!multiselect)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Radio(
                value: clientId,
                groupValue: selectedClientIds.isNotEmpty
                    ? selectedClientIds.first
                    : null,
                onChanged: (value) {
                  onTap();
                },
                activeColor: ColorConstants.primaryAppColor,
              ),
            ),
          Expanded(
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
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  radius: 21,
                ),
                // Client Name
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CommonUI.buildColumnTextInfo(
                      title: client.name?.toTitleCase() ?? client.email ?? '-',
                      subtitle: 'CRN ${client.crn ?? 'N/A'}',
                      titleStyle: context.headlineSmall!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitleStyle: context.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                // Client Status Button
                if (statusInfo.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: statusInfo['backgroundColor'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      statusInfo['text'],
                      style: context.titleLarge!.copyWith(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // Checkbox for multiselect
                if (multiselect)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        onTap();
                      },
                      activeColor: ColorConstants.primaryAppColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onContinue() {
    if (widget.targetScreenType == TargetScreenType.PortfolioReview) {
      AutoRouter.of(context)
          .push(PortfolioReviewRoute(client: selectedClients.first));
    }
    if (widget.targetScreenType == TargetScreenType.WealthCaseProposal) {
      widget.onClientSelected!(
        selectedClients.first,
        agentExternalIds: partnerOfficeModel?.isOwnerSelected == true
            ? []
            : partnerOfficeModel?.agentExternalIds ?? [],
      );
    }
  }
}
