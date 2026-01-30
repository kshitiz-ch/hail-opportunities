import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/slider_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class InterestTenureInputFieldForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        return Form(
          key: controller.tenureFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderField(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildGenderField(context, controller),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildSeniorCitizenField(context, controller),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderField(
    BuildContext context,
    FixedDepositsController controller,
  ) {
    Widget _buildAsset(bool isMale) {
      return Expanded(
        child: InkWell(
          onTap: () {
            controller.updateGender(isMale);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.isMale == isMale
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
              color: controller.isMale == isMale
                  ? ColorConstants.secondaryAppColor
                  : ColorConstants.secondaryWhite,
            ),
            child: SvgPicture.asset(
              isMale ? AllImages().maleIcon : AllImages().femaleIcon,
              color: controller.isMale == isMale
                  ? ColorConstants.primaryAppColor
                  : Color(0xffC5C5C5),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
              ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: Row(
            children: [
              _buildAsset(true),
              SizedBox(width: 12),
              _buildAsset(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeniorCitizenField(
    BuildContext context,
    FixedDepositsController controller,
  ) {
    final list = <bool>[false, true];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senior Citizen',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
              ),
        ),
        SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
            ),
          ),
          child: Row(
            children: List<Widget>.generate(
              list.length,
              (index) => Expanded(
                child: InkWell(
                  onTap: () {
                    controller.updateSeniorCitizen(list[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: controller.isSeniorCitizen == list[index]
                          ? ColorConstants.secondaryAppColor
                          : Colors.transparent,
                      border: controller.isSeniorCitizen == list[index]
                          ? Border.all(color: ColorConstants.primaryAppColor)
                          : null,
                      borderRadius: !controller.isSeniorCitizen
                          ? BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            )
                          : BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        list[index] ? 'Yes' : 'No',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: controller.isSeniorCitizen == list[index]
                                  ? ColorConstants.primaryAppColor
                                  : ColorConstants.black,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
