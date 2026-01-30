import 'package:app/src/widgets/misc/get_investment_product_bottomsheet.dart';
import 'package:flutter/material.dart';

class InvestmentProductBottomSheet extends StatelessWidget {
  const InvestmentProductBottomSheet(
      {Key? key, this.productType, this.productData})
      : super(key: key);

  final String? productType;
  final productData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: getInvestmentProductBottomSheet(context,
          productData: productData, productType: productType),
    );
  }
}
