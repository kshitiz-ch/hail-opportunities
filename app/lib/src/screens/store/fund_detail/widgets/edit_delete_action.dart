import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/add_amount_bottom_sheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditDeleteAction extends StatelessWidget {
  final bool? isMicroSIP;

  final SchemeMetaModel? fund;

  final String? tag;

  const EditDeleteAction({Key? key, this.isMicroSIP, this.fund, this.tag})
      : super(key: key);

  Widget _buildWidget(
      {Function? onDelete,
      Function? onEdit,
      double? amountEntered,
      required BuildContext context}) {
    return Row(
      children: [
        Text(
          WealthyAmount.currencyFormat(
            amountEntered,
            0,
            showSuffix: false,
          ),
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 11.0, right: 16),
          child: InkWell(
            onTap: () async {
              onEdit!();
            },
            child: Image.asset(
              AllImages().editIcon,
              height: 10,
              width: 10,
              color: ColorConstants.primaryAppColor,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            // open delete fund bottom sheet
            CommonUI.showBottomSheet(
              context,
              child: DeleteFundBottomSheet(
                onCancel: () {
                  AutoRouter.of(context).popForced();
                },
                onDelete: () async {
                  await onDelete!();
                  AutoRouter.of(context).popForced();
                  showCustomToast(
                    context: context,
                    child: Container(
                      width: SizeConfig().screenWidth,
                      // margin: const EdgeInsets.only(bottom: 136.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: ColorConstants.black.withOpacity(0.9),
                      ),
                      child: Text(
                        "Fund Deleted from Basket ✅",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.white,
                            ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isMicroSIP!) {
      return GetBuilder<MFPortfolioDetailController>(
        id: 'micro-sip',
        builder: (controller) {
          return controller.microSIPBasket.isNotEmpty &&
                  controller.microSIPBasket.containsKey(fund!.basketKey)
              ? _buildWidget(
                  context: context,
                  amountEntered:
                      controller.microSIPBasket[fund!.basketKey]!.amountEntered,
                  onDelete: () async {
                    controller.removeMicroSIPFundFromBasket(fund!);
                  },
                  onEdit: () async {
                    // Show Bottom Sheet
                    await CommonUI.showBottomSheet(
                      context,
                      child: AddAmountBottomSheetContent(
                        actionButtonText: 'Update Fund',
                        fund: fund,
                        preFilledAmount: controller
                            .microSIPBasket[fund!.basketKey]!.amountEntered,
                        onPressed: (amount) async {
                          controller.addMicroSIPFundToBasket(
                            fund!,
                            amount,
                            toastMessage: 'Fund Updated Successfully!',
                          );

                          AutoRouter.of(context).popForced();
                        },
                      ),
                    );
                  },
                )
              : SizedBox.shrink();
        },
      );
    } else {
      return GetBuilder<BasketController>(
        id: 'basket',
        global: tag != null ? false : true,
        init: Get.find<BasketController>(tag: tag),
        builder: (controller) {
          return controller.basket.isNotEmpty &&
                  controller.basket.containsKey(fund?.basketKey)
              ? _buildWidget(
                  context: context,
                  amountEntered:
                      controller.basket[fund?.basketKey]!.amountEntered,
                  onDelete: () async {
                    await deleteFund(
                      context: context,
                      // listKey: listKey,
                      controller: controller,
                      // index: index,
                      // isCustomDetailScreen: isCustomDetailScreen,
                      fund: fund,
                      // tag: tag,
                    );
                  },
                  onEdit: () async {
                    await editFund(
                      context: context,
                      controller: controller,
                      fund: fund!,
                    );
                  },
                )
              : SizedBox.shrink();
        },
      );
    }
  }
}
