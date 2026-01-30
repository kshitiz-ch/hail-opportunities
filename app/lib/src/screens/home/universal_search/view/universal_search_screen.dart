import 'dart:convert';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/home/universal_search_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:core/modules/store/models/store_search_results_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../widgets/customers_results.dart';
import '../widgets/go_to_results.dart';
import '../widgets/mf_portfolio_results.dart';
import '../widgets/mf_results.dart';
import '../widgets/no_result_section.dart';
import '../widgets/search_bar_section.dart';
import '../widgets/search_suggestions.dart';
import '../widgets/smart_search_appbar.dart';
import '../widgets/wealthcase_results.dart';

@RoutePage()
class UniversalSearchScreen extends StatelessWidget {
  const UniversalSearchScreen({Key? key, this.fromDeeplink = true})
      : super(key: key);

  final bool fromDeeplink;

  final String tag = 'smart_search';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UniversalSearchController>(
      init: UniversalSearchController(),
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final controller = Get.find<UniversalSearchController>();
          controller.searchBarFocusNode.requestFocus();
        });
      },
      dispose: (_) {
        if (_.controller?.recentSearchCacheFile != null) {
          String jsonEncoded = json.encode(_.controller?.recentSearches);
          _.controller?.recentSearchCacheFile!.writeAsString('$jsonEncoded');
        }
      },
      builder: (controller) {
        final statusBarColor = Colors.white;
        // isSmartSearch ? ColorConstants.lightBlue : Colors.white;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, () {
              if (controller.searchText.isNotEmpty) {
                controller.clearSearchBar();
              } else {
                AutoRouter.of(context).pop();
              }
            });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              toolbarHeight: 0,
              elevation: 0,
              backgroundColor: statusBarColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: statusBarColor,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartSearchAppBar(fromDeeplink: fromDeeplink),
                  SearchBarSection(),
                  SizedBox(height: 10),
                  Expanded(child: _buildContent(context, controller)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, UniversalSearchController controller) {
    final bool hasWealthyAiFAQAccess = Get.isRegistered<CommonController>()
        ? Get.find<CommonController>().hasWealthyAIFAQAccess
        : false;

    if (controller.searchText.isEmpty) {
      return SearchSuggestions();
    }

    bool isLoading = controller.searchText.isNotEmpty &&
        controller.searchResponse.state == NetworkState.loading;

    if (isLoading) {
      return Center(
        child: Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.searchResultList.isEmpty) {
      if (hasWealthyAiFAQAccess) {
        return NoResultSection(
          message: 'No Result Found',
          searchQuery: controller.searchText,
        );
      } else {
        return EmptyScreen(
          message: 'No Result Found',
        );
      }
    }

    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24).copyWith(top: 20),
      children: [
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.searchResultList.length,
          itemBuilder: (context, index) {
            UniversalSearchDataModel searchModel =
                controller.searchResultList[index];

            if (searchModel.category == UniversalSearchCategory.MF_FUND) {
              return MfResults(
                mfFunds: searchModel,
              );
            }

            if (searchModel.category == UniversalSearchCategory.MF) {
              return MfPortfolioResults(
                mfPortfolios: searchModel,
              );
            }

            if (searchModel.category ==
                UniversalSearchCategory.UNLISTED_STOCK) {
              return _buildUnlistedStocks(context, searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.FIXED_DEPOSIT) {
              return _buildFds(context, searchModel);
            }
            if (searchModel.category == UniversalSearchCategory.DEBENTURE) {
              return _buildMlds(context, searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.PMS) {
              return _buildPms(context, searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.INSURANCE) {
              return _buildInsurance(context, searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.CUSTOMERS) {
              return CustomersResults(clientResult: searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.GO_TO_SCREEN) {
              return GoToResults(goToResult: searchModel);
            }

            if (searchModel.category == UniversalSearchCategory.WEALTHCASE) {
              return WealthcaseResults(wealthcaseResults: searchModel);
            }

            return SizedBox();
          },
        ),
        if (hasWealthyAiFAQAccess)
          Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: NoResultSection(
              message: 'Couldn\'t find what you are looking for?',
              searchQuery: controller.searchText,
            ),
          )
      ],
    );
  }

  Widget _buildFds(BuildContext context, UniversalSearchDataModel fdsResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fdsResult.meta?.displayName ?? 'Insurance',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: fdsResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = fdsResult.data![index];
              return InkWell(
                onTap: () {
                  String defaultProviderId = (product.productVariant ?? '')
                      .split("_")
                      .join("")
                      .toLowerCase();
                  AutoRouter.of(context).push(FixedDepositListRoute(
                      defaultProviderId: defaultProviderId));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: fdImage(product.productVariant),
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget fdImage(String? productVariant) {
    if (productVariant == "bajaj_fd") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network('https://i.wlycdn.com/amc-logos/bajaj.png'),
      );
    }

    if (productVariant == "shriram_fd") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
            'https://res.cloudinary.com/dti7rcsxl/image/upload/v1709786300/sq5sfkpoajw5a7rfml2d.png'),
      );
    }

    return Image.asset(AllImages().storeFdIcon);
  }

  Widget _buildInsurance(
      BuildContext context, UniversalSearchDataModel insuranceResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insuranceResult.meta?.displayName ?? 'Insurance',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: insuranceResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = insuranceResult.data![index];
              return InkWell(
                onTap: () {
                  AutoRouter.of(context).push(
                    InsuranceDetailRoute(
                        productVariant: product.productVariant),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        insuranceImageUrl(product.productVariant),
                      ),
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMlds(BuildContext context, UniversalSearchDataModel mldsResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mldsResult.meta?.displayName ?? 'Debentures',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: mldsResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = mldsResult.data![index];
              return InkWell(
                onTap: () {
                  // String defaultProviderId = (product.productVariant ?? '')
                  //     .split("_")
                  //     .join("")
                  //     .toLowerCase();
                  AutoRouter.of(context).push(
                    ProductDetailsLoaderRoute(
                      category: product.category,
                      productVariant: product.productVariant,
                      productType: product.productType,
                      tag: tag,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.network(
                          "https://i.wlycdn.com/store-products/debenture-default-icon.svg"),
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
                    // Column(
                    //   children: [
                    //     Text(
                    //       getReturnPercentageText(product.oneYearReturns),
                    //       style: Theme.of(context)
                    //           .primaryTextTheme
                    //           .headlineSmall!
                    //           .copyWith(fontWeight: FontWeight.w400),
                    //     ),
                    //     SizedBox(height: 5),
                    //     Text(
                    //       '1 Year',
                    //       style: Theme.of(context)
                    //           .primaryTextTheme
                    //           .titleLarge!
                    //           .copyWith(color: ColorConstants.tertiaryBlack),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPms(BuildContext context, UniversalSearchDataModel pmsResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pmsResult.meta?.displayName ?? 'PMS',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: pmsResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = pmsResult.data![index];
              return InkWell(
                onTap: () {
                  AutoRouter.of(context).push(
                    ProductDetailsLoaderRoute(
                      category: product.category,
                      productVariant: product.productVariant,
                      productType: product.productType,
                      tag: tag,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CommonUI.buildRoundedFullAMCLogo(
                    //     radius: 16, amcName: product.name),
                    Container(
                      height: 32,
                      width: 32,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.network(
                          "https://i.wlycdn.com/store-products/pms-default-icon.svg"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 16),
                        child: Text(
                          product.name ?? '-',
                          style:
                              Theme.of(context).primaryTextTheme.headlineSmall!,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnlistedStocks(
      BuildContext context, UniversalSearchDataModel unlistesStockResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unlistesStockResult.meta?.displayName ?? 'PMS',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: unlistesStockResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              StoreSearchResultModel product = unlistesStockResult.data![index];
              return InkWell(
                onTap: () {
                  // String defaultProviderId = (product.productVariant ?? '')
                  //     .split("_")
                  //     .join("")
                  //     .toLowerCase();
                  AutoRouter.of(context).push(
                    ProductDetailsLoaderRoute(
                      category: product.category,
                      productVariant: product.productVariant,
                      productType: product.productType,
                      tag: tag,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(AllImages().storePreIpoIcon),
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
                    // Column(
                    //   children: [
                    //     Text(
                    //       getReturnPercentageText(product.oneYearReturns),
                    //       style: Theme.of(context)
                    //           .primaryTextTheme
                    //           .headlineSmall!
                    //           .copyWith(fontWeight: FontWeight.w400),
                    //     ),
                    //     SizedBox(height: 5),
                    //     Text(
                    //       '1 Year',
                    //       style: Theme.of(context)
                    //           .primaryTextTheme
                    //           .titleLarge!
                    //           .copyWith(color: ColorConstants.tertiaryBlack),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String insuranceImageUrl(String? productVariant) {
    if (productVariant == InsuranceProductVariant.TERM) {
      return AllImages().termLifeInsuranceIcon;
    }

    if (productVariant == InsuranceProductVariant.SAVINGS) {
      return AllImages().savingsInsuranceIcon;
    }

    if (productVariant == InsuranceProductVariant.TWO_WHEELER) {
      return AllImages().twoWheelerInsuranceIcon;
    }

    if (productVariant == InsuranceProductVariant.FOUR_WHEELER) {
      return AllImages().fourWheelerInsuranceIcon;
    }

    if (productVariant == InsuranceProductVariant.HEALTH) {
      return AllImages().healthInsuranceIcon;
    }

    return AllImages().storeInsuranceIcon;
  }
}
