import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/my_team/widgets/delete_employee_bottomsheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';

class AgentCard extends StatefulWidget {
  const AgentCard({
    Key? key,
    this.agentData,
    this.isEmployee = false,
  }) : super(key: key);

  final EmployeesModel? agentData;
  final bool isEmployee;

  @override
  State<AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<AgentCard>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _animationController
        .drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));
  }

  @override
  Widget build(BuildContext context) {
    final agentEmail = widget.agentData?.email ?? '-';
    final agentPhone = widget.agentData?.phoneNumber ?? '-';
    final name = widget.agentData?.name ?? '-';

    return Container(
      color: ColorConstants.white,
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: context.headlineSmall
                      ?.copyWith(color: ColorConstants.black),
                ),
              ),
              SizedBox(width: 20),
              if (widget.isEmployee) _buildDeleteIcon()
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                agentPhone,
                style: context.titleLarge
                    ?.copyWith(color: ColorConstants.tertiaryBlack),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: CommonUI.buildProfileDataSeperator(
                  color: Color(0xffDDDDDD),
                  height: 10,
                  width: 1,
                ),
              ),
              Text(
                agentEmail,
                style: context.titleLarge
                    ?.copyWith(color: ColorConstants.tertiaryBlack),
              )
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: 'AUM',
                      subtitle: widget.agentData?.aum != null
                          ? WealthyAmount.currencyFormat(
                              widget.agentData!.aum,
                              2,
                            )
                          : "₹0",
                      titleStyle: context.titleLarge
                          ?.copyWith(color: ColorConstants.tertiaryBlack),
                      subtitleStyle: context.titleLarge?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: 'Clients',
                      subtitle:
                          (widget.agentData?.customersCount ?? 0).toString(),
                      titleStyle: context.titleLarge
                          ?.copyWith(color: ColorConstants.tertiaryBlack),
                      subtitleStyle: context.titleLarge?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: RotationTransition(
                  turns: _iconTurns,
                  child: SizedBox(
                    child: Icon(
                      Icons.expand_more,
                      size: 16,
                      color: ColorConstants.secondaryBlack,
                    ),
                  ),
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              onExpansionChanged: (isExpanding) {
                if (isExpanding) {
                  MixPanelAnalytics.trackWithAgentId(
                    "user_${widget.isEmployee ? 'employee' : 'associate'}_drop_down",
                    screen: 'my_team',
                    screenLocation: 'wealthy_trial_office',
                  );
                }
                isExpanding
                    ? _animationController.forward()
                    : _animationController.reverse();
              },
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCTA(
                        ctaText: 'View Proposals',
                        context: context,
                        onPressed: () {
                          MixPanelAnalytics.trackWithAgentId(
                            "view_proposals",
                            screen: 'my_team',
                            screenLocation: 'wealthy_office',
                          );

                          if (widget.agentData?.agentExternalId == null) {
                            showToast(text: "Proposals not found");
                          } else {
                            AutoRouter.of(context).push(ProposalListRoute(
                                employeeAgentExternalId:
                                    widget.agentData?.agentExternalId));
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildCTA(
                        ctaText: 'View Clients',
                        context: context,
                        onPressed: () {
                          AutoRouter.of(context).push(
                              ClientListRoute(employee: widget.agentData));
                        },
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA({
    required String ctaText,
    required BuildContext context,
    required Function onPressed,
  }) {
    return ActionButton(
      margin: EdgeInsets.only(bottom: 10),
      height: 32,
      text: ctaText,
      bgColor: Color(0xffF7F4FE),
      borderRadius: 6,
      textStyle:
          context.titleLarge?.copyWith(color: ColorConstants.primaryAppColor),
      onPressed: () {
        onPressed();
      },
    );
  }

  Widget _buildDeleteIcon() {
    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          isScrollControlled: false,
          child: DeleteEmployeeBottomsheet(employee: widget.agentData!),
          isDismissible: false,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Delete',
            style: context.titleLarge
                ?.copyWith(color: ColorConstants.errorTextColor),
          ),
        ],
      ),
    );
  }
}
