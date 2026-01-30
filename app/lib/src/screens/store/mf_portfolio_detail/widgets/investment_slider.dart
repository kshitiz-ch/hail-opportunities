import 'dart:math' as math;

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/portfolio_return_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InvestmentSlider extends StatelessWidget {
  final FundReturnInputType inputType;

  InvestmentSlider({
    Key? key,
    required this.inputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioReturnController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investment ${inputType == FundReturnInputType.Amount ? 'Amount' : 'Period'}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Spacer(),
                _buildTextField(context, controller)
              ],
            ),
            SizedBox(height: 20),
            _buildSlider(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    PortfolioReturnController controller,
  ) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              height: 18 / 16,
            );

    late TextEditingController textController;
    String? errorMessage;
    int maxLength = 11;

    final width = 120.0;
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorConstants.primaryAppColor,
      ),
      borderRadius: BorderRadius.circular(4),
    );
    if (inputType == FundReturnInputType.Amount) {
      textController = controller.amountController;
      errorMessage = controller.amountErrorText;
      // 1,00,00,000
      maxLength = 11;
    } else {
      textController = controller.periodController;
      errorMessage = controller.periodErrorText;
      // 40
      maxLength = 2;
    }
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            textAlign: TextAlign.center,
            controller: textController,
            keyboardType: TextInputType.number,
            style: textStyle,
            inputFormatters: [
              NoLeadingSpaceFormatter(),
              LengthLimitingTextInputFormatter(maxLength),
              NoLeadingZeroFormatter()
            ],
            focusNode: inputType == FundReturnInputType.Period
                ? controller.periodFocusNode
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorConstants.primaryAppv3Color,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              focusedBorder: inputBorder,
              border: inputBorder,
              enabledBorder: inputBorder,
              constraints: BoxConstraints(maxHeight: 35, minHeight: 35),
            ),
            onChanged: (value) {
              controller.updateReturnFromTextField(inputType, value);
            },
            validator: (value) {
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          if (errorMessage.isNotNullOrEmpty)
            Text(
              errorMessage!,
              maxLines: 3,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.errorTextColor,
                  ),
            )
        ],
      ),
    );
  }

  /// Builds the slider widget for portfolio investment amount or period selection
  ///
  /// This method creates a custom slider with:
  /// - Dynamic min/max values based on the input type (Amount or Period)
  /// - Custom thumb shape with primary app color
  /// - Labels below the slider showing formatted values
  /// - Real-time updates as user drags the slider
  Widget _buildSlider(
    BuildContext context,
    PortfolioReturnController controller,
  ) {
    // Get minimum and maximum values for the slider from controller
    final min = controller.minSlider.toDouble();
    final max = controller.maxSlider(inputType).toDouble();

    // Determine current slider value based on input type
    // Prioritizes user input value over default value
    final value = inputType == FundReturnInputType.Amount
        ? (controller.sliderAmountFromInput ?? controller.sliderAmount)
            .toDouble()
        : (controller.sliderPeriodFromInput ?? controller.sliderPeriod)
            .toDouble();

    // Ensure value is within min/max range to avoid assertion errors
    final clampedValue = value.clamp(min, max);

    return Column(
      children: [
        // Customize slider appearance with app theme colors
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ColorConstants.primaryAppColor,
            inactiveTrackColor: ColorConstants.borderColor,
            trackHeight: 3.0,
            thumbShape: _CustomThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: (max - min).toInt(), // Create discrete steps
            value: clampedValue,
            // Update controller value as user drags the slider
            onChanged: (newValue) {
              controller.updateReturnFromSlider(
                inputType,
                WealthyCast.toInt(newValue) ?? 0,
              );
            },
            // Notify controller when user finishes dragging
            onChangeEnd: (newValue) {
              controller.updateReturnFromSlider(
                inputType,
                WealthyCast.toInt(newValue) ?? 0,
                isEndReached: true,
              );
            },
          ),
        ),
        SizedBox(height: 5),
        // Display labels below the slider for each division
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (max - min).toInt() + 1, // Generate label for each step
              (index) {
                final labelValue = min + index;
                return Container(
                  width: 3,
                  child: Center(
                    child: Text(
                      getSliderLabelText(labelValue, controller),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall
                          ?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontSize: 10,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String getSliderLabelText(
    dynamic actualValue,
    PortfolioReturnController controller,
  ) {
    final maxLength = inputType == FundReturnInputType.Period
        ? controller.sliderPeriodValues.length
        : controller.sliderAmountValues.length;
    final valueIndex = math.min(WealthyCast.toInt(actualValue) ?? 0, maxLength);
    String data = '';
    if (inputType == FundReturnInputType.Period) {
      data = controller.sliderPeriodValues[valueIndex].toInt().toString();
    } else {
      final amount = controller.sliderAmountValues[valueIndex];
      data =
          WealthyAmount.currencyFormat(amount.toString(), 0, showSuffix: true);
      data = data.replaceAll('₹', '');
    }
    return data;
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double externalThumbRadius;
  final double innerThumbRadius;
  final double circularBorder;

  const _CustomThumbShape({
    this.externalThumbRadius = 9.0,
    this.innerThumbRadius = 5.0,
    this.circularBorder = 1.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(externalThumbRadius + circularBorder);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    canvas.drawCircle(
      center,
      externalThumbRadius + circularBorder,
      Paint()..color = ColorConstants.primaryAppColor,
    );

    canvas.drawCircle(
      center,
      externalThumbRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      innerThumbRadius,
      Paint()..color = ColorConstants.primaryAppColor,
    );
  }
}
