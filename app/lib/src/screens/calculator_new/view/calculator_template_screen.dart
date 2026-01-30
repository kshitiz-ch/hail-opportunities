import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class CalculatorTemplateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalculatorController>(
      init: CalculatorController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildAppBar(context),
                SizedBox(height: 20),
                _buildTemplateListing(context, controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(maxHeight: 270),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(AllImages().calculatorBgIcon),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 5),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    AutoRouter.of(context).popForced();
                  },
                  child: Image.asset(
                    AllImages().appBackIcon,
                    color: Colors.white,
                    height: 32,
                    width: 32,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Calculators',
                  style: context.headlineMedium!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateListing(
    BuildContext context,
    CalculatorController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        primary: false,
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: CalculatorType.values.map(
          (type) {
            final data = controller.getCalculatorIconTitle(type);
            return InkWell(
              onTap: () {
                controller.changeCalculatorType(type);
                AutoRouter.of(context).push(CalculatorRoute());

                // Track the event with MixPanel
                MixPanelAnalytics.trackWithAgentId(
                  'page_viewed',
                  properties: {
                    'source': 'Calculators',
                    'page_name': type.calculatorName,
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorConstants.borderColor),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        data['icon']!,
                        height: 36,
                        width: 36,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data['title']!,
                          maxLines: 3,
                          style: context.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            color: ColorConstants.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
