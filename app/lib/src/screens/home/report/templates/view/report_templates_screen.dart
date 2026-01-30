import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/report_template_section.dart';

@RoutePage()
class ReportTemplateScreen extends StatelessWidget {
  const ReportTemplateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(maxHeight: 270),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryAppColor,
                      image: DecorationImage(
                        image: AssetImage(AllImages().reportTemplatesBg),
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
                            'Reports',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Client Reports',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You can download following reports for your\nclients. Click on a report to start',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ReportTemplateSection(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
