import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_investments/total_investment_card.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_investments_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'empty_investment.dart';

class MfInvestmentSection extends StatelessWidget {
  const MfInvestmentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientAdditionalDetailController>(
      id: GetxId.clientInvestments,
      builder: (controller) {
        if (controller.investmentResponse.state == NetworkState.loading) {
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 200,
              decoration: BoxDecoration(
                  color: ColorConstants.lightBackgroundColor,
                  borderRadius: BorderRadius.circular(12)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
          );
        }

        if (controller.investmentResponse.state == NetworkState.error) {
          return SizedBox(
            height: 96,
            child: RetryWidget(
              controller.investmentResponse.message,
              onPressed: () => controller.getInvestments(),
            ),
          );
        }

        if (controller.investmentResponse.state == NetworkState.loaded &&
            controller.clientInvestmentsResult == null) {
          return EmptyInvestment(
              emptyHeader: 'Wealthy Investments',
              emptyText: 'No Investments found for this client');
        }

        if (controller.investmentResponse.state == NetworkState.loaded) {
          return ListView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 30),
            children: [
              if (controller.clientInvestmentsResult?.total != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TotalInvestmentCard(),
                ),

              // ClientInvestmentOverview(
              //   investmentData: controller.clientInvestmentsResult!.total!,
              // ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.mutualFunds,
                investmentData: controller.clientInvestmentsResult?.mf,
              ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.preIpo,
                investmentData: controller.clientInvestmentsResult?.preipo,
              ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.debentures,
                investmentData: controller.clientInvestmentsResult?.deb,
              ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.pms,
                investmentData: controller.clientInvestmentsResult?.pms,
              ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.fixedDeposit,
                investmentData: controller.clientInvestmentsResult?.fd,
              ),
              _buildGenericInvestmentCard(
                productType: ClientInvestmentProductType.sif,
                investmentData: controller.clientInvestmentsResult?.sif,
              ),
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  // Widget _buildMfInvestmentCard(MfInvestmentModel? mf) {
  //   if (mf == null) {
  //     return SizedBox();
  //   }

  //   return Container(
  //     margin: EdgeInsets.only(bottom: 12),
  //     child: ClientInvestmentsCard(
  //       productType: InvestmentProductType.mf,
  //       // currentValue: mf.overview?.currentValue,
  //       // mfProducts: mf.products,
  //     ),
  //   );
  // }

  Widget _buildGenericInvestmentCard(
      {required ClientInvestmentProductType productType,
      GenericPortfolioOverviewModel? investmentData}) {
    DateTime? asOn = Get.find<ClientAdditionalDetailController>()
        .clientInvestmentsResult
        ?.asOn;
    double? totalValue = Get.find<ClientAdditionalDetailController>()
        .clientInvestmentsResult
        ?.total
        ?.currentValue;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ClientInvestmentsCard(
        productType: productType,
        investmentData: investmentData,
        asOn: asOn,
        totalValue: totalValue,
        // productList: investmentData.products,
        // pendingProductsCount: investmentData.inprogress?.length,
      ),
    );
  }
}
