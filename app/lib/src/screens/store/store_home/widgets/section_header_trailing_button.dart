import 'package:flutter/material.dart';

class SectionHeaderTrailingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SectionHeaderTrailingButton({
    Key? key,
    this.text = 'SEE ALL',
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.0,
      child: TextButton(
        child: Text(text),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
          fixedSize: Size.fromHeight(24.0),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
