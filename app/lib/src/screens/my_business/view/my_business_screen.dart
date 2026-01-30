import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/my_business/business_controller.dart';
import 'package:app/src/controllers/my_business/business_graph_controller.dart';
import 'package:app/src/screens/my_business/widgets/business_graph_section.dart';
import 'package:app/src/screens/my_business/widgets/business_info_card.dart';
import 'package:app/src/screens/my_business/widgets/business_overview_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const tag = 'My-Business';

@RoutePage()
class MyBusinessScreen extends StatelessWidget {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool hasLimitedAccess = false;
    if (Get.isRegistered<HomeController>()) {
      hasLimitedAccess = Get.find<HomeController>().hasLimitedAccess;
    }

    return GetBuilder<BusinessController>(
      init: BusinessController(),
      dispose: (_) {
        if (Get.isRegistered<BusinessGraphController>(tag: tag)) {
          Get.delete<BusinessGraphController>(tag: tag);
        }
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            backgroundColor: ColorConstants.tertiaryCardColor,
            titleText: 'My Business',
            subtitleText:
                'This page help you efficiently plan, manage and track your business',
            trailingWidgets: [
              PartnerOfficeDropdown(
                tag: tag,
                title: 'Business',
                onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                  MixPanelAnalytics.trackWithAgentId(
                    "employee_filter",
                    screen: 'my_business',
                    screenLocation: 'my_business',
                  );
                  final businessController = Get.find<BusinessController>();
                  businessController
                      .updatePartnerEmployeeSelected(partnerOfficeModel);
                  final businessGraphController =
                      Get.find<BusinessGraphController>(tag: tag);
                  businessGraphController
                      .updatePartnerEmployeeSelected(partnerOfficeModel);
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 500),
                    );
                  }
                },
                canSelectAllEmployees: true,
                canSelectPartnerOffice: true,
              ),
            ],
          ),
          body: ListView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              BusinessOverViewSection(),
              Container(
                // color: ColorConstants.secondaryAppColor,
                margin: EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.only(top: 10),
                // Initialised BusinessGraphController here to fix getx not found issue
                child: GetBuilder<BusinessGraphController>(
                  init: BusinessGraphController(hasLimitedAccess),
                  tag: tag,
                  autoRemove: false,
                  builder: (controller) {
                    return BusinessGraphSection(tag: tag);
                  },
                ),
              ),
              // Client Metrics
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BusinessInfoCard(
                  title: 'Clients',
                  image: AllImages().clientMore,
                  onTap: () {
                    AutoRouter.of(context).push(ClientListRoute());
                  },
                  id: BusinessSectionId.ClientMetrics,
                ),
              ),
              // MF Business Metrics
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: BusinessInfoCard(
                  title: 'Mutual Fund (Current Month)',
                  image: AllImages().storeMfIcon,
                  // onTap: () {
                  //   AutoRouter.of(context).push(MfLobbyRoute());
                  // },
                  id: BusinessSectionId.MFMetrics,
                ),
              ),
              // Online Sip Business
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BusinessInfoCard(
                  title: 'SIP Book (Online)',
                  image: AllImages().sipbookIcon,
                  onTap: () {
                    AutoRouter.of(context).push(SipBookRoute());
                  },
                  id: BusinessSectionId.OnlineSipMetrics,
                ),
              ),
              // Offline Sip Business
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
                child: BusinessInfoCard(
                  title: 'SIP Book (Offline)',
                  image: AllImages().sipbookIcon,
                  onTap: () {
                    AutoRouter.of(context).push(SipBookRoute());
                  },
                  id: BusinessSectionId.OfflineSipMetrics,
                ),
              ),
              // Tracker Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: BusinessInfoCard(
                  title: 'Business Opportunity',
                  image: AllImages().myBusinessMoreIcon,
                  onTap: () {
                    AutoRouter.of(context).push(TrackerListRoute());
                  },
                  id: BusinessSectionId.TrackerMetrics,
                ),
              ),
              // Broking Business
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
                child: BusinessInfoCard(
                  title: 'Broking Demat (Current Month)',
                  image: AllImages().brokingBusinessMoreIcon,
                  onTap: () {
                    AutoRouter.of(context).push(BrokingRoute());
                  },
                  id: BusinessSectionId.Broking,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
