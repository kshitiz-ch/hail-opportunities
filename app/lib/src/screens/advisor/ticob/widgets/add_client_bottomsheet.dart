import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class AddClientBottomSheet extends StatelessWidget {
  final Client selectedClient;

  const AddClientBottomSheet({Key? key, required this.selectedClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Client',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 30),
            child: Text(
              'Ravindra Kumar is not added as a client yet. \nAdd as a client now to Change Broker ',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }
}
