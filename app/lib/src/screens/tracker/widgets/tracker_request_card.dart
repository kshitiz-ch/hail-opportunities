import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackerRequestCard extends StatelessWidget {
  final TrackerModel tracker;
  final int effectiveIndex;

  const TrackerRequestCard(
      {Key? key, required this.tracker, required this.effectiveIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildClientLogo(context),
          SizedBox(width: 12),
          Expanded(child: _buildClientDetails(context)),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: _buildStatusWidget(tracker.status, context),
          )
        ],
      ),
    );
  }

  Widget _buildDateTimeText(
      DateTime date, String dateText, BuildContext context) {
    return Text(
      '$dateText at ${DateFormat('MMM d yyy').format(date)}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            color: ColorConstants.tertiaryBlack,
            height: 1.4,
          ),
    );
  }

  Widget _buildStatusWidget(int? status, BuildContext context) {
    String backgroundColor;
    String textColor;
    late String statusDescription;

    switch (status) {
      case TrackerRequestStatus.RequestedToCustomer:
        statusDescription = 'Requested';
        backgroundColor = "#FFF8EA";
        textColor = "#FFBF00";
        break;
      case TrackerRequestStatus.InProgress:
        statusDescription = 'In Progress';
        backgroundColor = "#F9F9F9";
        textColor = "#1C1C1C";
        break;
      case TrackerRequestStatus.Completed:
        statusDescription = 'Completed';
        backgroundColor = "#E9FFEF";
        textColor = "#4FC16F";
        break;
      case TrackerRequestStatus.Failure:
        statusDescription = 'Failure';
        backgroundColor = "#ffe8e5";
        textColor = "#e64500";
        break;
      default:
        backgroundColor = "#f5f6f8";
        textColor = "#787a8b";
    }

    return Container(
      padding: EdgeInsets.fromLTRB(11, 6, 11, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: hexToColor(backgroundColor),
      ),
      child: Center(
        child: Text(
          statusDescription,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: hexToColor(textColor),
              ),
        ),
      ),
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    Widget dateTimeWidget;

    if (tracker.completedAt != null) {
      dateTimeWidget =
          _buildDateTimeText(tracker.completedAt!, "Completed", context);
    } else if (tracker.failedAt != null) {
      dateTimeWidget = _buildDateTimeText(tracker.failedAt!, "Failed", context);
    } else if (tracker.markedInProgressAt != null) {
      dateTimeWidget = _buildDateTimeText(
          tracker.markedInProgressAt!, "Marked progress", context);
    } else if (tracker.createdAt != null) {
      dateTimeWidget =
          _buildDateTimeText(tracker.createdAt!, "Created", context);
    } else {
      dateTimeWidget = SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tracker.customer == null
              ? ''
              : tracker.customer!.name.isNotNullOrEmpty
                  ? (tracker.customer?.name ?? '').toTitleCase()
                  : tracker.customer!.email!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
        dateTimeWidget
      ],
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          tracker.customer!.name.toString().isEmpty
              ? getInitials(tracker.customer?.email ?? '').toUpperCase()
              : getInitials(tracker.customer?.name ?? '').toUpperCase(),
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 21,
    );
  }
}
