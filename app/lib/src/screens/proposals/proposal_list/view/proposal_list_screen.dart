import 'dart:async';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/screens/proposals/proposal_list/widgets/proposal_filter.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/partner_type_tabs.dart';
import '../widgets/proposal_list.dart';
import '../widgets/status_tabs.dart';

// TODO: Refactor tab status mapping
List tabStatusList = ['ALL', 'open', 'won'];
List tabTitles = ['All', 'Under Process', 'Completed', 'Deleted'];

int getTabIndex(tab) {
  tab = tab.toLowerCase();
  if (tab == "all") return 0;
  if (tab == "open") return 1;
  if (tab == "won") return 2;
  return 0;
}

@RoutePage()
class ProposalListScreen extends StatefulWidget {
  final Client? client;
  final String? tabStatus;
  final bool showBackButton;
  final String? employeeAgentExternalId;
  final String? selectedProductCategory;

  ProposalListScreen({
    Key? key,
    this.client,
    this.tabStatus,
    this.showBackButton = false,
    this.employeeAgentExternalId,
    this.selectedProductCategory,
  }) : super(key: key);

  @override
  State<ProposalListScreen> createState() => _ProposalListScreenState();
}

class _ProposalListScreenState extends State<ProposalListScreen>
    with TickerProviderStateMixin {
  late ProposalsController controller;
  ScrollController _scrollController = ScrollController();

  // for topup button
  MFPortfoliosController mfPortfolioController =
      Get.put<MFPortfoliosController>(MFPortfoliosController());

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      ProposalsController(
        client: widget.client,
        scrollController: _scrollController,
        selectedTabStatus: widget.tabStatus ?? 'ALL',
        employeeAgentExternalId: widget.employeeAgentExternalId,
        selectedProductCategory: widget.selectedProductCategory,
      ),
    );

    controller.tabController =
        TabController(length: tabTitles.length, vsync: this);
    if (widget.tabStatus != null) {
      controller.tabController!.index = getTabIndex(widget.tabStatus);
    }
    if (widget.selectedProductCategory.isNotNullOrEmpty) {
      controller.updateSelectedProductCategory(widget.selectedProductCategory);
    }

    controller.tabController!.addListener(() async {
      // A debounce for controlling multiple tab switches in quick succession
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(const Duration(milliseconds: 1000), () {
        String tabStatus = tabStatusList[controller.tabController!.index];
        controller.updateTabStatus(tabStatus);
        controller.getProposals();

        MixPanelAnalytics.trackWithAgentId(
          tabTitles[controller.tabController!.index],
          screen: 'proposals',
          screenLocation: 'proposals',
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<ProposalsController>();
    _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String clientFirstName = '';

    if ((widget.client?.name ?? '').isNotNullOrEmpty) {
      clientFirstName = '${widget.client!.name!.split(" ")[0]}\'s ';
    }

    final showBackButton =
        ModalRoute.of(context)!.settings.name == ProposalListRoute.name
            ? true
            : widget.showBackButton;
    return PopScope(
      canPop: showBackButton,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        // App Bar
        appBar: CustomAppBar(
          titleText: '${clientFirstName.toTitleCase()}Proposals',
          //  show the back button for deeplinking
          showBackButton: showBackButton,
          trailingWidgets: [
            Align(
              alignment: Alignment.centerRight,
              child: ProposalFilter(),
            ),
          ],
        ),
        body: GetBuilder<ProposalsController>(
          dispose: (_) {
            if (Get.isRegistered<MFPortfoliosController>()) {
              Get.delete<MFPortfoliosController>();
            }
          },
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Get.isRegistered<HomeController>())
                  GetBuilder<HomeController>(
                    builder: (controller) {
                      bool isEmployeeProposalsView =
                          widget.employeeAgentExternalId != null &&
                              widget.employeeAgentExternalId!.isNotEmpty;

                      bool hasPartnerOffice =
                          Get.find<HomeController>().hasPartnerOffice;

                      bool showPartnerOfficeTab = hasPartnerOffice &&
                          !isEmployeeProposalsView &&
                          widget.client?.taxyID == null;

                      String? partnerDisplayName =
                          Get.isRegistered<HomeController>()
                              ? Get.find<HomeController>()
                                  .advisorOverviewModel
                                  ?.agent
                                  ?.displayName
                              : null;

                      String partnerFirstName = 'Your';
                      if (partnerDisplayName != null &&
                          partnerDisplayName.isNotEmpty) {
                        partnerFirstName =
                            '${partnerDisplayName.split(" ")[0]}\'s';
                      }

                      if (showPartnerOfficeTab) {
                        return PartnerTypeTabs(
                            partnerFirstName: partnerFirstName);
                      }
                      return SizedBox();
                    },
                  ),
                StatusTabs(),
                Expanded(child: ProposalList()),
              ],
            );
          },
        ),
      ),
    );
  }
}
