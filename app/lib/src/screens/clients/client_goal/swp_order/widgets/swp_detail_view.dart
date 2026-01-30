import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_detail_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:core/modules/clients/models/swp_order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SWPDetailView extends StatefulWidget {
  @override
  State<SWPDetailView> createState() => _SWPDetailViewState();
}

class _SWPDetailViewState extends State<SWPDetailView> {
  final headerText = <String>['Date', 'Amount', 'Status'];

  final controller = Get.find<SwpDetailController>();

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    return GetBuilder<SwpDetailController>(
      id: GetxId.goalSwpOrders,
      builder: (SwpDetailController controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            _buildRow(
              rowData: headerText,
              backgroundColor: ColorConstants.white,
              style: headerStyle.copyWith(
                color: ColorConstants.black,
              ),
              stageTextColor: ColorConstants.tertiaryBlack,
            ),
            _buildSWPOrderView(controller, headerStyle),
          ],
        );
      },
    );
  }

  Widget _buildSWPOrderView(
    SwpDetailController controller,
    TextStyle headerStyle,
  ) {
    Widget getChild(List<SwpOrderModel>? swpList) {
      if (swpList.isNullOrEmpty) {
        return EmptyScreen(
          message: 'No SWPs available',
        );
      }
      return ListView.builder(
        controller: controller.scrollController,
        itemCount: swpList!.length,
        itemBuilder: (BuildContext context, int index) {
          return SwpDetailCard(swpIndex: index);
        },
      );
    }

    return Expanded(
      child: getChild(controller.pastSwps),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SwpDetailController controller,
  ) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ColorConstants.primaryAppColor),
        ),
      ),
      child: Text(
        'Past SWPs',
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            ),
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
