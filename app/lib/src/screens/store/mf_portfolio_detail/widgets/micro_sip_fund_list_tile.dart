import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_section.dart';
import 'package:app/src/screens/store/mf_portfolio_detail/widgets/add_to_micro_sip_basket_action.dart';
import 'package:app/src/screens/store/mf_portfolio_detail/widgets/edit_delete_action.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/list_tile/editable_fund_list_tile.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

// TODO: need to updated based on 3.0
class MicroSIPFundListTile extends StatelessWidget {
  final SchemeMetaModel fund;

  const MicroSIPFundListTile({
    Key? key,
    required this.fund,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20)
          .copyWith(bottom: 16.0, top: 10),
      child: GetBuilder<MFPortfolioDetailController>(
        id: 'micro-sip',
        builder: (controller) {
          return EditableFundListTile(
            fund: fund,
            onPressed: () {
              AutoRouter.of(context).push(
                FundDetailRoute(
                  isMicroSIP: true,
                  isTopUpPortfolio: controller.isTopUpPortfolio,
                  fund: fund,
                  showBottomBasketAppBar: false,
                  basketBottomBar: AddToMicroSIPBasketAction(
                    fund: fund,
                  ),
                ),
              );
            },
            bottomPane: controller.microSIPBasket.containsKey(fund.basketKey)
                ? EditDeleteAction(fund: fund)
                : SizedBox(),
            rightPane: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: controller.microSIPBasket.containsKey(fund.basketKey)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          WealthyAmount.currencyFormat(
                            controller
                                .microSIPBasket[fund.basketKey]!.amountEntered,
                            0,
                            showSuffix: false,
                          ),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.black,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: buildAddedWidget(
                            context,
                            iconColor: ColorConstants.greenAccentColor,
                            fillColor: Color(0xffE9FFEF),
                          ),
                        ),
                      ],
                    )

                  // Add Button
                  : TextButton(
                      child: Text(
                        "+ Add",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          ColorConstants.primaryAppColor,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        controller.addMicroSIPFundToBasket(
                          fund,
                          null,
                          toastMessage: "Fund Added Successfully!",
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
