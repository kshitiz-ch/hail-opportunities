import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/my_business/business_graph_controller.dart';
import 'package:app/src/screens/my_business/widgets/business_graph_section.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const tag = 'home-business';

class HomeBusinessSection extends StatelessWidget {
  final bool hasLimitedAccess;

  const HomeBusinessSection({Key? key, this.hasLimitedAccess = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessGraphController>(
      init: BusinessGraphController(hasLimitedAccess),
      tag: tag,
      autoRemove: false,
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        AutoRouter.of(context).push(MyBusinessRoute());
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Business Summary',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: ColorConstants.black,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    ClickableText(
                      onClick: () {
                        MixPanelAnalytics.trackWithAgentId(
                          "business_summary_view_details",
                          properties: {
                            "screen_location": "business_summary",
                            "screen": "Home",
                          },
                        );
                        AutoRouter.of(context).push(MyBusinessRoute());
                      },
                      text: 'View Details',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    // PartnerOfficeDropdown(
                    //   tag: 'home-business',
                    //   title: controller.selectedTab,
                    //   onEmployeeSelect:
                    //       controller.updatePartnerEmployeeSelected,
                    //   canSelectAllEmployees: true,
                    //   canSelectPartnerOffice: true,
                    // ),
                  ],
                ),
              ),
              BusinessGraphSection(tag: tag),
              // if (isLoaded)
              //   ColoredBox(
              //     color: ColorConstants.secondaryAppColor,
              //     child: ActionButton(
              //       margin: EdgeInsets.symmetric(vertical: 20, horizontal: 66),
              //       text: 'View Business Summary',
              //       bgColor: ColorConstants.white,
              //       textStyle: Theme.of(context)
              //           .primaryTextTheme
              //           .headlineSmall
              //           ?.copyWith(
              //             fontWeight: FontWeight.w700,
              //             color: ColorConstants.primaryAppColor,
              //           ),
              //       borderRadius: 8,
              //       suffixWidget: Icon(
              //         Icons.arrow_forward_outlined,
              //         color: ColorConstants.primaryAppColor,
              //       ),
              //       onPressed: () {
              //         AutoRouter.of(context).push(
              //             MyBusinessRoute(hasLimitedAccess: hasLimitedAccess));
              //       },
              //     ),
              //   )
            ],
          ),
        );
      },
    );
  }
}
