import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HiddenTextForm extends StatelessWidget {
  const HiddenTextForm(
      {Key? key, this.textController, this.pinFocusNode, this.onChanged})
      : super(key: key);
  final TextEditingController? textController;
  final FocusNode? pinFocusNode;
  final Function? onChanged;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true, // disable tap on the text field
      child: TextFormField(
        textInputAction: TextInputAction.done,
        controller: textController,
        focusNode: pinFocusNode,
        enabled: true,
        autofocus: false,
        keyboardType: TextInputType.number,
        onChanged: onChanged as void Function(String)?,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(
            4,
          ),
        ],
        showCursor: false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: InputBorder.none,
          fillColor: ColorConstants.lightGrey,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        style: TextStyle(
            color: Colors.transparent,
            height: .01,
            fontSize: kIsWeb ? 1 : 0.01),
      ),
    );
  }
}
