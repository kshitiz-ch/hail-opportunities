import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/clients/client_detail/view/client_detail_screen.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_investments/mf_investment_section.dart';
import 'package:app/src/screens/clients/client_detail/widgets/service_request_section.dart';
import 'package:app/src/screens/clients/client_detail/widgets/tracker_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/report/templates/widgets/report_template_section.dart';
import 'package:app/src/screens/proposals/proposal_list/widgets/proposal_list.dart';
import 'package:app/src/screens/proposals/proposal_list/widgets/status_tabs.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_list.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_tabs.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/card/sip_book_card_new.dart';
import 'package:app/src/widgets/input/sip_book_filter/filter_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class InvestmentsSection extends StatefulWidget {
  @override
  State<InvestmentsSection> createState() => _InvestmentsSectionState();
}

class _InvestmentsSectionState extends State<InvestmentsSection>
    with TickerProviderStateMixin {
  TabController? tabController;
  final tabList = [
    'Investments',
    'Proposals',
    'Tracker',
    // 'Insurance',
    'Transactions',
    'SIP',
    'Service Request',
    'Reports'
  ];
  int currentTabIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: tabList.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: GetBuilder<ClientDetailController>(
          id: 'profile-view',
          builder: (clientDetailController) {
            final selectedProfile = clientDetailController.selectedProfile;
            if (selectedProfile == null) {
              return SizedBox();
            }
            if (clientDetailController.tabBarViewLoading) {
              // needed to auto remove ClientAdditionalDetailController
              return SizedBox(
                height: 400,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final client = Client(
              name: selectedProfile.name,
              crn: selectedProfile.crn,
              taxyID: selectedProfile.userID,
              panNumber: selectedProfile.panNumber,
              phoneNumber: selectedProfile.phoneNumber,
              panUsageType: selectedProfile.accountType,
              email: selectedProfile.email,
              agent: clientDetailController.mainClientAgent,
            );
            return GetBuilder<ClientAdditionalDetailController>(
              init: ClientAdditionalDetailController(client),
              builder: (controller) {
                final labelStyle =
                    Theme.of(context).primaryTextTheme.headlineMedium!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: ColorConstants.white,
                      height: 54,
                      child: TabBar(
                        dividerHeight: 0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.symmetric(horizontal: 16),
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorWeight: 1,
                        controller: tabController,
                        indicatorColor: ColorConstants.primaryAppColor,
                        unselectedLabelColor: ColorConstants.tertiaryBlack,
                        unselectedLabelStyle: labelStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.tertiaryBlack,
                        ),
                        labelColor: ColorConstants.black,
                        labelStyle: labelStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.black),
                        onTap: (index) {
                          setState(() {
                            currentTabIndex = index;
                          });

                          String tabName = '';
                          switch (index) {
                            case 0:
                              tabName = 'investments';
                              return;
                            case 1:
                              tabName = 'proposals';
                              return;
                            case 2:
                              tabName = 'tracker';
                              return;
                            case 3:
                              tabName = 'transactions';
                              return;
                            case 4:
                              tabName = 'sip';
                              return;
                            case 5:
                              tabName = 'service_request';
                              return;
                            case 6:
                              tabName = 'reports';
                              return;
                          }
                          MixPanelAnalytics.trackWithAgentId(
                            tabName,
                            screen: 'user_profile',
                            screenLocation: 'client_holdings',
                          );
                        },
                        tabs: List.generate(
                          tabList.length,
                          (index) => Tab(
                            text: tabList[index],
                            iconMargin: EdgeInsets.zero,
                          ),
                        ).toList(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12)
                          .copyWith(top: 15, bottom: 10),
                      height: SizeConfig().screenHeight / 2,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          MfInvestmentSection(),
                          _buildProposalSection(controller.client!),
                          _buildTrackerSection(controller.client!),
                          _buildTransactionSection(controller.client!),
                          _buildSipList(controller.client!),
                          ServiceRequestSection(client: controller.client!),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 30),
                            child: SingleChildScrollView(
                              child: ReportTemplateSection(
                                  client: controller.client),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }),
    );
  }

  Widget _buildProposalSection(Client client) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<ProposalsController>(
      init: ProposalsController(
        client: client,
        scrollController: scrollController,
      ),
      tag: clientProposalControllerTag,
      autoRemove: false,
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusTabs(),
            Flexible(
              child: ProposalList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrackerSection(Client client) {
    // return TrackerSection(client: client);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TrackerSection(client: client),
      ],
    );
  }

  Widget _buildTransactionSection(Client client) {
    return GetBuilder<TransactionController>(
      init: TransactionController(
        selectedClient: client,
        screenContext: TransactionScreenContext.clientDetailView,
      ),
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionTabs(),
            SizedBox(height: 10),
            Expanded(
              child: TransactionList(showClientDetails: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSipList(Client client) {
    return GetBuilder<SipBookController>(
        init: SipBookController(
          selectedClient: client,
          fromSipBookScreen: false,
        ),
        builder: (controller) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 16, right: 10),
                alignment: Alignment.centerRight,
                child: FilterButton(),
              ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (!controller.isPaginating &&
                        controller.onlineSipResponse.state ==
                            NetworkState.loading) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return SkeltonLoaderCard(
                            height: 200,
                            margin: EdgeInsets.only(bottom: 20),
                          );
                        },
                      );
                    }

                    if (controller.onlineSipResponse.state ==
                        NetworkState.error) {
                      return RetryWidget(
                        controller.onlineSipResponse.message,
                        onPressed: () {
                          controller.getSipUserData();
                        },
                      );
                    }

                    if (controller.onlineSipResponse.state ==
                            NetworkState.loaded &&
                        controller.sipUserData.isEmpty) {
                      return EmptyScreen(
                        message: 'No SIP Found',
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            controller: controller.scrollController,
                            itemCount: controller.sipUserData.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return CommonUI.buildProfileDataSeperator(
                                color: ColorConstants.secondarySeparatorColor,
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              SipUserDataModel sipUserData =
                                  controller.sipUserData[index];
                              return SipBookCardNew(
                                sipData: sipUserData,
                                onClientView: true,
                                fromScreen: 'user_profile',
                                client: client,
                              );
                            },
                          ),
                        ),
                        if (controller.isPaginating) _buildInfiniteLoader()
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget _buildInfiniteLoader() {
    return Container(
      height: 30,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
