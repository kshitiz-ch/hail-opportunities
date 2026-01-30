import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/ntypes.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/notifications/models/notifications_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class BannerCarousel extends StatelessWidget {
  HomeController controller = Get.find<HomeController>();
  bool hasMultipleBanners = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'dashboard-content',
      builder: (controller) {
        hasMultipleBanners = controller.homeBanners.length > 1;
        final bannerSwiperCards = <Widget>[];

        // final List bannersList = SizeConfig().isTabletDevice
        //     ? (controller.dashboardContent?.homeBannersTablet ?? [])
        //     : (controller.dashboardContent?.homeBanners ?? []);

        if (controller.homeBannersResponse.state == NetworkState.loading) {
          return _buildLoader();
        } else if (controller.homeBannersResponse.state ==
            NetworkState.loaded) {
          if (controller.homeBanners.isNotNullOrEmpty) {
            controller.homeBanners.forEach(
              (banner) {
                bannerSwiperCards
                    .add(_buildBanners(context: context, banner: banner));
              },
            );
          }
        }

        // Don't use swiper widget if there are no banners
        if (bannerSwiperCards.isEmpty) {
          return SizedBox();
        }

        hasMultipleBanners = bannerSwiperCards.length > 1;

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: SizedBox(
            key: ValueKey(bannerSwiperCards.length),
            height: SizeConfig().screenHeight * (174 / 720),
            child: bannerSwiperCards.length == 1
                ? bannerSwiperCards.first
                : Swiper.children(
                    autoplay: hasMultipleBanners,
                    viewportFraction: SizeConfig().isTabletDevice
                        ? 0.45 // Show roughly 2 banners on tablet
                        : hasMultipleBanners
                            ? 0.9
                            : 1,
                    outer: false,
                    loop: hasMultipleBanners,
                    children: bannerSwiperCards,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBanners({BuildContext? context, DataNotificationModel? banner}) {
    if (banner == null || banner.summary.isNullOrEmpty) {
      return SizedBox();
    }

    // Use a more compact layout for tablets to show multiple banners
    final double horizontalPadding = SizeConfig().isTabletDevice
        ? 8.0 // Smaller padding for tablets to fit multiple banners
        : hasMultipleBanners
            ? 6.0
            : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              sendAnalyticEvent(banner.summary ?? "-");

              if (!ntypes.contains((banner.ntype ?? '').toLowerCase())) {
                return;
              }

              RemoteMessage message = RemoteMessage(
                data: {'ntype': banner.ntype, 'wcontext': banner.attrs},
              );
              PageRouteInfo? routeToNavigate = Get.find<NavigationController>()
                  .pushNotificationHandler(message);

              final moduleName =
                  getModuleName(routeName: routeToNavigate?.routeName ?? '');

              if (routeToNavigate != null) {
                MixPanelAnalytics.trackWithAgentId(
                  "page_viewed",
                  properties: {
                    "page_name": convertRouteToPageName(
                        routeToNavigate.routeName,
                        ntype: banner.ntype),
                    "source": "Home Banner",
                    'ntype': banner.ntype,
                    if (moduleName.isNotNullOrEmpty) "module_name": moduleName,
                    ...getDefaultMixPanelFields(routeToNavigate.routeName),
                  },
                );
                AutoRouter.of(context!).push(routeToNavigate);
              }
            },
            child: AspectRatio(
              aspectRatio: SizeConfig().isTabletDevice
                  ? 2
                  : 16 / 9, // Wider aspect ratio for tablets
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // Add a subtle border to separate banners visually
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: banner.summary!,
                    fit: BoxFit
                        .cover, // Changed from fill to cover to prevent stretching
                  ),
                ),
              ),
            ),
          ),
          if (banner.isDismissible == true)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  constraints: BoxConstraints.tightFor(width: 24, height: 24),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: () {
                    controller.dismissBanner(banner);
                    showToast(text: 'Banner Removed');
                  },
                ),
              ),
            ),
        ],
      ),
    );
    //
  }

  void sendAnalyticEvent(String url) {
    try {
      List splitBySlash = url.split('/');
      String fileName = splitBySlash[splitBySlash.length - 1].split(".").first;

      MixPanelAnalytics.trackWithAgentId(
        fileName,
        properties: {"screen_location": "home_top_banners", "screen": "Home"},
      );
    } catch (error) {
      print(error);
    }
  }

  String? extractProductType(String actionUrl) {
    String? productType;
    try {
      var queryParams = Uri.parse(actionUrl).queryParameters;
      productType = queryParams['type'];
    } catch (error) {
      LogUtil.printLog(error);
    }

    return productType;
  }

  Widget _buildLoader() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 260,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: 160,
            decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        },
      ),
    );
  }
}

// import 'package:api_sdk/log_util.dart';
// import 'package:app/src/config/constants/color_constants.dart';
// import 'package:app/src/config/constants/enums.dart';
// import 'package:app/src/config/constants/util_constants.dart';
// import 'package:app/src/config/mixpanel/mixpanel.dart';
// import 'package:app/src/config/routes/route_name.dart';
// import 'package:app/src/config/utils/extension_utils.dart';
// import 'package:app/src/config/utils/function_utils.dart';
// import 'package:app/src/controllers/home/home_controller.dart';
// import 'package:app/src/utils/shimmer_wrapper.dart';
// import 'package:app/src/utils/size_utils.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
// import 'package:get/get.dart';

// class BannerCarousel extends StatelessWidget {
//   HomeController controller = Get.find<HomeController>();
//   bool hasMultipleBanners = false;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeController>(
//       id: 'dashboard-content',
//       builder: (controller) {
//         hasMultipleBanners =
//             (controller.dashboardContent?.homeBanners?.isNotNullOrEmpty ??
//                     false) &&
//                 controller.dashboardContent!.homeBanners!.length > 1;
//         final bannerSwiperCards = <Widget>[];

//         final List bannersList = SizeConfig().isTabletDevice
//             ? (controller.dashboardContent?.homeBannersTablet ?? [])
//             : (controller.dashboardContent?.homeBanners ?? []);

//         if (controller.dashboardContentState == NetworkState.loading) {
//           return _buildLoader();
//         } else if (controller.dashboardContentState == NetworkState.loaded) {
//           if (bannersList.isNotNullOrEmpty) {
//             bannersList.forEach(
//               (banner) {
//                 bannerSwiperCards
//                     .add(_buildBanners(context: context, banner: banner));
//               },
//             );
//           }
//         }

//         // Don't use swiper widget if there are no banners
//         if (bannerSwiperCards.isEmpty) {
//           return SizedBox();
//         }

//         return SizedBox(
//           height: SizeConfig().screenHeight * (174 / 720),
//           child: Swiper.children(
//             autoplay: !hasMultipleBanners ? false : true,
//             viewportFraction: hasMultipleBanners ? 0.9 : 1,
//             outer: false,
//             loop: false,
//             // Dot Indicator
//             // pagination: SwiperPagination(
//             //   margin: EdgeInsets.only(left: 4, right: 4, top: 8),
//             //   builder: DotSwiperPaginationBuilder(
//             //     size: 5,
//             //     activeSize: 5,
//             //     activeColor: bannerSwiperCards.length <= 1
//             //         ? Colors.transparent
//             //         : ColorConstants.primaryAppColor,
//             //     color: bannerSwiperCards.length <= 1
//             //         ? Colors.transparent
//             //         : ColorConstants.primaryAppColor.withOpacity(0.16),
//             //   ),
//             // ),
//             children: bannerSwiperCards,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBanners({BuildContext? context, BannerModel? banner}) {
//     if (banner == null) {
//       return SizedBox();
//     }

//     return Padding(
//       padding: hasMultipleBanners
//           ? EdgeInsets.only(right: SizeConfig().isTabletDevice ? 30 : 6)
//           : EdgeInsets.symmetric(
//               horizontal: SizeConfig().isTabletDevice
//                   ? SizeConfig().screenWidth! * 0.1
//                   : 20,
//             ),
//       child: InkWell(
//         onTap: () {
//           sendAnalyticEvent(banner.image ?? "");

//           if (banner.isDeepLink!) {
//             try {
//               String? productType = extractProductType(banner.actionUrl!);
//               if (productType.isNotNullOrEmpty) {
//                 AutoRouter.of(context!).pushNamed(
//                     'https://applinks.buildwealth.in/store/insurance/$productType');
//               } else {
//                 if (banner.actionUrl?.endsWith(AppRouteName.storeDematScreen) ??
//                     false) {
//                   openDematStoreScreen(
//                     context: (context ?? getGlobalContext())!,
//                   );
//                 } else {
//                   AutoRouter.of(context!).pushNamed(banner.actionUrl!);
//                 }
//               }
//             } catch (error) {
//               LogUtil.printLog('error==>${error.toString()}');
//               launch(banner.actionUrl!);
//             }
//           } else {
//             launch(banner.actionUrl!);
//           }
//         },
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: CachedNetworkImage(
//             imageUrl: banner.image!,
//             fit: BoxFit.fill,
//           ),
//         ),
//       ),
//     );
//     //
//   }

//   void sendAnalyticEvent(String url) {
//     try {
//       List splitBySlash = url.split('/');
//       String fileName = splitBySlash[splitBySlash.length - 1].split(".").first;

//       MixPanelAnalytics.trackWithAgentId(
//         fileName,
//         properties: {"screen_location": "home_top_banners", "screen": "Home"},
//       );
//     } catch (error) {
//       print(error);
//     }
//   }

//   String? extractProductType(String actionUrl) {
//     String? productType;
//     try {
//       var queryParams = Uri.parse(actionUrl).queryParameters;
//       productType = queryParams['type'];
//     } catch (error) {
//       LogUtil.printLog(error);
//     }

//     return productType;
//   }

//   Widget _buildLoader() {
//     return Container(
//       height: 200,
//       child: ListView.builder(
//         itemCount: 3,
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         itemBuilder: (BuildContext context, int index) {
//           return Container(
//             width: 260,
//             margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             height: 160,
//             decoration: BoxDecoration(
//               color: ColorConstants.lightBackgroundColor,
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ).toShimmer(
//             baseColor: ColorConstants.lightBackgroundColor,
//             highlightColor: ColorConstants.white,
//           );
//         },
//       ),
//     );
//   }
// }
