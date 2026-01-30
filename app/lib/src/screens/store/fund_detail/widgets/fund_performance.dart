import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_return_calculator.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'historical_graph.dart';

class FundPerformance extends StatefulWidget {
  final SchemeMetaModel fund;
  final Function scrollToTop;

  const FundPerformance(
      {Key? key, required this.fund, required this.scrollToTop})
      : super(key: key);

  @override
  State<FundPerformance> createState() => _FundPerformanceState();
}

class _FundPerformanceState extends State<FundPerformance> {
  late FundGraphView _selectedView;

  final fundDetailcontroller = Get.find<FundDetailController>();

  @override
  void initState() {
    super.initState();
    _selectedView = FundGraphView.Historical;
    fundDetailcontroller.selectedGraphView = _selectedView;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.secondaryWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.fund.wpc.isNotNullOrEmpty ||
              widget.fund.wschemecode.isNotNullOrEmpty)
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.darkBlack.withOpacity(0.1),
                      offset: Offset(0.0, 4.0),
                      spreadRadius: 0.0,
                      blurRadius: 10.0,
                    ),
                  ],
                  border:
                      Border.all(color: ColorConstants.black.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: RadioButtons(
                  items: FundGraphView.values,
                  spacing: 30,
                  runSpacing: 0,
                  selectedValue: _selectedView,
                  itemBuilder: (context, value, index) {
                    late String text;
                    if (value == FundGraphView.Historical) {
                      text = 'Historical View';
                    } else {
                      text = 'Return Calculator';
                    }
                    return Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: value == _selectedView
                                ? ColorConstants.black
                                : ColorConstants.tertiaryBlack,
                          ),
                    );
                  },
                  direction: Axis.horizontal,
                  onTap: (value) {
                    if (value == FundGraphView.Historical) {
                    } else {
                      MixPanelAnalytics.trackWithAgentId(
                        "return_calculator",
                        screen: 'fund_details',
                        screenLocation: "overview",
                      );
                    }

                    if (_selectedView != value) {
                      setState(() {
                        _selectedView = value;
                        widget.scrollToTop();
                        fundDetailcontroller.selectedGraphView = _selectedView;
                      });
                    }
                  },
                ),
              ),
            ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 350),
            // switchInCurve: Curves.ease,
            // switchOutCurve: Curves.ease,
            child: _selectedView == FundGraphView.Historical
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: HistoricalGraph(
                      backgroundColor: ColorConstants.secondaryWhite,
                      padding: EdgeInsets.zero,
                      wSchemeCode: widget.fund.wschemecode,
                      fund: widget.fund,
                      isFund: true,
                    ),
                  )
                : FundReturnCalculator(fund: widget.fund),
          ),
        ],
      ),
    );
  }
}
