import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/my_business/business_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessInfoCard extends StatelessWidget {
  final String id;
  Function? onTap;
  final String title;
  final String image;

  BusinessInfoCard({
    Key? key,
    required this.id,
    this.onTap,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).primaryTextTheme.headlineSmall;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.tertiaryBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.secondaryWhite,
              border: Border(
                bottom: BorderSide(color: ColorConstants.secondaryWhite),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  image,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                ),
                if (onTap != null)
                  ClickableText(
                    text: 'View Details',
                    onClick: onTap,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )
              ],
            ),
          ),
          BusinessDataBuilder(id: id),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class BusinessDataBuilder extends StatelessWidget {
  final String id;

  const BusinessDataBuilder({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(
      id: id,
      builder: (controller) {
        final apiResponse = controller.getApiResponse(id);
        if (apiResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 200);
        }
        if (apiResponse.state == NetworkState.error) {
          return SizedBox(
            height: 200,
            child: RetryWidget(
              apiResponse.message,
              onPressed: () {
                controller.onRetry(id);
              },
            ),
          );
        }
        if (apiResponse.state == NetworkState.loaded) {
          final data = controller.getUIData(id);
          if (data.isEmpty) {
            return EmptyScreen(message: 'No data available');
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries
                .map(
                  (e) => _buildData(e.key, e.value, context),
                )
                .toList(),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildData(String key, String value, BuildContext context) {
    final textStyle = Theme.of(context).primaryTextTheme.headlineSmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key,
            style: textStyle?.copyWith(
              color: ColorConstants.tertiaryBlack,
            ),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: textStyle?.copyWith(color: ColorConstants.black),
          ),
        ],
      ),
    );
  }
}
