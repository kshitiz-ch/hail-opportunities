import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WealthyDematSection extends StatelessWidget {
  final clientDematController = Get.find<ClientDematController>();
  late List<List<String>> dematDetail;

  WealthyDematSection() {
    dematDetail = [
      [
        'Demat ID (DP ID + BO ID)',
        clientDematController.wealthyDematModel?.dematId ?? notAvailableText
      ],
      [
        'Account Type',
        (clientDematController.wealthyDematModel?.panUsageType
                ?.toCapitalized() ??
            notAvailableText)
      ],
      [
        'POA/ DDPI Status',
        clientDematController.wealthyDematModel?.poaEnabledAt == null
            ? 'Unauthorised'
            : 'Authorised'
      ],
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Wealthy Demat',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        SizedBox(height: 24),
      ]
        ..addAll(
          List<Widget>.generate(
            dematDetail.length,
            (index) => _buildDematDetail(
              title: dematDetail[index][0],
              subtitle: dematDetail[index][1],
              context: context,
              showDivider: index != (dematDetail.length - 1),
            ),
          ),
        )
        ..add(
          _buildSegmentsSection(context),
        ),
    );
  }

  Widget _buildDematDetail({
    required String title,
    required String subtitle,
    required BuildContext context,
    bool showDivider = true,
  }) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w500,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: CommonUI.buildColumnTextInfo(
              title: title,
              subtitle: subtitle,
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
          if (showDivider)
            CommonUI.buildProfileDataSeperator(
              width: double.infinity,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentsSection(BuildContext context) {
    final hasFNO = clientDematController.wealthyDematModel?.segments
            ?.contains('NSE_FNO') ==
        true;

    List<String> activeSegments = ['NSE Equity', 'Mutual Funds', 'BSE Equity'];

    if (hasFNO) {
      activeSegments.add('Future & Options');
    }

    final segmentTitleStyle =
        Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.primaryAppv3Color,
      ),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 24),
            child: Text(
              "Active Segments for your Client’s Account",
              maxLines: 2,
              style: segmentTitleStyle,
            ),
          ),
        ]
          // Active Segments
          ..addAll(
            List<Widget>.generate(
              activeSegments.length,
              (index) {
                return _buildActiveUI(context, activeSegments[index]);
              },
            ),
          )
          // Inactive Segments
          ..addAll(
            hasFNO ? <Widget>[] : _buildInactveUI(context),
          ),
      ),
    );
  }

  Widget _buildActiveUI(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.greenAccentColor,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.done,
              color: ColorConstants.white,
              size: 12,
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInactveUI(BuildContext context) {
    final segmentTitleStyle =
        Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    return <Widget>[
      // Divider
      Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
        child: LineDash(
          width: 2,
          color: ColorConstants.black.withOpacity(0.2),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Inactive Segments for your Client’s Account",
          maxLines: 2,
          style: segmentTitleStyle,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16)
            .copyWith(top: 12, bottom: 4),
        child: Text(
          'Future & Options',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.black,
              ),
        ),
      ),
      // Activate Inactive segments
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text.rich(
          TextSpan(
            text:
                'This segment is not active by default.\nPlease ask Client to activate it through Wealthy Client App',
            style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
            // TODO: uncomment when api is ready
            // children: <TextSpan>[
            // TextSpan(
            //   text: 'Tap here',
            //   style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
            //         fontWeight: FontWeight.w700,
            //         color: ColorConstants.primaryAppColor,
            //       ),
            //   recognizer: TapGestureRecognizer()
            //     ..onTap = () {
            //       // TODO:
            //       // partner cant activate fno segments
            //       // only client can activate it
            //       // share a proposal/service request to client
            //       // to activate it
            //       // update text in ActivateSegmentConfirmationBottomSheet
            //       // when this api is ready
            //       CommonUI.showBottomSheet(
            //         context,
            //         child: ActivateSegmentConfirmationBottomSheet(),
            //       );
            //     },
            // )
            // ],
          ),
        ),
      )
    ];
  }
}
