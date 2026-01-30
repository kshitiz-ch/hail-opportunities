import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/choose_investment_dates.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/offline_sip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineSipBookCard extends StatefulWidget {
  final OfflineSipModel sipData;

  const OfflineSipBookCard({Key? key, required this.sipData}) : super(key: key);

  @override
  State<OfflineSipBookCard> createState() => _OfflineSipBookCardState();
}

class _OfflineSipBookCardState extends State<OfflineSipBookCard>
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
          vertical: 12,
          horizontal: 20,
        ),
        childrenPadding:
            EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        onExpansionChanged: (value) {
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
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextInfo(
                    context,
                    'Frequency',
                    widget.sipData.frequencyText,
                  ),
                ),
                SizedBox(width: 20),
                _buildSipDays(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextInfo(
                  context,
                  'Start Date',
                  getFormattedDate(widget.sipData.startDate),
                ),
                SizedBox(width: 12),
                _buildTextInfo(
                  context,
                  'End Date',
                  getFormattedDate(widget.sipData.endDate),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextInfo(
                  context,
                  'Registration Date',
                  widget.sipData.regDate == null
                      ? 'N/A'
                      : getFormattedDate(widget.sipData.regDate),
                ),
                SizedBox(width: 12),
                _buildTextInfo(
                  context,
                  'Termination Date',
                  widget.sipData.terminationDate == null
                      ? 'N/A'
                      : getFormattedDate(widget.sipData.terminationDate),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTextInfo(
              context,
              'Monthly Contribution: ',
              '~${WealthyAmount.currencyFormat(widget.sipData.monthlyAmount, 2)}',
            ),
          ),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            (widget.sipData.name ?? 'N/A').toTitleCase(),
            style: style,
          ),
        ),
        Text(
          (widget.sipData.schemeName ?? 'N/A').toTitleCase(),
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

  Widget _buildSipDays(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final sipDays = widget.sipData.sipDaysList;

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
            'N/A',
            style: style?.copyWith(color: ColorConstants.black),
          ),
        ...List<Widget>.generate(
          min(2, sipDays.length),
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
                sipDays[index].numberPattern,
                style: style?.copyWith(color: ColorConstants.black),
              ),
            );
          },
        ),
        if (sipDays.length > 2)
          ClickableText(
            text: 'More',
            onClick: () {
              CommonUI.showBottomSheet(
                context,
                child: ChooseInvestmentDate(
                  title: 'Selected SIP days',
                  allowModification: false,
                  allowedSipDays: allowedSipDays.toList(),
                  selectedSipDays: sipDays,
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
        color: ColorConstants.tertiaryBlack, overflow: TextOverflow.ellipsis);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: style,
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            info,
            style: style?.copyWith(color: ColorConstants.black),
            maxLines: 2,
          ),
        )
      ],
    );
  }

  Map<String, dynamic> _getSipStatusData() {
    Map<String, dynamic> data = {};

    final isInactive = widget.sipData.isInActive;
    if (isInactive == true) {
      data['statusText'] = 'Inactive';
      data['color'] = ColorConstants.tertiaryBlack;
      data['image'] = AllImages().sipbookInactiveIcon;
      data['ctaText'] = 'Edit';
      data['ctaIcon'] = Icons.edit;
    } else if (widget.sipData.isPaused == true) {
      data['statusText'] = 'Paused';
      data['color'] = ColorConstants.tangerineColor;
      data['image'] = AllImages().sipbookPausedIcon;
      data['ctaText'] = 'Resume';
      data['ctaIcon'] = Icons.play_arrow;
    } else if (widget.sipData.isActive == true) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              WealthyAmount.currencyFormat(widget.sipData.amount, 2),
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
}
