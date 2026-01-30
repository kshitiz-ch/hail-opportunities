import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/stp_detail_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PastStpOrders extends StatelessWidget {
  const PastStpOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
          child: Text(
            'Past STPs',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _buildTableHeader(context),
        GetBuilder<StpDetailController>(
          id: GetxId.stpOrders,
          builder: (controller) {
            if (controller.stpOrdersResponse.state == NetworkState.loading &&
                !controller.isPaginating) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.stpOrdersResponse.state == NetworkState.error) {
              return Center(
                child: RetryWidget(
                  controller.stpOrdersResponse.message,
                  onPressed: () {
                    controller.getStpOrders();
                  },
                ),
              );
            }

            if (controller.stpOrdersResponse.state == NetworkState.loaded ||
                controller.isPaginating) {
              if (controller.stpOrders.isEmpty) {
                return EmptyScreen(
                  message: 'No STPs found',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.stpOrders.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      StpOrderModel stpOrder = controller.stpOrders[index];
                      return _buildStpOrderRow(context, stpOrder, index);
                    },
                  ),
                  // if (controller.isPaginating) _buildInfiniteLoader()
                ],
              );
            }
            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(color: ColorConstants.tertiaryBlack);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Date',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Amount',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status',
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          )
        ],
      ),
    );
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

  Widget _buildStpOrderRow(
      BuildContext context, StpOrderModel stpOrder, int index) {
    TextStyle textStyle = Theme.of(context).primaryTextTheme.titleLarge!;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: index % 2 == 0 ? ColorConstants.secondaryWhite : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              getDateMonthYearFormat(stpOrder.switchDate),
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              WealthyAmount.currencyFormat(stpOrder.amount, 0),
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              stpOrder.statusDescription,
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          )
        ],
      ),
    );
  }
}
