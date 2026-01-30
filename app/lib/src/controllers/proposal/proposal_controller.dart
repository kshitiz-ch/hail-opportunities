import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ProposalsController extends GetxController {
  String? employeeAgentExternalId;
  MetaDataModel proposalMetaData = MetaDataModel();
  List<String> productCategoryList = [
    "All",
    ProductCategoryType.INVEST,
    ProductCategoryType.INSURANCE,
    // ProductCategoryType.LOAN,
    ProductCategoryType.DEMAT,
  ];
  ScrollController? scrollController;
  TabController? tabController;

  Client? client;
  List<ProposalModel> proposals = [];
  bool isInitialLoading = true;

  NetworkState proposalListState = NetworkState.cancel;
  CancelToken? cancelToken;

  int limit = 20;
  int page = 0;
  bool isPaginating = false;

  String? selectedTabStatus = "ALL";
  String? selectedProductCategory;

  PartnerType partnerType = PartnerType.Self;
  EmployeesModel? partnerEmployeeSelected;

  NetworkState proposalState = NetworkState.cancel;

  String? proposalErrorMessage = '';

  Map<String, int?> proposalCount = {
    'ALL': 0,
    'open': 0,
    'won': 0,
  };

  bool get isDematProposalFilter =>
      selectedProductCategory == ProductCategoryType.DEMAT;

  ApiResponse deleteProposalResponse = ApiResponse();
  String? deleteReason;

  ProposalsController({
    this.client,
    this.scrollController,
    this.selectedTabStatus = 'ALL',
    this.employeeAgentExternalId,
    this.selectedProductCategory = 'All',
  }) {
    if (scrollController != null) {
      scrollController!.addListener(() {
        handlePagination();
      });
    }
    if (selectedProductCategory.isNullOrEmpty) {
      selectedProductCategory = 'All';
    }
  }

  @override
  void onInit() {
    super.onInit();
    getProposals();
  }

  @override
  void dispose() {
    tabController?.dispose();
    scrollController?.dispose();

    super.dispose();
  }

  Future<void> getProposals() async {
    try {
      if (cancelToken != null) {
        cancelToken!.cancel();
      }
      cancelToken = CancelToken();

      proposalState = NetworkState.loading;
      // If not paginating then reset existing proposal list
      if (!isPaginating) {
        proposals = [];
      }
      update();

      String? agentExternalId;
      if (partnerType == PartnerType.Office) {
        agentExternalId = partnerEmployeeSelected?.agentExternalId;
      } else {
        agentExternalId = employeeAgentExternalId;
      }

      String apiKey = (await getApiKey())!;

      int offset = ((page + 1) * limit) - limit;

      int agentId = await getAgentId() ?? 0;
      Map<String, dynamic> payload = {
        "limit": limit,
        "offset": offset,
        "status_category": selectedTabStatus ?? "",
        "product_category":
            selectedProductCategory == "All" || isDematProposalFilter
                ? ""
                : selectedProductCategory,
        if (isDematProposalFilter) "product_type": "demat",
        if (agentExternalId.isNotNullOrEmpty) "agent_ids": agentExternalId,
        if (client?.taxyID.isNotNullOrEmpty ?? false)
          "user_ids": client?.taxyID,
        if (client?.taxyID.isNotNullOrEmpty ?? false)
          "agent_ids": client?.agent?.externalId
      };

      final data = await ProposalRepository().getProposalsListv2(
        apiKey,
        agentId,
        payload,
        cancelToken: cancelToken,
      );

      final bool isRequestCancelled = data?['isRequestCancelled'] ?? false;
      if (isRequestCancelled) return;

      if (data['status'] == '200') {
        final dataList = WealthyCast.toList(data['response']['results']);
        MetaDataModel metaData =
            MetaDataModel.fromJson(data['response']['meta']);

        dataList.forEach((element) {
          proposals.add(ProposalModel.fromJson(element));
        });
        proposalMetaData = metaData;

        proposalCount[selectedTabStatus!] = proposalMetaData.totalCount;

        proposalState = NetworkState.loaded;
      } else {
        proposalState = NetworkState.error;
        proposalErrorMessage = handleApiError(data);
      }
    } catch (error) {
      proposalState = NetworkState.error;
      proposalErrorMessage = 'Something went wrong';
    } finally {
      if (isInitialLoading) {
        isInitialLoading = false;
      }
      isPaginating = false;
      update();
    }
  }

  updateTabStatus(tabStatus) {
    if (tabStatus != selectedTabStatus) {
      selectedTabStatus = tabStatus;
      resetPagination();
      getProposals();
      update();
    }
  }

  updateSelectedProductCategory(productCategory) {
    selectedProductCategory = productCategory;
    resetPagination();
    update();
  }

  setLoading() {
    proposalState = NetworkState.loading;
    update();
  }

  handlePagination() {
    if (scrollController!.hasClients) {
      bool isScrolledToBottom = scrollController!.position.maxScrollExtent <=
          scrollController!.position.pixels;
      bool isPagesRemaining =
          (proposalMetaData.totalCount! / (limit * (page + 1))) > 1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          proposalState != NetworkState.loading) {
        page += 1;
        isPaginating = true;
        update();
        getProposals();
      }
    }
  }

  resetPagination() {
    page = 0;
    proposalMetaData = MetaDataModel();
    // _currentProposalsCount = 0;

    //? ensure before animating list has clients
    if (scrollController!.hasClients) {
      scrollController!.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }

    update();
  }

  Future<void> deleteProposal(ProposalModel proposal) async {
    deleteProposalResponse.state = NetworkState.loading;
    update([GetxId.deleteProposal]);

    try {
      final agentId = (await getAgentId() ?? '').toString();
      final apiKey = (await getApiKey())!;

      final data = await ProposalRepository().markProposalFail(
        apiKey,
        proposal.externalId!,
        deleteReason!,
        agentId,
      );

      if (data['status'] == '200') {
        deleteProposalResponse.state = NetworkState.loaded;
        deleteProposalResponse.message =
            WealthyCast.toStr(data['response']['msg']) ??
                'Proposal Deleted Successfully';
      } else {
        deleteProposalResponse.state = NetworkState.error;
        deleteProposalResponse.message =
            WealthyCast.toStr(data['response']['msg']) ?? genericErrorMessage;
      }
    } catch (error) {
      deleteProposalResponse.state = NetworkState.error;
      deleteProposalResponse.message = 'Something went wrong! Please try again';
    } finally {
      update([GetxId.deleteProposal]);
    }
  }

  void updateDeleteReason(String value) {
    deleteReason = value;
    update([GetxId.deleteProposal]);
  }
}
