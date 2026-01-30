import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/demat/add_demat_controller.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class AttachScreenshotSection extends StatelessWidget {
  final Client? client;

  const AttachScreenshotSection({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddDematController>(
      id: 'add-demat-sc',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorConstants.secondaryWhite),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attach CMR/CML',
                style: Theme.of(context)
                    .primaryTextTheme
                    .displaySmall!
                    .copyWith(fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Attach screenshot of client’s CMR/CML details,',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w400,
                        ),
              ),
              SizedBox(
                height: 12,
              ),
              if (controller.fileName == null)
                _buildPreAttachWidget(context, controller)
              else
                _buildPostAttachWidget(context, controller)
            ],
          ),
        );
        // return controller.fileName != null
        //     // File name
        //     ? _buildPreAttachWidget(context, controller)

        //     // ATTACH SCREENSHOT Button
        //     : _buildPreAttachWidget(context, controller);
      },
    );
  }

  Widget _buildPreAttachWidget(
      BuildContext context, AddDematController controller) {
    return InkWell(
      onTap: controller.openFileExplorer,
      child: Row(
        children: [
          Transform.rotate(
            angle: 45,
            child: Icon(
              Icons.attach_file,
              color: ColorConstants.primaryAppColor,
              size: 20,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            'Attach',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  color: ColorConstants.primaryAppColor,
                  fontWeight: FontWeight.w400,
                ),
          )
        ],
      ),
    );
  }

  Widget _buildPostAttachWidget(
      BuildContext context, AddDematController controller) {
    return Row(
      children: [
        SvgPicture.asset(
          AllImages().verifiedRoundedIcon,
          width: 14,
          height: 14,
        ),
        SizedBox(
          width: 6,
        ),
        Expanded(
          flex: 1,
          child: Text(
            controller.fileName!,
            maxLines: 1,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ),
        Container(
          child: InkWell(
            onTap: controller.deleteSelectedFile,
            child: Image.asset(
              AllImages().deleteRoundedIcon,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}
