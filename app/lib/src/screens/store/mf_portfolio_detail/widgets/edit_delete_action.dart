import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/widgets/bottomsheet/add_amount_bottom_sheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditDeleteAction extends StatelessWidget {
  final SchemeMetaModel? fund;

  const EditDeleteAction({Key? key, this.fund}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'micro-sip',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  controller.removeMicroSIPFundFromBasket(fund!);

                  // Show Toast
                  showToast(
                    context: context,
                    text: 'Fund Removed from Basket!',
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
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
                    Text(
                      ' Delete',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: InkWell(
                  onTap: () async {
                    // Show Bottom Sheet
                    await CommonUI.showBottomSheet(
                      context,
                      child: AddAmountBottomSheetContent(
                        actionButtonText: 'Update Fund',
                        fund: fund,
                        preFilledAmount: controller
                            .microSIPBasket[fund!.basketKey]!.amountEntered,
                        onPressed: (amount) async {
                          double? minAmount = (controller.isTopUpPortfolio &&
                                  fund!.folioOverview!.exists)
                              ? fund!.minAddDepositAmt
                              : fund!.minDepositAmt;

                          if (checkMinAmountValidation(
                              amountEntered: amount, minAmount: minAmount)) {
                            return null;
                          }

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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AllImages().editIcon,
                        height: 10,
                        width: 10,
                        color: ColorConstants.primaryAppColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Edit',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
