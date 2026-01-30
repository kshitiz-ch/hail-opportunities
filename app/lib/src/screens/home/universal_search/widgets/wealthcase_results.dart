import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:core/modules/wealthcase/models/wealthcase_search_model.dart';
import 'package:flutter/material.dart';

class WealthcaseResults extends StatelessWidget {
  const WealthcaseResults({Key? key, required this.wealthcaseResults})
      : super(key: key);
  final UniversalSearchDataModel wealthcaseResults;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wealthcaseResults.meta?.displayName ?? 'Wealthcase',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: wealthcaseResults.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              WealthcaseSearchResultModel wealthcase =
                  wealthcaseResults.data![index];
              return InkWell(
                onTap: () {
                  // Navigate to wealthcase detail
                  if (wealthcase.basketId.isNotNullOrEmpty) {
                    AutoRouter.of(context).push(WealthcaseDetailRoute(
                        basketId: wealthcase.basketId ?? ''));
                  } else {
                    AutoRouter.of(context).push(WealthcaseListRoute());
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorConstants.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SmartValues logo
                      CachedNetworkImage(
                        imageUrl: getWealthCaseLogo(wealthcase.riaName),
                        fit: BoxFit.contain,
                        height: 20,
                        width: 100,
                      ),
                      // Title
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            (wealthcase.viewName ??
                                    wealthcase.name ??
                                    'Wealthcase')
                                .toTitleCase(),
                            style: context.headlineSmall?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        '${wealthcase.formattedOneYearReturns}\n1Y CAGR',
                        style: context.headlineSmall?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
