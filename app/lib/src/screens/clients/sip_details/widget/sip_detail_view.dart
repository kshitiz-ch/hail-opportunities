import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/sip/client_sip_detail_controller.dart';
import 'package:app/src/screens/clients/sip_details/widget/sip_detail_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:core/modules/transaction/models/mf_order_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SIPDetailView extends StatefulWidget {
  @override
  State<SIPDetailView> createState() => _SIPDetailViewState();
}

class _SIPDetailViewState extends State<SIPDetailView>
    with TickerProviderStateMixin {
  final headerText = <String>['Date', 'Amount', 'Status'];
  final tabs = <String>[
    'Past SIPs',
    // 'Upcoming SIPs',
  ];
  final controller = Get.find<ClientSipDetailController>();

  @override
  void initState() {
    controller.tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    return GetBuilder<ClientSipDetailController>(
      builder: (ClientSipDetailController controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(context, controller),
            _buildRow(
              rowData: headerText,
              backgroundColor: ColorConstants.white,
              style: headerStyle.copyWith(
                color: ColorConstants.black,
              ),
              stageTextColor: ColorConstants.tertiaryBlack,
            ),
            _buildTabBarView(controller, headerStyle),
          ],
        );
      },
    );
  }

  Widget _buildTabBarView(
    ClientSipDetailController controller,
    TextStyle headerStyle,
  ) {
    Widget getChild(List<MfOrderTransactionModel> sipList) {
      if (sipList.isNullOrEmpty) {
        return EmptyScreen(message: 'No SIPs available');
      }
      return ListView.builder(
        controller: controller.scrollController,
        itemCount: sipList.length,
        itemBuilder: (BuildContext context, int index) {
          return SipDetailCard(sipIndex: index);
        },
      );
    }

    return Expanded(
      child: TabBarView(
        controller: controller.tabController,
        children: [
          getChild(controller.sipTransactionList),
        ],
      ),
    );
  }

  Widget _buildTabs(
    BuildContext context,
    ClientSipDetailController controller,
  ) {
    return Container(
      height: 54,
      color: Colors.white,
      child: TabBar(
        onTap: (value) {
          // if (value != controller.tabController!.index) {
          //   controller.tabChangeScrollToTop();
          // }
        },
        dividerHeight: 0,
        controller: controller.tabController,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle:
            Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: ColorConstants.black,
        labelStyle: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            ),
        tabs: List<Widget>.generate(
          tabs.length,
          (index) => Container(
            width: SizeConfig().screenWidth! / tabs.length,
            alignment: Alignment.center,
            child: Tab(
              text: tabs[index],
              iconMargin: EdgeInsets.zero,
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildRow({
    required List<String> rowData,
    required Color backgroundColor,
    required TextStyle style,
    required Color stageTextColor,
  }) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: List<Widget>.generate(
          rowData.length,
          (index) {
            return Expanded(
              child: Align(
                alignment: index == 0
                    ? Alignment.centerLeft
                    : index == 1
                        ? Alignment.center
                        : Alignment.centerRight,
                child: Text(
                  rowData[index],
                  style: index == 2
                      ? style.copyWith(color: stageTextColor)
                      : style,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
