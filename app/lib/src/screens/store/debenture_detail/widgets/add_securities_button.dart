import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/debenture/debenture_controller.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSecuritiesButton extends StatelessWidget {
  final DebentureModel? product;

  AddSecuritiesButton({Key? key, this.product}) : super(key: key);

  DebentureController controller = Get.find<DebentureController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (controller.showSecuritiesInput)
                _buildChangeSecurityButtons(context)
              else
                _buildAddSecurityButton(context),
              SizedBox(height: 10),
              if (product!.lotCheckEnabled!)
                _buildAvailableSecurityText(context)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChangeSecurityButtons(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          disabledColor: Colors.black.withOpacity(0.4),
          color: Colors.black,
          onPressed: !controller.disableDecrementSecurityButton
              ? () {
                  controller.updateNoOfSecurities(
                    isIncrement: false,
                  );
                }
              : null,
          icon: Icon(
            Icons.remove,
            size: 14,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: ColorConstants.primaryAppColor),
          child: Text(
            controller.noOfSecuritiesController.text.toString(),
            // '5',
            style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
        ),
        IconButton(
          disabledColor: Colors.black.withOpacity(0.4),
          color: Colors.black,
          onPressed: !controller.disableIncrementSecurityButton
              ? () {
                  controller.updateNoOfSecurities(isIncrement: true);
                }
              : null,
          icon: Icon(
            Icons.add,
            size: 14,
          ),
        )
      ],
    );
  }

  Widget _buildAddSecurityButton(context) {
    bool shouldDisableAddButton = false;
    bool isTradeDatePassed = false;

    if (product?.tradeDate != null) {
      final now = DateTime.now();
      DateTime tradeDateParsed = DateTime.parse(product!.tradeDate!);
      int difference = now.difference(tradeDateParsed).inDays;
      if (difference > 0) {
        isTradeDatePassed = true;
      }
    }

    if (product!.lotAvailable! <= 0 || isTradeDatePassed) {
      shouldDisableAddButton = true;
    }

    return InkWell(
      onTap: () {
        if (product!.lotAvailable! <= 0) {
          return null;
        }

        if (isTradeDatePassed) {
          return showToast(
            context: context,
            text: 'Trade date has passed. Please contact your RM',
          );
        } else {
          controller.setshowSecuritiesInput();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: ColorConstants.primaryAppColor
              .withOpacity(shouldDisableAddButton ? 0.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 18,
            ),
            SizedBox(width: 2),
            Text(
              'ADD',
              style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSecurityText(context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Available: ',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.lightGrey,
                ),
          ),
          // TODO: Ask whether this field will always be present
          TextSpan(
            text: product!.lotAvailable!.toStringAsFixed(0),
            style: Theme.of(context).primaryTextTheme.displayLarge!.copyWith(
                  fontSize: 13,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
