import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/ticket_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class TicketsController extends GetxController {
  // Fields
  String? apiKey = '';
  int? agentId;

  int limit = 20;
  int page = 0;
  bool isPaginating = false;

  NetworkState? ticketsState;

  ScrollController scrollController = ScrollController();

  String ticketsErrorMessage = '';
  List<TicketModel> tickets = <TicketModel>[];
  int totalTicketsCount = 0;

  final Client client;

  TicketsController(this.client);

  @override
  void onInit() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();

    super.onInit();
  }

  @override
  void onReady() async {
    scrollController.addListener(_handlePagination);
    getClientTickets();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  void resetPagination() {
    tickets = <TicketModel>[];
    page = 0;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _handlePagination() {
    if (scrollController.hasClients && !isPaginating) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      bool isPagesRemaining = (totalTicketsCount / (limit * (page + 1))) > 1;

      if (isScrolledToBottom && isPagesRemaining) {
        page += 1;
        isPaginating = true;
        update();
        getClientTickets();
      }
    }
  }

  /// get Client Tickets from the API
  Future<dynamic> getClientTickets() async {
    // If not paginating then reset existing proposal list
    if (!isPaginating) {
      tickets = <TicketModel>[];
    }
    ticketsState = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientListRepository()
          .getClientTickets(apiKey!, client.taxyID!, limit * page);

      if (response.hasException) {
        ticketsErrorMessage = response.exception!.graphqlErrors[0].message;
        ticketsState = NetworkState.error;
      } else {
        final result = TicketsListModel.fromJson(response.data!['entreat']);
        tickets.addAll(result.tickets!);
        totalTicketsCount = result.ticketsCount ?? 0;
        ticketsState = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      ticketsErrorMessage = 'Something went wrong';
      ticketsState = NetworkState.error;
    } finally {
      isPaginating = false;
      update();
    }
  }
}
