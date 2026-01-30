import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/choose_investment_dates.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipBookCardNew extends StatefulWidget {
  SipBookCardNew({
    Key? key,
    required this.sipData,
    this.onClientView = false,
    this.fromScreen,
    this.client,
  }) : super(key: key);

  final bool onClientView;
  final SipUserDataModel sipData;
  final String? fromScreen;
  final Client? client;

  @override
  State<SipBookCardNew> createState() => _SipBookCardNewState();
}

class _SipBookCardNewState extends State<SipBookCardNew>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  bool isExpanded = false;
  List<int> allowedSipDays = [];

  Map<String, dynamic> sipStatusData = {};

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _animationController
        .drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));
    allowedSipDays = Get.find<CommonController>().allowedSipDays.toList();
    sipStatusData = _getSipStatusData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor:
            isExpanded ? ColorConstants.secondaryWhite : Colors.transparent,
        tilePadding: EdgeInsets.symmetric(
          vertical: widget.onClientView ? 6 : 12,
          horizontal: 20,
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 20).copyWith(
          bottom: widget.onClientView ? 6 : 12,
        ),
        onExpansionChanged: (value) {
          if (value) {
            MixPanelAnalytics.trackWithAgentId(
              "expand_sip_card",
              screen: widget.fromScreen ?? 'sip_book',
              screenLocation: 'sip_listing',
            );
          }
          value
              ? _animationController.forward()
              : _animationController.reverse();
          if (mounted) {
            setState(() {
              isExpanded = value;
            });
          }
        },
        title: _buildHeader(context),
        trailing: _buildTrailing(context),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildTextInfo(
                    context,
                    'Start Date',
                    getFormattedDate(widget.sipData.startDate),
                  ),
                ),
                _buildSipDays(context),
              ],
            ),
          ),
          if (widget.sipData.stepperEnabled == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildTextInfo(
                      context,
                      'Step Up Period',
                      widget.sipData.stepUpPeriodText,
                    ),
                  ),
                  _buildTextInfo(
                    context,
                    'Step Up Percentage',
                    '${widget.sipData.incrementPercentage}%',
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildTextInfo(
                    context,
                    'Last Debit',
                    widget.sipData.lastSipDate != null
                        ? getFormattedDate(widget.sipData.lastSipDate)
                        : 'N/A',
                  ),
                ),
                _buildCTAs(context),
              ],
            ),
          ),
          _buildInactiveReason(context),
          SizedBox(height: 10),
          _buildFailureReason(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.black,
          overflow: TextOverflow.ellipsis,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.onClientView)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              (widget.sipData.name ?? '-').toTitleCase(),
              style: style,
            ),
          ),
        Text(
          _getSipDisplayName() ?? 'N/A',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: style?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorConstants.tertiaryBlack,
          ),
        ),
      ],
    );
  }

  String? _getSipDisplayName() {
    if (widget.sipData.goalType == GoalType.ANY_FUNDS) {
      return widget.sipData.fundName;
    } else {
      return widget.sipData.goalName;
    }
  }

  Widget _buildSipDays(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final sipDays = widget.sipData.sipDays
        ?.split(',')
        .map((sipDay) => WealthyCast.toInt(sipDay)!)
        .toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SIP Days',
          style: style,
        ),
        SizedBox(width: 4),
        if (sipDays.isNullOrEmpty)
          Text(
            'Not Available',
            style: style?.copyWith(color: ColorConstants.black),
          ),
        ...List<Widget>.generate(
          min(2, sipDays?.length ?? 0),
          (index) {
            return Container(
              margin: EdgeInsets.only(right: 4),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ColorConstants.secondarySeparatorColor,
                ),
              ),
              child: Text(
                sipDays![index].numberPattern,
                style: style?.copyWith(color: ColorConstants.black),
              ),
            );
          },
        ),
        if ((sipDays?.length ?? 0) > 2)
          ClickableText(
            text: 'More',
            onClick: () {
              CommonUI.showBottomSheet(
                context,
                child: ChooseInvestmentDate(
                  title: 'Selected SIP days',
                  allowModification: false,
                  allowedSipDays: allowedSipDays,
                  selectedSipDays: sipDays!,
                  onUpdateSipDays: (selectedDays) {},
                ),
              );
            },
            fontWeight: FontWeight.w600,
          )
      ],
    );
  }

  Widget _buildTextInfo(
    BuildContext context,
    String text,
    String info,
  ) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: style,
        ),
        SizedBox(width: 5),
        Text(
          info,
          style: style?.copyWith(color: ColorConstants.black),
        )
      ],
    );
  }

  Map<String, dynamic> _getSipStatusData() {
    Map<String, dynamic> data = {};

    final isInactive = widget.sipData.endDate?.isBefore(DateTime.now());
    if (isInactive == true) {
      data['statusText'] = 'Inactive';
      data['color'] = ColorConstants.tertiaryBlack;
      data['image'] = AllImages().sipbookInactiveIcon;
      data['ctaText'] = 'Edit';
      data['ctaIcon'] = Icons.edit;
    } else if (widget.sipData.mandateApproved == false) {
      data['statusText'] = 'Pending eMandate ';
      data['color'] = ColorConstants.errorColor;
      data['image'] = AllImages().sipbookPendingIcon;
      data['ctaText'] = 'Edit';
      data['ctaIcon'] = Icons.edit;
    } else if (widget.sipData.isPaused == true) {
      data['statusText'] = 'Paused';
      data['color'] = ColorConstants.tangerineColor;
      data['image'] = AllImages().sipbookPausedIcon;
      data['ctaText'] = 'Resume';
      data['ctaIcon'] = Icons.play_arrow;
    } else if (widget.sipData.isSipActive == true) {
      data['statusText'] = 'Active';
      data['color'] = ColorConstants.greenAccentColor;
      data['image'] = AllImages().sipbookActiveIcon;
      data['ctaText'] = 'Pause';
      data['ctaIcon'] = Icons.pause;
    } else {
      data['statusText'] = 'Inactive';
      data['color'] = ColorConstants.tertiaryBlack;
      data['image'] = AllImages().sipbookInactiveIcon;
      data['ctaText'] = 'Edit';
      data['ctaIcon'] = Icons.edit;
    }
    return data;
  }

  Widget _buildSipStatus(BuildContext context) {
    final statusText = sipStatusData.containsKey('statusText')
        ? sipStatusData['statusText'].toString()
        : '';
    Color? color;
    String? image;
    if (statusText.isNotNullOrEmpty) {
      color = sipStatusData['color'];
      image = sipStatusData['image'];
    }
    if (statusText.isNotNullOrEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image!,
            height: 16,
            width: 16,
          ),
          SizedBox(width: 4),
          Text(
            statusText ?? '',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge
                ?.copyWith(color: color),
          )
        ],
      );
    }
    return SizedBox();
  }

  Widget _buildTrailing(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.black,
          overflow: TextOverflow.ellipsis,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              WealthyAmount.currencyFormat(widget.sipData.sipAmount, 2),
              textAlign: TextAlign.right,
              style: style,
            ),
            SizedBox(height: 8),
            _buildSipStatus(context),
          ],
        ),
        SizedBox(width: 4),
        RotationTransition(
          turns: _iconTurns,
          child: SizedBox(
            child: Icon(
              Icons.expand_more,
              size: 20,
              color: ColorConstants.secondaryBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAs(BuildContext context) {
    final sipCTAText = sipStatusData.containsKey('ctaText')
        ? sipStatusData['ctaText']
        : 'Edit';
    IconData sipCTAIcon = sipStatusData.containsKey('ctaIcon')
        ? sipStatusData['ctaIcon']
        : Icons.edit;

    final client = widget.client ??
        Client(
          name: widget.sipData.name,
          phoneNumber: widget.sipData.phoneNumber,
          taxyID: widget.sipData.userId,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableText(
          text: 'View Debits',
          onClick: () {
            MixPanelAnalytics.trackWithAgentId(
              "view_debits",
              screen: widget.fromScreen ?? 'sip_book',
              screenLocation: 'sip_listing_card',
            );
            AutoRouter.of(context).push(
              SipDetailRoute(client: client, sipUserData: widget.sipData),
            );
          },
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CommonUI.buildProfileDataSeperator(
            color: ColorConstants.secondarySeparatorColor,
            height: 18,
            width: 1,
          ),
        ),
        ClickableText(
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 2),
            height: 16,
            width: 16,
            color: ColorConstants.primaryAppColor.withOpacity(0.1),
            child: Icon(
              sipCTAIcon,
              size: 10,
              color: ColorConstants.primaryAppColor,
            ),
          ),
          text: sipCTAText,
          onClick: () {
            MixPanelAnalytics.trackWithAgentId(
              "edit_sip",
              screen: widget.fromScreen ?? 'sip_book',
              screenLocation: 'sip_listing_card',
            );
            AutoRouter.of(context).push(
              EditSipFormRoute(
                client: client,
                selectedSip: widget.sipData,
              ),
            );
          },
          fontSize: 14,
          fontWeight: FontWeight.w500,
        )
      ],
    );
  }

  Widget _buildFailureReason(BuildContext context) {
    final failureReason = widget.sipData.failureReason;
    if (failureReason.isNotNullOrEmpty) {
      return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 6),
        decoration: BoxDecoration(
          color: ColorConstants.lightYellowColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorConstants.tangerineColor),
        ),
        child: Text(
          'Last SIP debit failed due to: $failureReason',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge
              ?.copyWith(color: ColorConstants.black),
        ),
      );
    }

    return SizedBox();
  }

  Widget _buildInactiveReason(BuildContext context) {
    final isInactive = widget.sipData.endDate?.isBefore(DateTime.now());
    if (isInactive == true) {
      return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 6),
        decoration: BoxDecoration(
          color: ColorConstants.tertiaryBlack.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'The end date for this SIP has passed.',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge
              ?.copyWith(color: ColorConstants.black),
        ),
      );
    }

    return SizedBox();
  }
}
