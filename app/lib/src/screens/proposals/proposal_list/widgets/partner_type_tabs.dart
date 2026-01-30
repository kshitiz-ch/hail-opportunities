import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/bottomsheet/partner_office_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerTypeTabs extends StatelessWidget {
  const PartnerTypeTabs({Key? key, this.partnerFirstName}) : super(key: key);

  final String? partnerFirstName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProposalsController>(builder: (controller) {
      String? partnerOfficeEmployeeName;

      if (controller.partnerType == PartnerType.Office) {
        partnerOfficeEmployeeName =
            getPartnerOfficeEmployeeName(controller.partnerEmployeeSelected);
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (controller.partnerType != PartnerType.Self) {
                    controller.partnerType = PartnerType.Self;
                    controller.updateTabStatus('ALL');
                    controller.updateSelectedProductCategory('All');
                    controller.getProposals();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: controller.partnerType == PartnerType.Self
                              ? ColorConstants.primaryAppColor
                              : ColorConstants.white),
                    ),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: MarqueeWidget(
                      child: Text(
                        '$partnerFirstName Proposals',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displayMedium!
                            .copyWith(
                                fontSize: 14,
                                color:
                                    controller.partnerType == PartnerType.Self
                                        ? ColorConstants.black
                                        : ColorConstants.tertiaryBlack),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "employee_filter",
                    screen: 'proposals',
                    screenLocation: 'proposals',
                  );
                  CommonUI.showBottomSheet(
                    context,
                    child: PartnerOfficeBottomSheet(
                      title: 'Show Proposals of',
                      onEmployeeSelect:
                          (EmployeesModel? employee, agentExternalIdList) {
                        controller.partnerEmployeeSelected = employee;
                        controller.partnerType = PartnerType.Office;
                        controller.updateTabStatus('ALL');
                        controller.updateSelectedProductCategory('All');
                        controller.getProposals();
                      },
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: controller.partnerType == PartnerType.Office
                              ? ColorConstants.primaryAppColor
                              : ColorConstants.white),
                    ),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: MarqueeWidget(
                            child: Text(
                              '${partnerOfficeEmployeeName ?? 'My Team'}\'s Proposals',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontSize: 14,
                                      color: controller.partnerType ==
                                              PartnerType.Office
                                          ? ColorConstants.black
                                          : ColorConstants.tertiaryBlack),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: controller.partnerType == PartnerType.Office
                            ? ColorConstants.black
                            : ColorConstants.tertiaryBlack,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
