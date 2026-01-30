import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvestmentPieChart extends StatefulWidget {
  @override
  State<InvestmentPieChart> createState() => _InvestmentPieChartState();
}

class _InvestmentPieChartState extends State<InvestmentPieChart> {
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientAdditionalDetailController>(
      id: GetxId.clientInvestments,
      builder: (controller) {
        if (controller.clientInvestmentsResult != null)
          return Container(
            margin: EdgeInsets.only(top: 30),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: showingSections(
                        controller.clientInvestmentsResult!,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      Text(
                        WealthyAmount.currencyFormat(
                            controller
                                .clientInvestmentsResult?.total?.currentValue,
                            2,
                            showSuffix: true),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        return SizedBox();
      },
    );
  }

  List<PieChartSectionData> showingSections(
      UserPortfolioOverviewModel clientInvestmentResult) {
    List<Map<ClientInvestmentProductType, double>> productTypeWithInvestments =
        [];
    double totalValue = clientInvestmentResult.total?.currentValue ?? 0;

    void addProductTypeToChart(
        double? currentValue, ClientInvestmentProductType productType) {
      if ((currentValue ?? 0) > 0) {
        productTypeWithInvestments
            .add({productType: (currentValue! / totalValue).toPercentage});
      }
    }

    addProductTypeToChart(clientInvestmentResult.mf?.currentValue,
        ClientInvestmentProductType.mutualFunds);
    addProductTypeToChart(clientInvestmentResult.preipo?.currentValue,
        ClientInvestmentProductType.preIpo);
    addProductTypeToChart(clientInvestmentResult.pms?.currentValue,
        ClientInvestmentProductType.pms);
    addProductTypeToChart(clientInvestmentResult.deb?.currentValue,
        ClientInvestmentProductType.debentures);
    addProductTypeToChart(clientInvestmentResult.fd?.currentValue,
        ClientInvestmentProductType.fixedDeposit);

    return List.generate(productTypeWithInvestments.length, (i) {
      return PieChartSectionData(
        color: getInvestmentColors(productTypeWithInvestments[i].keys.first),
        value: productTypeWithInvestments[i].values.first,
        title: '',
        radius: 50.0,
      );
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
