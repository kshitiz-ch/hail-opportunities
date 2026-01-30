import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

final wealthyAddress =
    'PN PLAZA, 1090/B, Ground Floor,\n18th Cross road, 3rd sector, HSR Layout\nBengaluru, 560102, Karnataka, India ';

class CobSteps extends StatelessWidget {
  final stepList = [
    {
      'image': AllImages().ticobProcessIcon1,
      'title': 'Generate Change of Broker form',
    },
    {
      'image': AllImages().ticobProcessIcon2,
      'title': 'Get this form signed by \nrespective Client',
    },
    {
      'image': AllImages().ticobProcessIcon3,
      'title': 'Courier Signed COB to \nWealthy office ',
      'subtitle': wealthyAddress,
    },
    {
      'image': AllImages().ticobProcessIcon4,
      'title':
          'After validation wealthy operations team \nwill forward form to respective AMCs',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return _buildCOBProcessSteps(context);
  }

  Widget _buildCOBProcessSteps(BuildContext context) {
    return ListTileTheme(
      dense: true,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: ColorConstants.secondarySeparatorColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          collapsedShape: RoundedRectangleBorder(
            side: BorderSide(
                color: ColorConstants.secondarySeparatorColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          initiallyExpanded: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AllImages().ticobInfoIcon2,
                height: 16,
                width: 16,
              ),
              SizedBox(width: 6),
              Text(
                'How is the Process ?',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
            ],
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: EdgeInsets.only(bottom: 20),
          children: [
            CommonUI.buildProfileDataSeperator(
                color: ColorConstants.secondarySeparatorColor),
            ...stepList
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(top: 20),
                    child: _buildProcessStepUI(context, step),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStepUI(BuildContext context, Map<String, String> data) {
    final image = data['image'];
    final title = data['title'];
    final subtitle = data['subtitle'];
    final style = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.copyWith(color: ColorConstants.black);
    return Row(
      children: [
        Image.asset(image ?? '', height: 32, width: 32),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? '',
                style: style,
              ),
              if (subtitle.isNotNullOrEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    subtitle ?? '',
                    style: style?.copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ),
              if (subtitle.isNotNullOrEmpty)
                ClickableText(
                  prefixIcon: Icon(
                    Icons.copy,
                    size: 20,
                    color: ColorConstants.primaryAppColor,
                  ),
                  text: 'Copy',
                  textColor: ColorConstants.primaryAppColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  onClick: () {
                    copyData(data: subtitle);
                  },
                )
            ],
          ),
        )
      ],
    );
  }
}
