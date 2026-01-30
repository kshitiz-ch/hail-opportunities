import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipo_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FormSection extends StatelessWidget {
  // FIelds
  final UnlistedProductModel? product;

  // Constructor
  const FormSection({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PreIPOController>(
      id: 'total-amt',
      builder: (_controller) {
        String? noOfSharesCaption;
        int? noOfShares;

        // calculate no of shares by lot check
        if (product!.lotCheckEnabled! && product!.lotAvailable! >= 0) {
          noOfShares = product!.lotAvailable;
          noOfSharesCaption = 'No of shares available';
        }
        // calculate no of shares by share price entered by user
        else if (_controller.sharePrice.isNotNullOrZero) {
          noOfShares =
              ((product?.minPurchaseAmount ?? 0) / _controller.sharePrice!)
                  .ceil();
          noOfSharesCaption = 'Min shares required';
        }
        // calculate no of shares by min sell price
        else if (product?.minSellPrice != null &&
            product!.minSellPrice.isNotNullOrZero) {
          noOfShares =
              ((product?.minPurchaseAmount ?? 0) / product!.minSellPrice!)
                  .ceil();
          noOfSharesCaption = 'Min shares required';
        }

        return Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Share Price TextField
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SimpleTextFormField(
                  controller: _controller.sharePriceController,
                  label: 'Enter Share Price',
                  hintText:
                      'Min Price. ${WealthyAmount.currencyFormatWithoutTrailingZero(
                    product!.minSellPrice,
                    1,
                  )}',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Text("\₹ "),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  scrollPadding: const EdgeInsets.only(bottom: 100),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    // only allow upto two decimals
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                    LengthLimitingTextInputFormatter(9),
                  ],

                  onChanged: (string) {
                    if (string.isEmpty) {
                      // LogUtil.printLog("here");
                      // _controller.sharePrice = 0;
                    } else {
                      if (string[0] == '₹') {
                        string = string.substring(2);
                      }
                      _controller.sharePrice = double.parse(string);

                      // if (string.length > 1 && double.parse(string) > 9999) {
                      //   string =
                      //       '${WealthyAmount.formatNumber(string.replaceAll(',', ''))}';
                      // }

                      // _controller.sharePriceController!.value =
                      //     _controller.sharePriceController!.value.copyWith(
                      //   text: string,
                      // selection: TextSelection.collapsed(
                      //   offset: string.length + 2,
                      // ),
                      // );
                    }
                    _controller.update(['total-amt']);
                  },
                  validator: (value) {
                    if (value.isNullOrEmpty) {
                      return 'Share Price is required';
                    }

                    try {
                      if (_controller.sharePrice! < product!.minSellPrice!) {
                        return 'Minimum selling price should be ${WealthyAmount.currencyFormatWithoutTrailingZero(product!.minSellPrice, 2)}';
                      }

                      if (_controller.sharePrice! > product!.maxSellPrice!) {
                        return 'Maxiumum selling price should be ${WealthyAmount.currencyFormatWithoutTrailingZero(product!.maxSellPrice, 2)}';
                      }
                    } catch (error) {}

                    return null;
                  },
                  // onFieldSubmitted: (_) {
                  //   _controller.sharesFocusNode.requestFocus();
                  // },
                ),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Min Price. ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontSize: 12,
                          ),
                    ),
                    TextSpan(
                      text: WealthyAmount.currencyFormatWithoutTrailingZero(
                        product!.minSellPrice,
                        1,
                      ),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontSize: 12,
                          ),
                    ),
                    TextSpan(
                      text: ', Max Price. ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontSize: 12,
                          ),
                    ),
                    TextSpan(
                      text: WealthyAmount.currencyFormatWithoutTrailingZero(
                        product!.maxSellPrice,
                        1,
                      ),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontSize: 12,
                          ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 44),

              // Quantity TextField
              SimpleTextFormField(
                controller: _controller.sharesController,
                label: 'Enter Quantity',
                hintText: 'Eg. 2 Shares',
                keyboardType: TextInputType.number,
                focusNode: _controller.sharesFocusNode,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (string) {
                  if (string.isEmpty) {
                    _controller.shares = 0;
                    // _controller.sharesController.value =
                    //     TextEditingValue(text: '');
                  } else {
                    if (string[0] == '₹') string = string.substring(2);
                    _controller.shares = int.parse(string);

                    if (string.length > 1 && double.parse(string) > 9999)
                      string =
                          '${WealthyAmount.formatNumber(string.replaceAll(',', ''))}';

                    _controller.sharesController!.value =
                        _controller.sharesController!.value.copyWith(
                      text: '$string Shares',
                      selection: TextSelection.collapsed(
                        offset: string.length,
                      ),
                    );
                  }
                  _controller.update(['total-amt']);
                },
                validator: (value) {
                  if (value.isNullOrEmpty) {
                    return 'No of shares is required';
                  }

                  if (product!.lotCheckEnabled! && product!.lotAvailable! > 0) {
                    try {
                      if (_controller.shares! > product!.lotAvailable!) {
                        return 'Only ${product!.lotAvailable!.toStringAsFixed(0)} units are available now';
                      }
                    } catch (error) {}
                  }

                  return null;
                },
              ),
              SizedBox(height: 8),
              if (noOfShares != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: noOfSharesCaption,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontSize: 12,
                            ),
                      ),
                      TextSpan(
                        text: ' $noOfShares',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                height: 44,
              ),
              if (product!.lotCheckEnabled! && product!.lotAvailable! <= 0)
                _buildBottomTextContainer(context, showMinPurchaseAmount: false)
              else if (product!.minPurchaseAmount != null)
                _buildBottomTextContainer(context, showMinPurchaseAmount: true)
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomTextContainer(BuildContext context,
      {bool showMinPurchaseAmount = false}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: showMinPurchaseAmount
            ? (Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Min Purchase Amount ',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            color: ColorConstants.tertiaryBlack, fontSize: 12),
                  ),
                  Text(
                    WealthyAmount.currencyFormat(product!.minPurchaseAmount, 0,
                        showSuffix: false),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontSize: 12),
                  )
                ],
              ))
            : (Text(
                'No Units Available',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        color: ColorConstants.tertiaryBlack, fontSize: 12),
              )),
      ),
    );
  }
}
