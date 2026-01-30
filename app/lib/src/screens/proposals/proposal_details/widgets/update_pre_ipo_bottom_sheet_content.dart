import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipo_controller.dart';
import 'package:app/src/screens/store/pre_ipo_form/widgets/form_section.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePreIpoBottomSheetContent extends StatelessWidget {
  // Fields
  final ProposalModel proposal;

  const UpdatePreIpoBottomSheetContent({
    Key? key,
    required this.proposal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = UnlistedProductModel(
      title: proposal.productExtrasJson!['name'],
      productVariant: proposal.productTypeVariant,
      minSellPrice: proposal.productExtrasJson!['min_sell_price'],
      maxSellPrice: proposal.productExtrasJson!['max_sell_price'],
      minPurchaseAmount: proposal.productExtrasJson!['min_purchase_amount'],
      isin: proposal.productExtrasJson!['isin'],
      lotCheckEnabled: false,
    );

    Get.put(
      PreIPOController(
        product: product,
        isUpdateProposal: true,
        proposal: proposal,
      ),
    );

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          GetBuilder<PreIPOController>(
            initState: (_) {
              _initController(Get.find<PreIPOController>());
            },
            builder: (controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: FormSection(
                      product: product,
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: GetBuilder<PreIPOController>(
                      id: 'update-proposal',
                      dispose: (_) {
                        Get.delete<PreIPOController>();
                      },
                      builder: (controller) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            bgColor: ColorConstants.secondaryAppColor,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.primaryAppColor,
                                  fontSize: 16,
                                ),
                            text: 'Discard',
                            margin: EdgeInsets.zero,
                            onPressed: () async {
                              AutoRouter.of(context).popForced(true);
                            },
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          ActionButton(
                            responsiveButtonMaxWidthRatio: 0.4,
                            text: 'Save Changes',
                            margin: EdgeInsets.zero,
                            showProgressIndicator:
                                controller.updateProposalState ==
                                    NetworkState.loading,
                            onPressed: () async {
                              if (controller.formKey.currentState!.validate()) {
                                double totalAmount =
                                    controller.sharePrice! * controller.shares!;
                                if (totalAmount < product.minPurchaseAmount!) {
                                  return showToast(
                                    context: context,
                                    text:
                                        'Min purchase Amount is ${WealthyAmount.currencyFormat(product.minPurchaseAmount, 0, showSuffix: false)}',
                                  );
                                } else {
                                  await controller.updateProposal();

                                  if (controller.updateProposalState ==
                                      NetworkState.loaded) {
                                    AutoRouter.of(context).push(
                                      ProposalSuccessRoute(
                                        client: proposal.customer,
                                        productName: controller.product!.title,
                                        proposalUrl: controller.proposalUrl,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 10.0),
              child: IconButton(
                splashRadius: 20.0,
                icon: Icon(
                  Icons.close,
                  color: ColorConstants.black,
                ),
                onPressed: () async {
                  AutoRouter.of(context).popForced(true);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _initController(PreIPOController controller) {
    final prefilledSharePrice = proposal.productExtrasJson!['sell_price'];
    final prefilledShares = proposal.productExtrasJson!['units'];

    // If prefilledSharePrice is not null, initialize
    // the amountController with prefilledSharePrice
    if (prefilledSharePrice != null) {
      String string = prefilledSharePrice.toString();

      if (string.length > 1 && double.parse(string) > 9999)
        string = '${WealthyAmount.formatNumber(string)}';

      controller.sharePriceController!.value =
          controller.sharePriceController!.value.copyWith(
        text: '₹ ${string}',
        selection: TextSelection.collapsed(offset: string.length + 2),
      );
    }

    // If prefilledShares is not null, initialize
    // the amountController with prefilledShares
    if (prefilledShares != null) {
      String string = prefilledShares.toString();

      if (string.length > 1 && double.parse(string) > 9999)
        string = '${WealthyAmount.formatNumber(string)}';

      controller.sharesController!.value =
          controller.sharesController!.value.copyWith(
        text: '$string Shares',
        selection: TextSelection.collapsed(
          offset: string.length,
        ),
      );
    }

    controller.sharePrice = WealthyCast.toDouble(prefilledSharePrice);
    controller.shares = WealthyCast.toInt(prefilledShares);
  }
}
