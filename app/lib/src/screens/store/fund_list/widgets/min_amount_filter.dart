import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MinAmountFilter extends StatelessWidget {
  MinAmountFilter({Key? key, this.tag}) : super(key: key);

  final FocusNode minAmountControllerFocusNode = FocusNode();
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      id: 'min-amount-slider',
      builder: (controller) {
        return Center(
          child: ListView(
            controller: controller.filterScrollController,
            padding: EdgeInsets.only(left: 30, top: 50, right: 20),
            children: [
              Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          color: ColorConstants.black,
                          // fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(width: 5),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: controller.minAmountController,
                      focusNode: minAmountControllerFocusNode,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        NoLeadingSpaceFormatter(),
                      ],
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        isDense: true,
                        counterText: '',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Color(0xFFEAEAEA)..withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Color(0xFFEAEAEA)..withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Color(0xFFEAEAEA)..withOpacity(0.5),
                          ),
                        ),
                      ),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w600,
                          ),
                      onChanged: (String value) {
                        if (value.isNullOrEmpty) {
                          controller.updateMinAmountFilter(0);
                        } else if (WealthyCast.toDouble(value)! > 10000) {
                          controller.updateMinAmountFilter(10000);
                          controller.minAmountController!.text = "10000";
                          showToast(text: 'Max limit is ₹10,000');
                        } else {
                          controller.updateMinAmountFilter(
                              WealthyCast.toDouble(value));
                        }
                      },
                    ),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              // Text('Min Amount',
              //     style: Theme.of(context)
              //         .primaryTextTheme
              //         .headline6
              //         .copyWith(
              //           color: ColorConstants.black,
              //           fontWeight: FontWeight.w600,
              //         )),
              // BorderedTextFormField(),
              // Text(
              //   WealthyAmount.currencyFormat(
              //       controller.minAmountFilter.toString(), 0),
              //   style:
              //       Theme.of(context).primaryTextTheme.headlineSmall.copyWith(
              //             color: ColorConstants.black,
              //             fontWeight: FontWeight.w600,
              //           ),
              // )
              //   ],
              // ),
              Padding(
                // width: MediaQuery.of(context).size.width,
                // color: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      trackShape: RoundedRectSliderTrackShape(),
                      tickMarkShape: null,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                      showValueIndicator: ShowValueIndicator.never,
                      overlayShape: SliderComponentShape.noThumb),
                  child: Slider(
                      value: controller.minAmountFilter!,
                      min: 0.0,
                      max: 10000.0,
                      divisions: 20,
                      // activeColor: ColorConstants.primaryAppColor,
                      // inactiveColor: ColorConstants.secondaryAppColor,
                      label: controller.minAmountFilter!.toStringAsFixed(0),
                      onChanged: (double newValue) {
                        controller.minAmountController!.text =
                            newValue.toStringAsFixed(0);
                        controller.updateMinAmountFilter(newValue);
                        // setState(() {
                        //   _value = newValue.round();
                        // });
                      }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹0',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                  Text(
                    '₹10,000',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
