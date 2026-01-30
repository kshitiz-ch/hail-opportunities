import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/wealth_academy/events_controller.dart';
import 'package:app/src/screens/wealth_academy/widgets/event_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/wealth_academy/models/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({
    Key? key,
  }) : super(key: key);

  final String defaultPoster =
      'https://res.cloudinary.com/dti7rcsxl/image/upload/v1661487469/Group_8208_gxcoco.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Wealthy Training',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: GetBuilder<EventsController>(
          initState: (_) {
            EventsController _controller = Get.isRegistered<EventsController>()
                ? Get.find<EventsController>()
                : Get.put(EventsController());

            _controller.getEventSchedules();
          },
          builder: (controller) {
            if (controller.eventSchedulesState == NetworkState.loading) {
              return _buildEventLoader(context);
            }

            if (controller.eventSchedulesState == NetworkState.loaded &&
                controller.eventSchedules.length > 0) {
              return ListView(
                children: [
                  Text(
                    'Upcoming Event',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.tertiaryBlack),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryCardColor,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black12,
                      //     offset: Offset(0.0, 1.0),
                      //     spreadRadius: 0.0,
                      //     blurRadius: 7.0,
                      //   ),
                      // ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: EventCard(
                        eventSchedule: controller.eventSchedules[3],
                        controller: controller),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Events',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.tertiaryBlack),
                      ),
                      TextButton(
                        onPressed: () {
                          _buildFilterBottomSheet(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedFilter,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: ColorConstants.primaryAppColor,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Center(
                                child: Icon(
                                  Icons.expand_more,
                                  color: ColorConstants.secondaryBlack,
                                  size: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(bottom: 50),
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 24);
                      },
                      itemCount: controller.eventSchedules.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        EventScheduleModel? currentEventSchedule =
                            controller.eventSchedules[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryCardColor,
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black12,
                            //     offset: Offset(0.0, 1.0),
                            //     spreadRadius: 0.0,
                            //     blurRadius: 7.0,
                            //   ),
                            // ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: EventCard(
                              eventSchedule: currentEventSchedule,
                              controller: controller),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return SizedBox();
          },
        ),
      ),
    );
  }

  void _buildFilterBottomSheet(BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      backgroundColor: ColorConstants.white,
      child: GetBuilder<EventsController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(top: 30, bottom: 45),
                child: Text(
                  'Sort By',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: ColorConstants.black,
                      ),
                ),
              ),
            ]..addAll(
                controller.filtersList
                    .map<Widget>(
                      (productCategory) => Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 34, right: 12),
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: controller.selectedFilter
                                              .toLowerCase() ==
                                          productCategory.toLowerCase()
                                      ? Icon(
                                          Icons.check_sharp,
                                          color: ColorConstants.primaryAppColor,
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              Text(
                                productCategory,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: controller.selectedFilter
                                                  .toLowerCase() ==
                                              productCategory.toLowerCase()
                                          ? ColorConstants.black
                                          : ColorConstants.tertiaryBlack,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          );
        },
      ),
    );
  }

  Widget _buildEventLoader(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...List.filled(3, 0)
                .map(
                  (e) => Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ProductCard().toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }
}
