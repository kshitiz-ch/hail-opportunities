import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/sip/client_sip_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

class SipDetailCard extends StatefulWidget {
  final int sipIndex;

  const SipDetailCard({Key? key, required this.sipIndex}) : super(key: key);
  @override
  State<SipDetailCard> createState() => _SipDetailCardState();
}

class _SipDetailCardState extends State<SipDetailCard>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  final controller = Get.find<ClientSipDetailController>();
  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _animationController
        .drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sipData = controller.sipTransactionList[widget.sipIndex];
    final date = sipData.status == TransactionOrderStatus.NavAllocated
        ? sipData.navAllocatedAt
        : sipData.lastUpdatedStageAt;
    final rowData = <String>[
      getDateMonthYearFormat(date),
      WealthyAmount.currencyFormat(sipData.lumsumAmount, 0),
      getStatusText(sipData.status),
    ];
    final order = controller.selectedSipOrders
        ?.firstWhereOrNull((sipOrder) => sipOrder.orderId.toString() == sipData.orderId);
    final color = widget.sipIndex % 2 == 0
        ? ColorConstants.secondaryWhite
        : ColorConstants.white;
    final texStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor: color,
        collapsedBackgroundColor: color,
        leading: Text(
          rowData[0],
          style: texStyle,
        ),
        title: Text(
          rowData[1],
          textAlign: TextAlign.center,
          style: texStyle,
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rowData[2],
              style: texStyle.copyWith(
                color: sipData.status == TransactionOrderStatus.NavAllocated
                    ? ColorConstants.greenAccentColor
                    : sipData.status == TransactionOrderStatus.Failure
                        ? ColorConstants.errorColor
                        : ColorConstants.primaryAppColor,
              ),
            ),
            RotationTransition(
              turns: _iconTurns,
              child: SizedBox(
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: ColorConstants.secondaryBlack,
                ),
              ),
            ),
          ],
        ),
        onExpansionChanged: (isExpanding) {
          isExpanding
              ? _animationController.forward()
              : _animationController.reverse();
        },
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding:
            EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 20),
        children: [
          if (order?.schemeOrders?.length != null &&
              order!.schemeOrders!.length > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Funds',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Units (Nav)',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Amount',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 15),
                  itemCount: order.schemeOrders?.length,
                  itemBuilder: (BuildContext context, int index) {
                    SchemeOrderModel schemeOrder = order.schemeOrders![index];
                    String? schemeName = schemeOrder.schemeName;
                    if (schemeName.isNotNullOrEmpty &&
                        order.category == TransactionCategoryType.Siso) {
                      // switch out withradwl
                      // switch in deposit
                      if (schemeOrder.category == "1") {
                        schemeName = schemeName! + ' (Switch out)';
                      }
                      if (schemeOrder.category == "0") {
                        schemeName = schemeName! + ' (Switch in)';
                      }
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              schemeName ?? '-',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${schemeOrder.units != null ? schemeOrder.units!.toStringAsFixed(2) : 0} @ ${schemeOrder.nav != null ? schemeOrder.nav!.toStringAsFixed(2) : 0}',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              WealthyAmount.currencyFormat(
                                  schemeOrder.displayAmount ?? '0', 2),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          _buildOrderProcessedText(order),
          if (sipData.status == TransactionOrderStatus.Failure)
            _buildFailureReason(sipData.failureReason ?? '-')
        ],
      ),
    );
  }

  Widget _buildFailureReason(String failureReason) {
    final style = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Failure reason ', style: style),
          Text(
            failureReason,
            style: style.copyWith(color: ColorConstants.errorColor),
          )
        ],
      ),
    );
  }

  Widget _buildOrderProcessedText(ClientOrderModel? order) {
    String label = '';
    String value = '';

    try {
      bool isSwitchOrder = order?.category == TransactionCategoryType.Siso ||
          order?.category == TransactionCategoryType.SwitchIn;
      if (order?.isProcessing ?? false) {
        label = isSwitchOrder
            ? 'Switch will be processed by'
            : 'Investment will be processed by';
        value = DateFormat('dd MMM yyyy').format(order!.estProcessedAt!);
      } else {
        label =
            isSwitchOrder ? 'Switch processed on' : 'Investment processed on';
        value = DateFormat('dd MMM yyyy').format(order!.navAllocatedAt!);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }

    final style = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w600);
    if (value.isNullOrEmpty) {
      return SizedBox();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  String getStatusText(int? status) {
    switch (status) {
      case TransactionOrderStatus.Created:
        return "Created";
      case TransactionOrderStatus.PaymentInitiated:
        return "Payment Initiated";
      case TransactionOrderStatus.PaymentSuccess:
        return "Payment Success";
      case TransactionOrderStatus.NavAllocated:
        return "Nav Allocated";
      case TransactionOrderStatus.Failure:
        return "Failed";
      default:
        return '-';
    }
  }
}
