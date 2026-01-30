import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/store/insurance/insurance_controller.dart';
import 'package:app/src/screens/store/insurance_list/widgets/insurance_card_footer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;
import 'package:responsive_framework/responsive_framework.dart';

class InsuranceSection extends StatefulWidget {
  @override
  State<InsuranceSection> createState() => _InsuranceSectionState();
}

class _InsuranceSectionState extends State<InsuranceSection> {
  InsuranceController insuranceController =
      Get.isRegistered<InsuranceController>()
          ? Get.find<InsuranceController>()
          : Get.put<InsuranceController>(InsuranceController());
  ScrollController? _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController!.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return _buildInsuranceList(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.insurancesResult.products!.map<Widget>(
                  (InsuranceModel model) {
                    String productVariant =
                        model.productVariant.toString().toLowerCase();

                    // if (productVariant) {

                    // }
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () {
                          MixPanelAnalytics.trackWithAgentId(
                            "insurance_${insuranceSectionData[productVariant]!['title']}",
                            properties: {
                              "screen_location": "explore_insurance",
                              "screen": "Home",
                            },
                          );
                          AutoRouter.of(context).push(
                            InsuranceDetailRoute(
                              productVariant: productVariant,
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          height: 160,
                          decoration: BoxDecoration(
                              color: insuranceSectionData[productVariant]![
                                  'background_color'],
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Container(
                                      padding:
                                          EdgeInsets.only(left: 20, top: 20),
                                      child: Text(
                                        insuranceSectionData[productVariant]![
                                            'title'],
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: insuranceSectionData[
                                                      productVariant]![
                                                  'text_color'],
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    )),
                                    Container(
                                      margin: EdgeInsets.only(right: 6, top: 4),
                                      width: 70,
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        insuranceSectionData[productVariant]![
                                            'image_path'],
                                        // height: 80,
                                        // width: 64,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 54,
                                color: ColorConstants.white.withOpacity(0.4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: InsuranceCardFooter(
                                  productVariant: productVariant,
                                  imageRadius: 15,
                                  overlapWidth: 12,
                                  title: 'Generate Quotes',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                        height: 1.4,
                                        color: ColorConstants.black,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsuranceList(
      {required Widget child, ScrollController? scrollController}) {
    return ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ],
      child: child,
      replacement: Scrollbar(
          thumbVisibility: true, controller: scrollController, child: child),
    );
  }
}
