import 'package:app/src/config/constants/enums.dart';
import 'package:flutter/material.dart';

//* here Passcode term is used in referecne to loack screen password
class PassCodeContainer extends StatelessWidget {
  const PassCodeContainer(
      {Key? key, this.pinFocusNode, this.textController, this.lockScreenMode})
      : super(key: key);
  final FocusNode? pinFocusNode;
  final TextEditingController? textController;
  final LockScreenMode? lockScreenMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        if (pinFocusNode!.hasFocus &&
            MediaQuery.of(context).viewInsets.bottom == 0) {
          pinFocusNode!.unfocus();
          Future.delayed(
            const Duration(microseconds: 1),
            () => pinFocusNode!.requestFocus(),
          );
        } else {
          pinFocusNode!.requestFocus();
        }
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildPasscodeBox(textController!, context, lockScreenMode),
      ),
    );
  }
}

List<Widget> _buildPasscodeBox(TextEditingController textController,
    BuildContext context, LockScreenMode? lockScreenMode) {
  List<Widget> boxWidgets = <Widget>[];
  List passCodeEntered = textController.text.split("");

  for (int index = 0; index < 4; index++) {
    String passCodeValue = '';
    if (passCodeEntered.length > index) {
      passCodeValue = passCodeEntered[index];
    }
    boxWidgets.add(
      Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: lockScreenMode == LockScreenMode.newPassCodeMode
            ? Center(
                child: Text(
                  passCodeValue.toString(),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: 18,
                      ),
                ),
              )
            : (passCodeValue.isNotEmpty
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : SizedBox()),
      ),
    );
  }
  return boxWidgets;
}
