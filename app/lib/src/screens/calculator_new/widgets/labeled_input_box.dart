import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledInputBox<T extends num> extends StatefulWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final String labelText;
  final String suffixText;
  final double? height;

  const LabeledInputBox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.suffixText = '%',
    this.height = 40,
  }) : super(key: key);

  @override
  State<LabeledInputBox<T>> createState() => _LabeledInputBoxState<T>();
}

class _LabeledInputBoxState<T extends num> extends State<LabeledInputBox<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.suffixText.isNotEmpty
          ? '${_formatValue(widget.value)} ${widget.suffixText}'
          : _formatValue(widget.value),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // When focus is lost, validate and format
      _handleTextChanged(_controller.text);
    }
  }

  String _formatValue(T value) {
    if (T == int) {
      return value.toInt().toString();
    } else {
      return value.toDouble().toString();
    }
  }

  T _convertToT(num value) {
    if (T == int) {
      return value.toInt() as T;
    } else {
      return value.toDouble() as T;
    }
  }

  @override
  void didUpdateWidget(LabeledInputBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText = widget.suffixText.isNotEmpty
          ? '${_formatValue(widget.value)} ${widget.suffixText}'
          : _formatValue(widget.value);
      if (_controller.text != newText) {
        _controller.text = newText;
        final valueString = _formatValue(widget.value);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: valueString.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    String numericText = text;
    if (widget.suffixText.isNotEmpty) {
      numericText = text.replaceAll(widget.suffixText, '').trim();
    }

    double? parsedValue = double.tryParse(numericText);

    if (parsedValue != null) {
      final typedValue = _convertToT(parsedValue);

      // Update the value
      widget.onChanged(typedValue);

      // Format the text with suffix
      final formattedText = widget.suffixText.isNotEmpty
          ? '${_formatValue(typedValue)} ${widget.suffixText}'
          : _formatValue(typedValue);

      if (_controller.text != formattedText) {
        _controller.text = formattedText;
        final valueString = _formatValue(typedValue);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: valueString.length),
        );
      }
    } else {
      // Fallback to current value if parsing fails
      final fallbackText = widget.suffixText.isNotEmpty
          ? '${_formatValue(widget.value)} ${widget.suffixText}'
          : _formatValue(widget.value);
      if (_controller.text != fallbackText) {
        _controller.text = fallbackText;
        final valueString = _formatValue(widget.value);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: valueString.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: context.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: ColorConstants.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xffDDDDDD), width: 1),
          ),
          child: Center(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.numberWithOptions(
                decimal: T == double,
              ),
              inputFormatters: T == double
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                  : [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style:
                  context.headlineMedium?.copyWith(color: ColorConstants.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: _handleTextChanged,
              onTapOutside: (event) {
                _handleTextChanged(_controller.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
      ],
    );
  }
}
