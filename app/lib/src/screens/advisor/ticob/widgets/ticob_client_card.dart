import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/synced_pan_model.dart';
import 'package:flutter/material.dart';

class TicobClientCard extends StatelessWidget {
  final Client selectedClient;
  final SyncedPanModel? panModel;

  const TicobClientCard({
    Key? key,
    required this.selectedClient,
    this.panModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    final subtitleStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(color: ColorConstants.tertiaryBlack);
    final panNumber = panModel?.pan ?? selectedClient.panNumber ?? '-';
    final panName = panModel == null ? '' : panModel?.name ?? '-';
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: getRandomBgColor(1),
          child: Center(
            child: Text(
              selectedClient.name?.initials ?? '',
              style: headerStyle.copyWith(color: getRandomTextColor(1)),
            ),
          ),
          radius: 21,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (selectedClient.name?.toTitleCase() ??
                    selectedClient.email ??
                    ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: headerStyle,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'CRN ${selectedClient.crn ?? '-'}',
                  style: subtitleStyle,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PAN $panNumber  ',
                    style: subtitleStyle,
                  ),
                  Expanded(
                    child: MarqueeWidget(
                      child: Text(
                        '${panName.isNullOrEmpty ? '' : '($panName)'}',
                        style: subtitleStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
