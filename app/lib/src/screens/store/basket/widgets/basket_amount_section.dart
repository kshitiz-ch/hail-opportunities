import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/basket_amount_textfield.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketAmountSection extends StatefulWidget {
  final String? tag;
  late BasketController basketController;
  final SchemeMetaModel fund;
  late TextEditingController amountController;

  BasketAmountSection({Key? key, required this.tag, required this.fund})
      : super(key: key) {
    basketController = Get.find<BasketController>(tag: tag);
    SchemeMetaModel? basketFund = basketController.basket[fund.basketKey];
    String? text;

    if (basketController.isUpdateProposal) {
      text = (basketFund?.amountEntered ?? 0).toString();
    } else {
      if (basketFund?.amountEntered?.isNotNullOrZero ?? false) {
        text = (basketFund?.amountEntered ?? 0).toString();
      }
    }
    text = WealthyAmount.currencyFormat(text ?? '0', 0);
    amountController = TextEditingController(text: text);
  }

  @override
  State<BasketAmountSection> createState() => _BasketAmountSectionState();
}

class _BasketAmountSectionState extends State<BasketAmountSection> {
  double get amount {
    return widget.amountController.text.isEmpty
        ? 0
        : double.parse(widget.amountController.text
            .replaceAll(',', '')
            .replaceAll(' ', '')
            .replaceAll('₹', ''));
  }

  @override
  Widget build(BuildContext context) {
    return BasketAmountTextField(
      amountController: widget.amountController,
      onChanged: (value) {
        onChanged(value);
      },
      validator: (value) {
        return validator(value);
      },
    );
  }

  void onChanged(String value) {
    if (value.isEmpty) {
    } else {
      value = value.replaceAll(',', '').replaceAll(' ', '').replaceAll('₹', '');
      value = '${WealthyAmount.currencyFormat(value, 0)}';
      widget.amountController.value = widget.amountController.value.copyWith(
        text: '$value',
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    widget.basketController.addFundToBasket(widget.fund, context, amount,
        toastMessage: null, isCustomFlow: true);
    // basketController.basket[fund.wschemecode]?.amountEntered = amount;
    widget.basketController.update(['basket-summary']);
  }

  String? validator(String? value) {
    if (value.isNullOrEmpty) {
      return 'Amount is required.';
    }

    double minAmount = getMinAmount(
        widget.fund,
        widget.basketController.investmentType,
        widget.basketController.isTopUpPortfolio);

    if (amount < minAmount) {
      return 'Minimum ${widget.basketController.investmentType == InvestmentType.SIP ? 'sip ' : ''}amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';
    }

    return null;
  }
}
