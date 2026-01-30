import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/widgets/bottomsheet/add_amount_bottom_sheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

// TODO: need to updated based on 3.0

class AddToMicroSIPBasketAction extends StatelessWidget {
  const AddToMicroSIPBasketAction({
    Key? key,
    required this.fund,
  }) : super(key: key);

  final SchemeMetaModel fund;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GetBuilder<MFPortfolioDetailController>(
        id: 'micro-sip',
        builder: (controller) {
          return _buildBasketActionWidget(
              context: context, controller: controller);
        },
      ),
    );
  }

  Widget _buildBasketActionWidget(
      {BuildContext? context,
      required MFPortfolioDetailController controller}) {
    bool isFundAdded = controller.microSIPBasket.containsKey(fund.basketKey);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ColorConstants.lightGrey,
            width: 1.0,
          ),
        ),
      ),
      child: isFundAdded
          ? ActionButton(
              heroTag: kDefaultHeroTag,
              text: "Continue",
              margin: EdgeInsets.symmetric(horizontal: 30),
              isDisabled: controller.fundsState != NetworkState.loaded ||
                      controller.isMicroSIP
                  ? controller.microSIPBasket.isEmpty
                  : false,
              onPressed: () {
                if (controller.isMicroSIP) {
                  double? minAmount = controller.isTopUpPortfolio
                      ? controller.portfolio.minAddAmount
                      : controller.portfolio.minAmount;

                  if (checkMinAmountValidation(
                    minAmount: minAmount,
                    amountEntered: controller.totalMicroSIPAmount,
                    isTaxSaver: controller.portfolio.productVariant ==
                        taxSaverProductVariant,
                  )) {
                    return null;
                  }
                }

                AutoRouter.of(context!).push(MfPortfolioFormRoute());
              },
            )
          : ActionButton(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              text: 'Add Fund',
              onPressed: () async {
                await CommonUI.showBottomSheet(
                  context,
                  child: AddAmountBottomSheetContent(
                    fund: fund,
                    onPressed: (amount) async {
                      controller.addMicroSIPFundToBasket(
                        fund,
                        amount,
                        toastMessage: "Fund Added Successfully!",
                      );

                      controller.update(['micro-sip']);

                      AutoRouter.of(context!).popForced();
                    },
                  ),
                );
              },
              textStyle:
                  Theme.of(context!).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: ColorConstants.white,
                      ),
            ),
    );
  }
}
