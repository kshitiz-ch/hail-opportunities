import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/client_birthdays_controller.dart';
import 'package:app/src/screens/client_birthday/widgets/birthday_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientBirthdayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Client Birthdays'),
      body: GetBuilder<ClientBirthdaysController>(
        init: ClientBirthdaysController(),
        builder: (controller) => _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(ClientBirthdaysController controller) {
    if (controller.clientBirthdaysResponse.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.clientBirthdaysResponse.isError) {
      return Center(
        child: RetryWidget(
          controller.clientBirthdaysResponse.message.isNotEmpty
              ? controller.clientBirthdaysResponse.message
              : 'Something went wrong',
          onPressed: controller.getClientBirthdays,
        ),
      );
    }

    if (controller.clientBirthdaysList.isEmpty) {
      return const EmptyScreen(
        iconData: Icons.cake_outlined,
        message: 'No birthdays found',
      );
    }

    return _buildBirthdaysList(controller);
  }

  Widget _buildBirthdaysList(ClientBirthdaysController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Birthdays
          if (controller.todaysBirthdays.isNotEmpty)
            BirthdaySection(
              title: 'Today\'s Birthdays (${getFormattedDate(DateTime.now())})',
              clients: controller.todaysBirthdays,
              enableWishButton: true,
            ),

          // Tomorrow's Birthdays
          if (controller.tomorrowsBirthdays.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: BirthdaySection(
                title:
                    'Tomorrow (${getFormattedDate(DateTime.now().add(const Duration(days: 1)))})',
                clients: controller.tomorrowsBirthdays,
              ),
            ),

          // Next 7 Days
          if (controller.next7DaysBirthdays.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: BirthdaySection(
                title: 'Next 7 Days',
                clients: controller.next7DaysBirthdays,
                showDate: true,
              ),
            ),

          // Next 30 Days
          if (controller.next30DaysBirthdays.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: BirthdaySection(
                title: 'Next 30 Days',
                clients: controller.next30DaysBirthdays,
                showDate: true,
              ),
            ),
        ],
      ),
    );
  }
}
