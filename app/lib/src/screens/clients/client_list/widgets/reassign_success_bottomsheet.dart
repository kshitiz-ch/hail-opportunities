import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ReassignSuccessBottomsheet extends StatelessWidget {
  final List<String> clientList;
  final String employeeName;

  const ReassignSuccessBottomsheet(
      {super.key, required this.clientList, required this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24).copyWith(top: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().clientReassignSuccessIcon,
            width: 90,
            height: 90,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 20),
            child: Text(
              '${clientList.length} Client${clientList.length > 1 ? 's' : ''} have been Reassigned \nSuccesfully',
              textAlign: TextAlign.center,
              style: context.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              text: getClientAssignmentText(clientList),
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
              children: [
                TextSpan(
                  text: ' client(s) have been reassigned to ',
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
                ),
                TextSpan(
                  text: employeeName,
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          ActionButton(
            margin: EdgeInsets.zero,
            text: 'Got It',
            onPressed: () {
              AutoRouter.of(context).popUntilRouteWithName(BaseRoute.name);
            },
          )
        ],
      ),
    );
  }
}

String getClientAssignmentText(List<String> clientList) {
  // limit diplay of client names upto 5 client
  final limit = 5;

  if (clientList.length == 1) {
    return clientList.first;
  }
  final extraCount = clientList.length - limit;

  final clientNameText = clientList
      .sublist(0, extraCount > 0 ? limit : clientList.length - 1)
      .join(", ");

  final appendText =
      extraCount > 0 ? 'and $extraCount more' : 'and ${clientList.last}';

  return '$clientNameText $appendText';
}
