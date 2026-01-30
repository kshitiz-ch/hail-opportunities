import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  // Fields
  final String? errorMessage;
  final VoidCallback? onPressed;

  // Controller
  const RetryWidget(
    this.errorMessage, {
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              errorMessage!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium!
                  .copyWith(fontSize: deviceSpecificValue(context, 10, 14)),
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.replay_rounded,
                color: ColorConstants.primaryAppColor,
              ),
              onPressed: onPressed,
            ),
          )
        ],
      ),
    );
  }
}
