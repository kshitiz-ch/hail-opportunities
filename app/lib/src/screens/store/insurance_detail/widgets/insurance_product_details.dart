import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/insurance/insurance_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/store/models/insurance_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsuranceProductDetails extends StatelessWidget {
  const InsuranceProductDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceController>(
      id: GetxId.insuranceProductDetail,
      builder: (controller) {
        if (controller.insuranceProductDetailState == NetworkState.loading) {
          return _buildLoadingIndicator();
        }

        if (controller.insuranceProductDetailState == NetworkState.loaded &&
            controller.insuranceDetailModel != null) {
          return ListView.builder(
            padding: EdgeInsets.only(top: 0, bottom: 100),
            shrinkWrap: true,
            itemCount: controller.insuranceDetailModel!.products!.length,
            itemBuilder: (BuildContext context, int index) {
              InsuranceProductDetailModel productDetail =
                  controller.insuranceDetailModel!.products![index];
              return _buildProductCard(context, productDetail);
            },
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildProductCard(BuildContext context,
      InsuranceProductDetailModel insuranceProductDetailModel) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.07),
      elevation: 5,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              offset: Offset(0, 3),
              blurRadius: 10,
            )
          ],
          border: Border.all(
            width: 0.5,
            color: ColorConstants.tertiaryBlack.withOpacity(0.5),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag(
                        context: context,
                        isOffline: insuranceProductDetailModel.isOffline!,
                      ),
                      Text(
                        insuranceProductDetailModel.name!,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16),
                  child: CachedNetworkImage(
                    imageUrl: insuranceProductDetailModel.logo!,
                    fit: BoxFit.fitWidth,
                    // height: 54,
                    width: 54,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            if (insuranceProductDetailModel.description.isNotNullOrEmpty)
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    copyData(data: insuranceProductDetailModel.description!);
                  },
                  child: Text(
                    insuranceProductDetailModel.description!,
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                ),
              ),
            if (insuranceProductDetailModel.benefits.isNotNullOrEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _buildBulletList(
                  context: context,
                  textList: insuranceProductDetailModel.benefits!,
                ),
              ),
            if (insuranceProductDetailModel.quoteUrl.isNotNullOrEmpty)
              _buildQuoteGenerationView(
                  context, insuranceProductDetailModel.quoteUrl!)
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteGenerationView(BuildContext context, String quoteUrl) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            launch(quoteUrl);
          },
          child: Text(
            'Quote Generation Link',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: hexToColor("#4B93FF"),
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: () {
            copyData(data: quoteUrl);
          },
          child: Icon(
            Icons.copy_rounded,
            color: ColorConstants.primaryAppColor,
            size: 16,
          ),
        )
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView(
      padding: EdgeInsets.only(top: 0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ...List.filled(2, 0)
            .map(
              (e) => Container(
                height: 170,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ProductCard().toShimmer(
                  baseColor: ColorConstants.lightBackgroundColor,
                  highlightColor: ColorConstants.white,
                ),
              ),
            )
            .toList()
      ],
    );
  }

  Widget _buildBulletList(
      {BuildContext? context, required List<String> textList}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[].toList()
          ..addAll(
            textList.map<Widget>(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '   $bulletPointUnicode ',
                      style: Theme.of(context!)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            height: 18 / 12,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        '$text',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              height: 18 / 12,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildTag({bool isOffline = false, required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isOffline
            ? ColorConstants.insuranceOfflineColor
            : ColorConstants.lightGreenBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        'Available ${isOffline ? 'Offline' : 'Online'}',
        style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.black,
            ),
      ),
    );
  }
}
