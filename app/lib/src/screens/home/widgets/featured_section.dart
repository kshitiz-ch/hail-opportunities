import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class FeaturedSection extends StatelessWidget {
  Map<String, dynamic> primaryAmcMap = {};

  FeaturedSection({Key? key}) : super(key: key) {
    primaryAmcMap = {
      'Axis': {'image_path': AllImages().axisBankMFIcon, 'filter_code': 'axs'},
      'ICICI': {'image_path': AllImages().iciciMFIcon, 'filter_code': 'ici'},
      'SBI': {'image_path': AllImages().sbiMFIcon, 'filter_code': 'sbi'},
      'UTI': {'image_path': AllImages().utiMFIcon, 'filter_code': 'uti'},
      'Kotak': {'image_path': AllImages().kotakMFIcon, 'filter_code': 'kkm'},
      'Tata': {'image_path': AllImages().tataMfIcon, 'filter_code': 'tat'},
      'DSP': {'image_path': AllImages().dspMFIcon, 'filter_code': 'dsp'},
    };
  }

  @override
  Widget build(BuildContext context) {
    final amcList = primaryAmcMap.keys.toList();
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: amcList.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          return SizedBox(width: 20);
        },
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "mf_${amcList[index]}",
                    properties: {
                      "screen_location": "explore_mf",
                      "screen": "Home",
                    },
                  );
                  AutoRouter.of(context).push(
                    MfListRoute(
                      amc: primaryAmcMap[amcList[index]]['filter_code'],
                    ),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        primaryAmcMap[amcList[index]]['image_path'],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Center(
                  child: Text(
                    amcList[index],
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.secondaryBlack,
                              height: 1.4,
                            ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
