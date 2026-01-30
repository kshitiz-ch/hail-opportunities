import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:core/modules/store/models/store_search_results_model.dart';
import 'package:flutter/material.dart';

class MfResults extends StatelessWidget {
  const MfResults({Key? key, required this.mfFunds}) : super(key: key);
  final UniversalSearchDataModel mfFunds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mfFunds.meta?.displayName ?? 'Mutual Funds',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: mfFunds.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = mfFunds.data![index];
              return InkWell(
                onTap: () {
                  final String tag = 'home_product_search';

                  AutoRouter.of(context).push(
                    ProductDetailsLoaderRoute(
                      productType: product.productType,
                      productVariant: product.productVariant,
                      tag: tag,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonUI.buildRoundedFullAMCLogo(
                      radius: 16,
                      amcName: product.name,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 16),
                        child: Text(
                          product.name ?? '-',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          getReturnPercentageText(product.oneYearReturns),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '1 Year',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
