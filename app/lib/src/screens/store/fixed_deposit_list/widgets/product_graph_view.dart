import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';

const double FD_GRAPH_MAX_HEIGHT = 250.0;

class ProductGraphView extends StatefulWidget {
  @override
  State<ProductGraphView> createState() => _ProductGraphViewState();
}

class _ProductGraphViewState extends State<ProductGraphView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        if (controller.chartDataState == NetworkState.loading) {
          return SizedBox(
            height: FD_GRAPH_MAX_HEIGHT,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.chartDataState == NetworkState.error) {
          return SizedBox(
            height: FD_GRAPH_MAX_HEIGHT,
            child: Center(
              child: RetryWidget(
                controller.chartErrorMessage ?? genericErrorMessage,
                onPressed: () {
                  controller.getChartData();
                },
              ),
            ),
          );
        }
        if (controller.chartDataState == NetworkState.loaded) {
          if (controller.chartData == null || controller.chartData!.isEmpty) {
            return Container(
              height: FD_GRAPH_MAX_HEIGHT,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: EmptyScreen(
                textStyle: context.headlineSmall?.copyWith(
                    color: ColorConstants.black, fontWeight: FontWeight.w500),
                message:
                    'No eligible FD providers found for the entered details.',
              ),
            );
          }
          return BarChartApplication();
        }

        return SizedBox();
      },
    );
  }
}

class BarChartApplication extends StatelessWidget {
  Widget _getSelectorWidget(
    String providerId,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 36),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? ColorConstants.primaryAppColor
                : ColorConstants.borderColor,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: ColorConstants.primaryAppColor,
              )
            : SizedBox(),
      ),
    );
  }

  Widget _buildProductAvailabiltyIcon({bool isOnline = true}) {
    return Container(
      width: 4,
      height: 4,
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline
            ? ColorConstants.greenAccentColor
            : ColorConstants.errorTextColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(
            controller.chartData!.entries.length,
            (index) {
              final entry = controller.chartData!.entries.elementAt(index);
              // height should be b/w 0 to 1
              // assuming max fd rate is 10%
              final height = (entry.value['interest_rate'] ?? 0) /
                  (controller.highestInterestRate.isNotNullOrZero
                      ? controller.highestInterestRate
                      : 10);
              final providerId = entry.key;
              final isSelected = controller.selectedProduct != null &&
                  controller.selectedProduct!.fdProvider == providerId;
              String topText = entry.value['interest_rate']?.toString() ?? '';
              String bottomText = entry.value['display_name']?.toString() ??
                  entry.key?.toString() ??
                  notAvailableText;
              final isOnline = entry.value['is_online'] ?? false;
              return Bar(
                height: height,
                width: 20,
                color: isSelected
                    ? [
                        ColorConstants.primaryAppColor,
                        ColorConstants.primaryAppColor.withOpacity(0.28),
                      ]
                    : [
                        Color(0xffE7DCFF),
                        Color(0xffE7DCFF),
                      ],
                topLabel: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProductAvailabiltyIcon(
                      isOnline: isOnline,
                    ),
                    Text(
                      topText.isNotNullOrEmpty
                          ? '$topText %'
                          : notAvailableText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ],
                ),
                bottomLabel: SizedBox(
                  height: 35,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      bottomText.split(' ').join('\n'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ),
                ),
                selectorWidget: _getSelectorWidget(providerId, isSelected),
                onSelect: () {
                  controller.updateSelectedProduct(providerId);
                },
                selectedProduct: controller.selectedProduct?.fdProvider,
                highestInterestRate: controller.highestInterestRate,
              );
            },
          ),
        );
      },
    );
  }
}

class Bar extends StatefulWidget {
  final double? height;
  final Widget? topLabel;
  final Widget? bottomLabel;
  final double? width;
  List<Color>? color;
  final Widget? selectorWidget;
  final Function? onSelect;
  final double? highestInterestRate;
  final String? selectedProduct;

  Bar({
    this.height,
    this.topLabel,
    this.bottomLabel,
    this.width,
    this.color,
    this.selectorWidget,
    this.onSelect,
    this.highestInterestRate,
    this.selectedProduct,
  });

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  final int _baseDurationMs = 500;
  // Initially its false for first time
  // as bar graph height animation takes place initially
  // then shimmering effect is shown
  bool showShimmeringEffect = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Bar oldWidget) {
    if (oldWidget.selectedProduct != widget.selectedProduct && this.mounted) {
      // use case:
      // when the selected product is changed transistion should happen immediately
      // so making showShimmeringEffect = false
      // so that transistion will happen in Duration(milliseconds: 200) instead of
      // Duration(seconds: 1)
      showShimmeringEffect = false;
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = FD_GRAPH_MAX_HEIGHT;
    if (widget.highestInterestRate.isNotNullOrZero) {
      // calculate the max height dynamically based on max interest rate
      maxHeight = (FD_GRAPH_MAX_HEIGHT / 10) * widget.highestInterestRate!;
    }

    return Container(
      height: maxHeight + 140,
      // ignore: deprecated_member_use
      child: PlayAnimationBuilder<double>(
        duration:
            Duration(milliseconds: (widget.height! * _baseDurationMs).round()),
        tween: Tween(begin: 0.0, end: widget.height),
        builder: (BuildContext context, double animatedHeight, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: SizedBox()),
                    widget.topLabel!,
                    SizedBox(height: 10),
                    // Container(
                    //   height: (1 - animatedHeight) * _maxElementHeight,
                    // ),
                    InkWell(
                      onTap: widget.onSelect as void Function()?,
                      child: AnimatedContainer(
                        onEnd: () {
                          setState(
                            () {
                              widget.color = widget.color!.reversed.toList();
                              if (!showShimmeringEffect) {
                                showShimmeringEffect = true;
                              }
                            },
                          );
                        },
                        duration: showShimmeringEffect
                            ? Duration(seconds: 1)
                            : Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: widget.color!,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                          ),
                        ),
                        width: 20,
                        height: animatedHeight * maxHeight,
                      ),
                    ),
                  ],
                ),
              ),
              widget.bottomLabel!,
              InkWell(
                onTap: widget.onSelect as void Function()?,
                child: widget.selectorWidget,
              ),
            ],
          );
        },
      ),
    );
  }
}
