import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({
    Key? key,
    required this.product,
  }) : super(key: key);

  final UnlistedProductModel? product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 52.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Min Sale Price",
            subtitle: WealthyAmount.formatWithoutTrailingZero(
              product!.minSellPrice,
              2,
              addCurrency: true,
            ),
          ),
          GridData(
            title: "Max Sale Price",
            subtitle: WealthyAmount.formatWithoutTrailingZero(
              product!.maxSellPrice,
              2,
              addCurrency: true,
            ),
          ),
          GridData(
            title: "Min Purchase Amount",
            subtitle: WealthyAmount.currencyFormat(
              product!.minPurchaseAmount,
              1,
              showSuffix: false,
            ),
          ),
          if (product?.landingPrice != null)
            GridData(
              title: "Landing Price",
              subtitle: WealthyAmount.formatWithoutTrailingZero(
                product!.landingPrice,
                2,
                addCurrency: true,
              ),
            ),
          GridData(
            title: "ISIN",
            subtitle: product!.isin,
          ),
          if (product!.lotCheckEnabled!)
            GridData(
              title: "Units Available",
              subtitle:
                  "${product!.lotAvailable! > 0 ? product!.lotAvailable : 'None'}",
            ),
        ],
      ),
    );
  }
}
