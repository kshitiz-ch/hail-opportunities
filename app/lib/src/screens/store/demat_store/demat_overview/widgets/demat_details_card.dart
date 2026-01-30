import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DematDetailsCard extends StatelessWidget {
  const DematDetailsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: 30, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Broking Plan',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.tertiaryBlack,
                      ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryCardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AllImages().storeDematIcon,
                          width: 24,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          controller.planSelected?.planName ?? "-",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 55),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnInfoText(
                          context,
                          title: WealthyAmount.currencyFormat(
                              controller.planSelected?.openingCharges ?? 0, 0),
                          subtitle: 'Opening Charges',
                        ),
                        // Column(
                        //   children: [
                        //     _buildColumnInfoText(
                        //       context,
                        //       title:
                        //           "${controller.dematDetails?.pricingPlan?.amcCharges ?? WealthyAmount.currencyFormat(0, 0)}*",
                        //       subtitle: 'AMC',
                        //     ),
                        //     Text(
                        //       '(*for first year)',
                        //       style: Theme.of(context)
                        //           .primaryTextTheme
                        //           .headlineSmall!
                        //           .copyWith(
                        //             color: ColorConstants.secondaryBlack,
                        //             fontWeight: FontWeight.w600,
                        //             height: 2,
                        //             fontSize: 11,
                        //           ),
                        //     ),
                        //   ],
                        // ),
                        _buildColumnInfoText(
                          context,
                          title: WealthyAmount.currencyFormat(
                              controller.planSelected?.amcCharges, 0),
                          subtitle: 'Amc Charges',
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumnInfoText(BuildContext context,
      {required String title, required String subtitle}) {
    return CommonUI.buildColumnTextInfo(
      crossAxisAlignment: CrossAxisAlignment.center,
      title: WealthyAmount.currencyFormat(0, 0),
      subtitle: subtitle,
      gap: 8,
      titleStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
      subtitleStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w400,
            color: ColorConstants.tertiaryGrey,
            overflow: TextOverflow.ellipsis,
          ),
    );
  }
}
