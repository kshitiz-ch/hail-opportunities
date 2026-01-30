import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/basket_amount_textfield.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MicroSipBasketAmountSection extends StatelessWidget {
  final controller = Get.find<MFPortfolioDetailController>();
  final SchemeMetaModel fund;
  late TextEditingController amountController;

  MicroSipBasketAmountSection({Key? key, required this.fund})
      : super(key: key) {
    String? text;
    if (controller.isUpdateProposal) {
      text = (controller.microSIPBasket[fund.basketKey]?.amountEntered ?? 0)
          .toString();
    } else {
      if (controller
              .microSIPBasket[fund.basketKey]?.amountEntered?.isNotNullOrZero ??
          false) {
        text = (controller.microSIPBasket[fund.basketKey]?.amountEntered ?? 0)
            .toString();
      }
    }
    text = WealthyAmount.currencyFormat(text ?? '0', 0);
    amountController = TextEditingController(text: text);
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
    return BasketAmountTextField(
      amountController: amountController,
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
      amountController.value = amountController.value.copyWith(
        text: '$value',
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    controller.microSIPBasket[fund.wschemecode]?.amountEntered = amount;
    controller.update(['basket-summary', 'investment-type']);
  }

  String? validator(String? value) {
    if (value.isNullOrEmpty) {
      return 'Amount is required.';
    }
    if (fund.minSipDepositAmt.isNotNullOrZero &&
        controller.investmentType != InvestmentType.oneTime) {
      if (amount < fund.minSipDepositAmt!) {
        return 'Minimum sip amount is ${WealthyAmount.currencyFormat(fund.minSipDepositAmt, 0)}';
      }
    } else if (fund.minDepositAmt.isNotNullOrZero) {
      if (amount < fund.minDepositAmt!) {
        return 'Minimum amount is ${WealthyAmount.currencyFormat(fund.minDepositAmt, 0)}';
      }
    }
    return null;
  }
}
