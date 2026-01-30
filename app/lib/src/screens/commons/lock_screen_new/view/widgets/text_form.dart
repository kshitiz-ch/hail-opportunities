import 'package:app/src/config/constants/enums.dart';
import 'package:flutter/material.dart';

import 'dashes.dart';
import 'hidden_text_form.dart';
import 'pin_input.dart';

class TextForm extends StatefulWidget {
  const TextForm(
      {Key? key,
      this.passcodeInputController,
      this.pinFocusNode,
      this.onChange,
      this.digits,
      this.correctString,
      this.lockScreenMode})
      : super(key: key);

  final TextEditingController? passcodeInputController;
  final FocusNode? pinFocusNode;
  final Function? onChange;
  final int? digits;
  final String? correctString;
  final LockScreenMode? lockScreenMode;

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.passcodeInputController!.addListener(() {
      String text = widget.passcodeInputController!.text;
      if (text.length == widget.digits &&
          text != widget.correctString &&
          widget.lockScreenMode == LockScreenMode.currentPassCodeMode) {
        _animationController.forward();
      }
    });
    //* Showing shaking dashes / password input when input is wrong

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    _animation = _animationController
        .drive(CurveTween(curve: Curves.elasticIn))
        .drive(Tween<Offset>(begin: Offset.zero, end: Offset(0.06, 0)))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Column(children: [
        HiddenTextForm(
            textController: widget.passcodeInputController,
            pinFocusNode: widget.pinFocusNode,
            onChanged: widget.onChange),
        PassCodeContainer(
            pinFocusNode: widget.pinFocusNode,
            textController: widget.passcodeInputController,
            lockScreenMode: widget.lockScreenMode),
        Dashes(
            textController: widget.passcodeInputController,
            totalDashes: widget.digits),
      ]),
    );
  }
}
