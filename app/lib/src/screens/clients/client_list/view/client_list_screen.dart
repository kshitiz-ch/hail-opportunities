import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/add_family_client_search_bottomsheet.dart';
import 'package:app/src/screens/clients/client_list/widgets/client_card_new.dart';
import 'package:app/src/screens/clients/client_list/widgets/client_master_report_bottomsheet.dart';
import 'package:app/src/screens/clients/client_list/widgets/client_onboarding_bottomsheet.dart';
import 'package:app/src/screens/clients/client_list/widgets/filter_sort_buttons.dart';
import 'package:app/src/screens/clients/client_list/widgets/reassign_clients_bottomsheet.dart';
import 'package:app/src/screens/commons/ai/ai_bottom_sheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/ai_icon_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientListScreen extends StatelessWidget {
  final EmployeesModel? employee;
  ClientListScreen({Key? key, this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showBackButton =
        ModalRoute.of(context)!.settings.name == ClientListRoute.name
            ? true
            : false;
    PartnerOfficeModel? partnerOfficeModel;
    if (employee != null && employee!.agentExternalId.isNotNullOrEmpty) {
      partnerOfficeModel = PartnerOfficeModel(
        partnerEmployeeSelected: employee,
        partnerEmployeeExternalIdList: [],
      );
    }
    return PopScope(
      canPop: ModalRoute.of(context)!.settings.name == ClientListRoute.name
          ? true
          : false,
      child: GetBuilder<ClientListController>(
        init: ClientListController(partnerOfficeModel: partnerOfficeModel),
        builder: (controller) {
          final clientCount = controller.clientListMetaData.totalCount;
          return Scaffold(
            backgroundColor: ColorConstants.white,

            // App Bar
            appBar: CustomAppBar(
              leadingLeftPadding: 16,
              showBackButton: showBackButton,
              titleText:
                  'Clients ${clientCount.isNullOrZero ? '' : '($clientCount)'}',
              // subtitleHeight: 14,
              // subtitleText:
              //     '${controller.clientListMetaData.totalCount} Client(s)',
              trailingWidgets: [
                _buildAddClientCTA(context),
                SizedBox(width: 8),
                _buildShareClientOnbardingCTA(context),
                SizedBox(width: 8),
                _buildClientReportCTA(context, controller),
                SizedBox(width: 8),
                _buildAIAssistantCTA(context),
              ],
            ),

            // Body
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOfficeCTAs(context, controller),
                  _buildSearchSection(context, controller),
                  SizedBox(height: 12),
                  Expanded(
                    child: _buildClientList(context, controller),
                  ),
                  if (controller.clientResponse.state == NetworkState.loading &&
                      controller.isPaginating)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientList(
      BuildContext context, ClientListController controller) {
    if (controller.clientResponse.state == NetworkState.loading &&
        !controller.isPaginating) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.clientResponse.state == NetworkState.error &&
        !controller.isPaginating) {
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
        message: 'No Clients Found!',
      );
    }
    return ListView.separated(
      controller: controller.scrollController,
      itemCount: controller.clientList.length,
      itemBuilder: (context, index) => ClientCard(
        client: controller.clientList[index],
        effectiveIndex: index % 7,
      ),
      separatorBuilder: (_, __) => SizedBox(height: 10),
    );
  }

  Widget _buildOfficeCTAs(
      BuildContext context, ClientListController controller) {
    if (Get.isRegistered<HomeController>()) {
      return GetBuilder<HomeController>(
        builder: (homeController) {
          if (homeController.hasPartnerOffice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (controller.clientList.isNotNullOrEmpty)
                    ClickableText(
                      text: 'Reassign Clients',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      onClick: () {
                        CommonUI.showBottomSheet(
                          context,
                          child: ReassignClientsBottomsheet(
                            partnerOfficeModel: controller.partnerOfficeModel,
                          ),
                        );
                      },
                    )
                  else
                    SizedBox(),
                  PartnerOfficeDropdown(
                    tag: 'Client-List',
                    title: 'Client List',
                    selectedEmployee: this.employee,
                    onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                      MixPanelAnalytics.trackWithAgentId(
                        "employee_filter",
                        screen: 'client_list',
                        screenLocation: 'client_list',
                      );
                      controller
                          .updatePartnerEmployeeSelected(partnerOfficeModel);
                    },
                    canSelectAllEmployees: true,
                    canSelectPartnerOffice: true,
                  ),
                ],
              ),
            );
          }
          return SizedBox();
        },
      );
    }
    return SizedBox();
  }

  Widget _buildSearchSection(
      BuildContext context, ClientListController controller) {
    return Row(
      children: [
        Expanded(
          child: NewSearchBar(
            searchController: controller.searchController,
            hintText: 'Search by name, phone, CRN and email',
            onClear: () {
              controller.clearSearchBar();
            },
            onChanged: (value) {
              if (value != controller.searchQuery) {
                controller.searchQuery = value;
                controller.searchClientList(value);
              }
            },
          ),
        ),
        FilterSortButtons(),
      ],
    );
  }

  Widget _buildAddClientCTA(BuildContext context) {
    final items = ['Client', 'Family'];
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 40, maxWidth: 85),
      child: DropdownButtonFormField2<String>(
        alignment: Alignment.center,
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: ColorConstants.primaryAppColor,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          padding: EdgeInsets.zero,
          width: 170,
          elevation: 0,
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all<bool>(true),
            radius: Radius.circular(8),
            thickness: WidgetStateProperty.all<double>(5.0),
            mainAxisMargin: 0,
            crossAxisMargin: 0,
          ),
          maxHeight: 200,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorConstants.black.withOpacity(0.3),
                offset: Offset(0.0, 1.0),
                spreadRadius: 0.0,
                blurRadius: 7.0,
              ),
            ],
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        value: null,
        items: items.map(
          (value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value == 'Client' ? 'Add Client' : 'Add Family Member',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
              ),
            );
          },
        ).toList(),
        selectedItemBuilder: (BuildContext context) {
          return items.map(
            (value) {
              return Text(
                'Add New',
                style: context.headlineSmall?.copyWith(
                  color: ColorConstants.primaryAppColor,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ).toList();
        },
        hint: Text(
          'Add New',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.primaryAppColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        isExpanded: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          // isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConstants.borderColor),
            borderRadius: BorderRadius.circular(15),
          ),
          hintStyle: context.headlineSmall?.copyWith(
            color: ColorConstants.primaryAppColor,
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        onChanged: (val) {
          if (val == 'Client') {
            MixPanelAnalytics.trackWithAgentId(
              "add_client",
              screen: 'clients',
              screenLocation: 'clients',
            );
            onClientAdd(context);
          } else if (val == 'Family') {
            CommonUI.showBottomSheet(
              context,
              child: AddFamilyClientSearchBottomsheet(),
            );
          }
        },
        validator: (val) {
          return null;
        },
      ),
    );
  }

  Widget _buildShareClientOnbardingCTA(BuildContext context) {
    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: ClientOnboardingBottomsheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.primaryAppColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: Image.asset(
          AllImages().clientShareIcon,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget _buildClientReportCTA(
      BuildContext context, ClientListController controller) {
    return InkWell(
      onTap: () async {
        MixPanelAnalytics.trackWithAgentId(
          "download_clients_reports",
          screen: 'clients',
          screenLocation: 'clients',
        );
        controller.createAgentReport();

        await CommonUI.showBottomSheet(
          context,
          child: ClientMasterReportBottomSheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.primaryAppColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: Image.asset(
          AllImages().clientDownloadIcon,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget _buildAIAssistantCTA(BuildContext context) {
    return GetBuilder<CommonController>(
      id: GetxId.clients,
      builder: (controller) {
        if (controller.hasWealthyAiClientAccess) {
          final suggestedQuestions = controller
                  .getAssistantByAssistantKey(
                      AIAssistantType.clientAssistant.key)
                  ?.suggestedQuestions ??
              [];
          return AIIconWidget(
            onTap: () {
              showAIBottomSheet(
                context,
                screenContext: AiScreenType.clients,
                parameters: WealthyAIScreenParameters(
                  assistantKey: AIAssistantType.clientAssistant.key,
                  quickActions: suggestedQuestions,
                ),
              );
            },
            showBackground: false,
            size: 30.0,
          );
        }
        return SizedBox();
      },
    );
  }
}

Future<void> onClientAdd(BuildContext context) async {
  MixPanelAnalytics.trackWithAgentId(
    "add_client",
    screen: 'clients',
    screenLocation: 'clients',
  );

  await AutoRouter.of(context).push(
    AddClientRoute(
      showAddContacts: true,
      onClientAdded: (Client client, bool isClientNew) {
        AutoRouter.of(context).popForced();

        final clientListController = Get.find<ClientListController>();
        clientListController.queryClientList();
      },
    ),
  );
}
