import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasketAmountSectionNew extends StatefulWidget {
  final BasketController basketController;
  final SchemeMetaModel fund;
  final double? minAmount;

  BasketAmountSectionNew({
    Key? key,
    required this.basketController,
    required this.fund,
    this.minAmount, // Optional override for Minimum Amount (e.g. used for SIF grouping requirements)
  }) : super(key: key) {}

  @override
  State<BasketAmountSectionNew> createState() => _BasketAmountSectionNewState();
}

class _BasketAmountSectionNewState extends State<BasketAmountSectionNew> {
  TextEditingController amountController = TextEditingController();

  void initState() {
    String? text;
    SchemeMetaModel? basketFund =
        widget.basketController.basket[widget.fund.basketKey];
    if (widget.basketController.isUpdateProposal) {
      text = (basketFund?.amountEntered ?? 0).toStringAsFixed(0);
    } else {
      if (basketFund?.amountEntered?.isNotNullOrZero ?? false) {
        text = (basketFund?.amountEntered ?? 0).toStringAsFixed(0);
      }
    }

    amountController = TextEditingController(text: text);
    super.initState();
  }

  double get amount {
    return amountController.text.isEmpty
        ? 0
        : double.parse(amountController.text
            .replaceAll(',', '')
            .replaceAll(' ', '')
            .replaceAll('₹', ''));
  }

  @override
  Widget build(BuildContext context) {
    double minAmount = widget.minAmount ??
        getMinAmount(widget.fund, widget.basketController.investmentType,
            widget.basketController.isTopUpPortfolio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Amount',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge!
              .copyWith(color: ColorConstants.primaryAppColor),
        ),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 8),
          child: TextFormField(
            // focusNode: controller.amountFocusNode,
            controller: amountController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
            textAlign: TextAlign.left,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium!
                  .copyWith(color: ColorConstants.redAccentColor),
              contentPadding: EdgeInsets.only(bottom: 10),
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text("\₹ "),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: 'Enter Amount',
              hintStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.secondaryLightGrey,
                        height: 1.4,
                      ),
            ),
            onChanged: (value) {
              onChanged(value);
            },
            onTap: () {},
            validator: (value) {
              return validator(value);
            },
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Minimum Amount ',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: ColorConstants.tertiaryBlack,
                    ),
              ),
              TextSpan(
                text: WealthyAmount.currencyFormat(minAmount, 0),
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: ColorConstants.black,
                    ),
              )
            ],
          ),
        )
      ],
    );
  }

  void onChanged(String value) {
    if (value.isEmpty) {
    } else {
      value = value.replaceAll(',', '').replaceAll(' ', '').replaceAll('₹', '');
      value = '${WealthyAmount.currencyFormat(value, 0)}';
      // amountController.value = amountController.value.copyWith(
      //   text: '$value',
      //   selection: TextSelection.collapsed(offset: value.length),
      // );
    }

    widget.basketController.addFundToBasket(widget.fund, context, amount,
        toastMessage: null, isCustomFlow: true);
    // basketController.basket[fund.wschemecode]?.amountEntered = amount;
    widget.basketController.update(['basket-summary', 'basket']);
  }

  String? validator(String? value) {
    if (value.isNullOrEmpty) {
      return 'Amount is required.';
    }

    double minAmount = widget.minAmount ??
        getMinAmount(
          widget.fund,
          widget.basketController.investmentType,
          widget.basketController.isTopUpPortfolio,
        );

    if (amount < minAmount) {
      return 'Minimum ${widget.basketController.investmentType == InvestmentType.SIP ? 'sip ' : ''}amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';
    }

    if (widget.fund.isTaxSaver == true && amount % (500) != 0) {
      return 'Amount must be in multiples of 500 for Tax Saving funds';
    }

    return null;
  }
}
