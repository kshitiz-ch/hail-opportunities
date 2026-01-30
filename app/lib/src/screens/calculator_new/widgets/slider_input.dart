import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/calculator_new/widgets/custom_slider_thumb_shape.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliderInput<T extends num> extends StatefulWidget {
  final String label;
  final T value;
  final ValueChanged<T> onChanged;
  final T min;
  final T max;
  final T? step;
  final String valuePrefix;
  final String? valueSuffix;
  final bool showToggle;
  final bool? initialToggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const SliderInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.step,
    this.valuePrefix = '₹',
    this.valueSuffix = '',
    this.showToggle = false,
    this.initialToggleValue,
    this.onToggleChanged,
  });

  @override
  State<SliderInput<T>> createState() => _SliderInputState<T>();
}

class _SliderInputState<T extends num> extends State<SliderInput<T>> {
  late TextEditingController _textController;
  late bool _isTextFieldEnabled;
  late FocusNode _focusNode;

  int? get _divisions {
    if (widget.step != null) {
      return ((widget.max.toDouble() - widget.min.toDouble()) /
              widget.step!.toDouble())
          .round();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _isTextFieldEnabled = widget.initialToggleValue ?? true;
    _textController = TextEditingController(
      text:
          '${widget.valuePrefix}${_formatValue(widget.value)}${widget.valueSuffix}',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // When focus is lost, validate and format
      _handleTextChanged(_textController.text);
    }
  }

  String _formatValue(T value) {
    String formattedValue;
    if (T == int) {
      formattedValue = value.toInt().toString();
    } else {
      formattedValue = value.toDouble().toString();
    }

    // Apply comma formatting if valuePrefix is ₹
    if (widget.valuePrefix.trim() == '₹') {
      formattedValue = WealthyAmount.formatNumber(formattedValue);
    }

    return formattedValue;
  }

  T _convertToT(num value) {
    if (T == int) {
      return value.toInt() as T;
    } else {
      return value.toDouble() as T;
    }
  }

  @override
  void didUpdateWidget(SliderInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText =
          '${widget.valuePrefix}${_formatValue(widget.value)}${widget.valueSuffix}';
      if (_textController.text != newText) {
        _textController.text = newText;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSliderChanged(double newValue) {
    double clampedValue =
        newValue.clamp(widget.min.toDouble(), widget.max.toDouble());

    // If step is provided, round to nearest step
    if (widget.step != null) {
      final stepValue = widget.step!.toDouble();
      final minValue = widget.min.toDouble();
      clampedValue =
          ((clampedValue - minValue) / stepValue).round() * stepValue +
              minValue;
      // Clamp again to ensure we're within bounds after rounding
      clampedValue =
          clampedValue.clamp(widget.min.toDouble(), widget.max.toDouble());
    }

    final typedValue = _convertToT(clampedValue);

    setState(() {
      _textController.text =
          '${widget.valuePrefix}${_formatValue(typedValue)}${widget.valueSuffix}';
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
    });
    widget.onChanged(typedValue);
  }

  void _handleTextChanged(String text) {
    String numericText = text.replaceAll(widget.valuePrefix, '');
    if (widget.valueSuffix != null && widget.valueSuffix!.isNotEmpty) {
      numericText = numericText.replaceAll(widget.valueSuffix!, '');
    }
    // Remove commas for parsing
    numericText = numericText.replaceAll(',', '').trim();

    double? parsedValue = double.tryParse(numericText);

    if (parsedValue != null) {
      // For currency (₹) and percentage (%), allow values greater than max
      // For other inputs, clamp to max
      final bool isCurrency = widget.valuePrefix.trim() == '₹';
      final bool isPercentage = widget.valueSuffix?.trim() == '%';

      double clampedValue;
      if (isCurrency || isPercentage) {
        // For currency and percentage, allow min 0 and no upper limit
        clampedValue = parsedValue < 0 ? 0 : parsedValue;
      } else {
        // For other inputs, enforce both min and max
        clampedValue =
            parsedValue.clamp(widget.min.toDouble(), widget.max.toDouble());
      }

      final typedValue = _convertToT(clampedValue);

      if (widget.value != typedValue) {
        widget.onChanged(typedValue);
      }

      final formattedText =
          '${widget.valuePrefix}${_formatValue(typedValue)}${widget.valueSuffix}';
      if (_textController.text != formattedText) {
        _textController.text = formattedText;
        _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length));
      }
    } else {
      final fallbackText =
          '${widget.valuePrefix}${_formatValue(widget.value)}${widget.valueSuffix}';
      if (_textController.text != fallbackText) {
        _textController.text = fallbackText;
        _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expectedText =
        '${widget.valuePrefix}${_formatValue(widget.value)}${widget.valueSuffix}';
    if (_textController.text != expectedText &&
        !FocusScope.of(context).hasFocus) {
      _textController.text = expectedText;
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 2,
                        style: context.headlineSmall?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.showToggle) ...[
                      const SizedBox(width: 12),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isTextFieldEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isTextFieldEnabled = value;
                            });
                            widget.onToggleChanged?.call(value);
                          },
                          activeColor: ColorConstants.primaryAppColor,
                          activeTrackColor:
                              ColorConstants.primaryAppColor.withOpacity(0.5),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xffDDDDDD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: _isTextFieldEnabled,
                  textAlign: TextAlign.center,
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isTextFieldEnabled
                        ? ColorConstants.black
                        : ColorConstants.black.withOpacity(0.4),
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: T == double, signed: false),
                  inputFormatters: T == double
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                      : [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  onSubmitted: _handleTextChanged,
                  onTapOutside: (event) {
                    _handleTextChanged(_textController.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _isTextFieldEnabled
                ? ColorConstants.primaryAppColor
                : ColorConstants.borderColor.withOpacity(0.5),
            inactiveTrackColor: ColorConstants.borderColor.withOpacity(0.5),
            trackHeight: 2.0,
            thumbShape: CustomSliderThumbShape(
              thumbColor: _isTextFieldEnabled
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.borderColor.withOpacity(0.7),
              enabledThumbRadius: 9,
              disabledThumbRadius: 9,
            ),
            overlayColor: ColorConstants.primaryAppColor.withAlpha(50),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: widget.value
                .toDouble()
                .clamp(widget.min.toDouble(), widget.max.toDouble()),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: _divisions,
            onChanged: _isTextFieldEnabled ? _handleSliderChanged : null,
          ),
        ),
      ],
    );
  }
}
