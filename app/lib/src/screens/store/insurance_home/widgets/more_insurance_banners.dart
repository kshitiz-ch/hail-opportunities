import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/insurance/insurance_home_controller.dart';
import 'package:app/src/screens/store/insurance_home/widgets/insurance_banner_carousel.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class MoreInsuranceBanners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceHomeController>(
      builder: (controller) {
        if (controller.insuranceBannerState == NetworkState.loading) {
          return buildInsuranceBannerShimmer();
        }
        if (controller.insuranceBannerState == NetworkState.error) {
          return Center(
            child: RetryWidget(
              controller.insuranceBannerErrorMessage ?? genericErrorMessage,
              onPressed: () {
                controller.getInsuranceBanner();
              },
            ),
          );
        }
        final bannerList = controller.insuranceBanners
            .where((banner) => !banner.isCarousel!)
            .toList();

        if (bannerList.isNullOrEmpty) {
          return SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'More Insurance',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
              ),
            ),
          ]
            ..addAll(
              bannerList
                  .map<Widget>(
                    (banner) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig().isTabletDevice
                            ? SizeConfig().screenWidth! * 0.1
                            : 20,
                      ).copyWith(top: 12),
                      child: InkWell(
                        onTap: () {
                          // Temporary requirement
                          if (banner.name == "term-insurance" &&
                              banner.actionUrl.isNullOrEmpty) {
                            _openInsuranceProposalUrl(controller, context);
                          } else {
                            if (banner.actionUrl.isNotNullOrEmpty) {
                              if (banner.isDeepLink!) {
                                try {
                                  AutoRouter.of(context)
                                      .pushNamed(banner.actionUrl!);
                                } catch (error) {
                                  LogUtil.printLog(
                                      'error==>${error.toString()}');
                                  launch(banner.actionUrl!);
                                }
                              } else {
                                launch(banner.actionUrl!);
                              }
                            }
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: banner.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
            ..add(
              SizedBox(height: 48),
            ),
        );
      },
    );
  }

  void _openInsuranceProposalUrl(
      InsuranceHomeController controller, BuildContext context) async {
    InsuranceModel termInsuranceProduct = InsuranceModel.fromJson({
      'category': 'Insure',
      'product_type': 'general',
      'product_variant': 'term'
    });

    String termInsuranceDeepLink =
        'https://applinks.buildwealth.in/store/insurance/term';

    try {
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );

      String? proposalUrl =
          await controller.getProposalUrl(termInsuranceProduct, context);

      if (proposalUrl.isNotNullOrEmpty) {
        showToast(text: "Opening Term Insurance");
        if (!isPageAtTopStack(context, InsuranceWebViewRoute.name)) {
          bool shouldHandleAppBar = true;
          if (!SizeConfig().isTabletDevice) {
            shouldHandleAppBar = false;
          }
          AutoRouter.of(context).push(
            InsuranceWebViewRoute(
              url: proposalUrl,
              shouldHandleAppBar: shouldHandleAppBar,
              onNavigationRequest: (
                InAppWebViewController controller,
                NavigationAction action,
              ) async {
                final navigationUrl = action.request.url.toString();
                if (navigationUrl.contains("applinks.buildwealth.in")) {
                  if (navigationUrl ==
                      "https://applinks.buildwealth.in/proposals") {
                    navigateToProposalScreen(context);
                  } else {
                    AutoRouter.of(context).popForced();
                  }
                  return NavigationActionPolicy.CANCEL;
                } else {
                  return NavigationActionPolicy.ALLOW;
                }
              },
            ),
          );
        }
      } else {
        // Fallback if something goes wrong
        AutoRouter.of(context).pushNamed(termInsuranceDeepLink);
      }
    } catch (error) {
      // Fallback if something goes wrong
      AutoRouter.of(context).pushNamed(termInsuranceDeepLink);
    } finally {
      AutoRouter.of(context).popForced();
    }
  }
}
