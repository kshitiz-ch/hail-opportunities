import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/tickets_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/ticket_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceRequestSection extends StatelessWidget {
  final Client client;

  const ServiceRequestSection({Key? key, required this.client})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketsController>(
      init: TicketsController(client),
      // dispose: (_) => Get.delete<TicketsController>(),
      builder: (TicketsController controller) {
        if (controller.ticketsState == NetworkState.loading &&
            !controller.isPaginating) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.ticketsState == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.ticketsErrorMessage,
                onPressed: () {
                  controller.getClientTickets();
                },
              ),
            ),
          );
        }
        if (controller.tickets.isNullOrEmpty) {
          return Center(
            child: EmptyScreen(
              message: 'No Service Request found for the client',
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                controller: controller.scrollController,
                itemBuilder: (BuildContext context, int index) {
                  return _buildServiceRequestCard(
                    context,
                    controller.tickets[index],
                  );
                },
                itemCount: controller.tickets.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 14);
                },
              ),
            ),
            (controller.ticketsState == NetworkState.loading &&
                    controller.isPaginating)
                ? Center(child: CircularProgressIndicator())
                : SizedBox()
          ],
        );
      },
    );
  }

  Widget _buildServiceRequestCard(BuildContext context, TicketModel ticket) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
              overflow: TextOverflow.ellipsis,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
              overflow: TextOverflow.ellipsis,
            );
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket ID : ${ticket.no}',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.title ?? notAvailableText,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CommonUI.buildColumnTextInfo(
                    title: 'Created On',
                    subtitle: getFormattedDateTime(ticket.createdAt?.toLocal()),
                    gap: 4,
                    titleStyle: titleStyle,
                    subtitleStyle: subtitleStyle,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonUI.buildColumnTextInfo(
                        title: 'Created by',
                        subtitle: ticket.requestor?.getDisplayName ?? '',
                        useMarqueeWidget: true,
                        gap: 4,
                        titleStyle: titleStyle,
                        subtitleStyle: subtitleStyle,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CommonUI.buildColumnTextInfo(
                          title: 'Status',
                          subtitle: getServiceRequestStatusDescription(
                              ticket.status ?? ''),
                          gap: 4,
                          titleStyle: titleStyle,
                          subtitleStyle: subtitleStyle,
                        ),
                      ),
                    )
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 16),
                //   child: CommonUI.buildColumnTextInfo(
                //     title: 'Whatsapp Communication',
                //     subtitle: 'Delivered 21/05/2023 10.30 AM',
                //     gap: 4,
                //     titleStyle: titleStyle,
                //     subtitleStyle: subtitleStyle,
                //   ),
                // ),
                // CommonUI.buildColumnTextInfo(
                //   title: 'Email Communication',
                //   subtitle: 'Delivered 21/05/2023 10.30 AM',
                //   gap: 4,
                //   titleStyle: titleStyle,
                //   subtitleStyle: subtitleStyle,
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
