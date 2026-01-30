import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/insurance/insurance_home_controller.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/insurance_home/widgets/insurance_banner_carousel.dart';
import 'package:app/src/screens/store/insurance_home/widgets/insurance_product_section.dart';
import 'package:app/src/screens/store/insurance_home/widgets/more_insurance_banners.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_video_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class InsuranceHomeScreen extends StatefulWidget {
  @override
  State<InsuranceHomeScreen> createState() => _InsuranceHomeScreenState();
}

class _InsuranceHomeScreenState extends State<InsuranceHomeScreen> {
  final storeController =
      Get.isRegistered<StoreController>() ? Get.find<StoreController>() : null;
  final ScrollController scrollController = ScrollController();
  double _scrollPosition = 0;
  bool showScrollAppBar = false;

  _scrollListener() {
    if (this.mounted) {
      _scrollPosition = scrollController.position.pixels;
      if (showScrollAppBar && _scrollPosition == 0) {
        showScrollAppBar = false;
        setState(() {});
      }
      if (!showScrollAppBar && _scrollPosition > 0) {
        showScrollAppBar = true;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceHomeController>(
      init: InsuranceHomeController(),
      dispose: (_) => Get.delete<InsuranceHomeController>(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Insurance',
            subtitleText: 'All your protection needs under one roof',
          ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ProductVideoCard(
                    productType: "insurance",
                    isProductVideoViewed: false,
                    video: AdvisorVideoModel.fromJson(
                      {"link": "https://youtu.be/BFAcrd8ZJRQ"},
                    ),
                    currentRoute: InsuranceHomeRoute.name,
                  ),
                ),
                InsuranceBannerCarousel(),
                InsuranceProductSection(),
                SizedBox(height: 32),
                MoreInsuranceBanners(),
                _buildLookingForInsuranceBg()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLookingForInsuranceBg() {
    return SafeArea(
      child: Column(
        children: [
          Center(
            child: Text(
              'Looking for Insurance?',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: ColorConstants.tertiaryBlack,
                      ),
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Let us ',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: ColorConstants.black,
                        ),
                children: [
                  TextSpan(
                    text: 'Quote ',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: ColorConstants.black,
                        ),
                  ),
                  TextSpan(
                    text: 'you Happy ',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: ColorConstants.black,
                        ),
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ActionButton(
          //   onPressed: () {
          //   },
          //   text: 'Explore all Products',
          //   bgColor: Colors.white,
          //   margin: EdgeInsets.symmetric(vertical: 32, horizontal: 75),
          //   textStyle:
          //       Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
          //             fontWeight: FontWeight.w700,
          //             color: ColorConstants.primaryAppColor,
          //           ),
          // ),
          Image.asset(
            AllImages().insuranceHomeLandingIcon,
            height: 270,
            width: SizeConfig().screenWidth,
            fit: BoxFit.fill,
          ),
        ],
      ),
    );
  }
}
