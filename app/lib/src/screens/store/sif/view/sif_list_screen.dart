import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/sif_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/fund_detail/widgets/basket_icon.dart';
import 'package:app/src/screens/store/sif/widgets/sif_list_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/loader/screener_table_skelton.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SifListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SifController>(
      init: SifController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'SIF',
            trailingWidgets: [
              if (controller.sifs.isNotEmpty)
                BasketIcon(
                  onTap: () {
                    AutoRouter.of(context).push(BasketOverViewRoute());
                  },
                )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 30),
            child: _buildSifList(controller, context),
          ),
          bottomNavigationBar: controller.sifs.isNotEmpty
              ? CommonMfUI.buildMfLobbyBottomNavigationBar()
              : SizedBox(),
        );
      },
    );
  }

  Widget _buildSifList(SifController controller, BuildContext context) {
    if (controller.sifListResponse.isLoading && !controller.isPaginating) {
      return Center(child: ScreenerTableSkelton());
    }

    if (controller.sifListResponse.isError) {
      return Center(
        child: RetryWidget(
          controller.sifListResponse.message,
          onPressed: () {
            controller.getSifs();
          },
        ),
      );
    }

    if (controller.sifListResponse.isLoaded && controller.sifs.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(message: 'No SIF found'),
      );
    }

    return SifListSection();
  }
}
