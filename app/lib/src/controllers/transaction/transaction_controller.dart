import 'dart:async';
import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/date_range_utils.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/transaction/models/insurance_transaction_model.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:core/modules/transaction/models/pms_transaction_model.dart';
import 'package:core/modules/transaction/models/transaction_aggregate_model.dart';
import 'package:core/modules/transaction/resources/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

enum TransactionCategory { mutualFund, insurance, pms }

class TransactionTabConfig {
  final String label;
  final String apiType;
  final TransactionCategory category;
  final bool Function(dynamic)? filterCondition;
  // List of transaction types allowed for this tab (e.g., only Purchase and SIP for SIF tab)
  // If null, all types defined in the logic will be shown.
  final List<String>? allowedTransactionTypes;

  TransactionTabConfig({
    required this.label,
    required this.apiType,
    required this.category,
    this.filterCondition,
    this.allowedTransactionTypes,
  });
}

class TransactionController extends GetxController
    with GetTickerProviderStateMixin {
  // List of configured tabs for the transaction screen.
  // This replaces the hardcoded list to allow for easier extension (e.g., adding SIF tab).
  late final List<TransactionTabConfig> tabs;

  List<String> get transactionTabList => tabs.map((e) => e.label).toList();

  late TransactionTabConfig selectedTabConfig;

  // Backward compatibility
  String get selectedTab => selectedTabConfig.label;

  late TabController tabController;

  ApiResponse transactionResponse = ApiResponse();

  TextEditingController searchController = TextEditingController();

  List<MfTransactionModel> _allMfTransactions = [];

  List<MfTransactionModel> get mfTransactionList {
    if (selectedTabConfig.category == TransactionCategory.mutualFund) {
      // Filter transactions based on the selected tab's condition.
      // e.g. For 'Mutual Fund' tab, exclude SIF. For 'SIF' tab, include only SIF.
      if (selectedTabConfig.filterCondition != null) {
        return _allMfTransactions
            .where((t) => selectedTabConfig.filterCondition!(t))
            .toList();
      }
      return _allMfTransactions;
    }
    return [];
  }

  List<InsuranceTransactionModel> insuranceTransactionList = [];
  List<PmsTransactionModel> pmsTransactionList = [];

  bool get isMfTabActive =>
      selectedTabConfig.category == TransactionCategory.mutualFund;

  bool get isPmsTabActive =>
      selectedTabConfig.category == TransactionCategory.pms;

  PartnerOfficeModel? partnerOfficeModel;
  Client? selectedClient;
  int? goalId;
  String? wschemecode;

  final TransactionScreenContext screenContext;

  List<String> timeOptions = [];
  String selectedTimeOption = '';

  List<String> sortOptions = [
    'Amount',
    'Date Created',
    'Date Updated',
  ];
  String selectedSortOption = 'Amount';

  DateTime? fromDate, toDate;

  Timer? _debounce;

  List<TransactionAggregate> transactionAggregates = [];

  String selectedTransactionType = 'All';
  String selectedTransactionStatus = 'All';

  final ScrollController transactionListScrollController = ScrollController();
  bool scrollToTop = false;

  // Track the current request to prevent race conditions when switching tabs
  int _requestCounter = 0;

  List get filteredTransactionList {
    if (isMfTabActive) {
      return filterMFTransactions();
    } else if (isPmsTabActive) {
      return filterPMSTransactions();
    } else {
      return filterInsuranceTransactions();
    }
  }

  TransactionController({
    this.selectedClient,
    this.goalId,
    this.wschemecode,
    this.partnerOfficeModel,
    this.screenContext = TransactionScreenContext.general,
  });

  @override
  void onInit() {
    super.onInit();

    tabs = [
      TransactionTabConfig(
        label: 'Mutual Fund',
        apiType: 'Mutual Fund',
        category: TransactionCategory.mutualFund,
        // Exclude SIF transactions from the main Mutual Fund tab
        // Exclude SIF transactions from the main Mutual Fund tab
        filterCondition: (dynamic t) {
          // For SIP Book and Portfolio views, we want to show all transactions
          // regardless of SIF status, so we bypass the specific SIF filter.
          if (screenContext.isSipBookView || screenContext.isGoalView) {
            return true;
          }
          return t is MfTransactionModel && (t.isSif != true);
        },
      ),
      TransactionTabConfig(
        label: 'SIF',
        apiType: 'Mutual Fund',
        category: TransactionCategory.mutualFund,
        // Include ONLY SIF transactions for the SIF tab
        // Include ONLY SIF transactions for the SIF tab
        filterCondition: (dynamic t) {
          // For SIP Book and Portfolio views, we want to show all transactions
          // regardless of SIF status, so we bypass the specific SIF filter.
          if (screenContext.isSipBookView || screenContext.isGoalView) {
            return true;
          }
          return t is MfTransactionModel && (t.isSif == true);
        },
        // Restrict filter options to 'Purchase' (Lumpsum) and 'SIP' for SIF tab
        allowedTransactionTypes: ['Purchase', 'SIP'],
      ),
      TransactionTabConfig(
        label: 'PMS',
        apiType: 'PMS',
        category: TransactionCategory.pms,
      ),
      TransactionTabConfig(
        label: 'Insurance',
        apiType: 'Insurance',
        category: TransactionCategory.insurance,
      ),
    ];

    // Initialize the selected tab to the first tab in the list
    selectedTabConfig = tabs.first;
    tabController = TabController(length: tabs.length, vsync: this);

    onTabChange();

    tabController.addListener(() {
      if (tabController.indexIsChanging == true) {
        onTabChange();
        EventTracker.trackTransactionsViewed(
          controller: this,
          context: getGlobalContext(),
        );
      }
    });
  }

  void onTabChange() {
    selectedTabConfig = tabs[tabController.index];

    // Common time options for both tabs
    final commonTimeOptions = [
      'Last 7 Days',
      'Last 15 Days',
      'This Month',
      'Last Month',
      'Last 3 Months',
      'This Year',
      'Custom Range',
    ];

    // Set time options based on active tab
    // Set time options based on active tab
    timeOptions = isMfTabActive || isPmsTabActive
        ? commonTimeOptions
        : [...commonTimeOptions, 'All Time'];
    selectedTimeOption = isMfTabActive || isPmsTabActive
        ? screenContext.isSipBookView
            ? 'This Month'
            : 'Last 7 Days'
        : 'All Time';
    if (selectedTimeOption == 'All Time') {
      fromDate = null;
      toDate = null;
    } else {
      final dates = DateRangeUtils.calculateDateRange(selectedTimeOption);
      fromDate = dates.$1;
      toDate = dates.$2;
    }
    selectedSortOption = 'Date Updated';
    selectedTransactionType = screenContext.isSipBookView ? 'SIP' : 'All';
    selectedTransactionStatus = 'All';
    getTransactions();
  }

  /// Call this method when the search input changes.
  void onSearchChanged() {
    final debounceDuration = const Duration(milliseconds: 300);
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      // filteredTransactionList will handle search filter
      // just need to re render UI
      scrollToTop = true;
      update();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> getTransactions() async {
    try {
      // Increment counter and capture the current request ID
      final currentRequestId = ++_requestCounter;

      _allMfTransactions = [];
      insuranceTransactionList = [];
      pmsTransactionList = [];
      transactionResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey() ?? '';

      final agentExternalIdList = await getAgentExternalIdList();
      final filters = getFilterPayload();

      // final offset = transactionMetaData.page * transactionMetaData.limit;

      final payload = <String, dynamic>{
        'agentExternalIdList': agentExternalIdList,
        'filters':
            (isMfTabActive || isPmsTabActive) ? filters : jsonEncode(filters),
        // commented due to in app sort
        // if (isMfTabActive) 'orderBy': '-$orderBy',
        if ((screenContext.isClientView || screenContext.isGoalView) &&
            isMfTabActive)
          'historical': true,
      };

      QueryResult response = await TransactionRepository().getTransactions(
        apiKey,
        payload,
        selectedTabConfig.apiType,
      );

      // Check if this response is still relevant (no newer request has been made)
      if (currentRequestId != _requestCounter) {
        // A newer request has been initiated, ignore this response
        return;
      }

      if (response.hasException) {
        transactionResponse.message =
            response.exception!.graphqlErrors[0].message;
        transactionResponse.state = NetworkState.error;
      } else {
        final currentTransactionList = WealthyCast.toList(
          isMfTabActive
              ? (response.data?['taxy']['partnerSchemeOrderDetailedView']
                  ['schemeOrderData'])
              : isPmsTabActive
                  ? (response.data?['entreat']['pmsCashflowsPartner']['data'])
                  : (response.data?['entreat']['insuranceTransactionsPartner']
                      ['data']),
        );

        if (isMfTabActive) {
          _allMfTransactions = currentTransactionList
              .map(
                  (mfTransaction) => MfTransactionModel.fromJson(mfTransaction))
              .toList();
          sortTransactions(_allMfTransactions);
          if (screenContext.showAggregateSection)
            getMFTransactionAggregatesList();
        } else if (isPmsTabActive) {
          pmsTransactionList = currentTransactionList
              .map((pmsTransaction) =>
                  PmsTransactionModel.fromJson(pmsTransaction))
              .toList();
          sortTransactions(pmsTransactionList);
          if (screenContext.showAggregateSection)
            getPmsTransactionAggregatesList();
        } else {
          insuranceTransactionList = currentTransactionList
              .map((insuranceOrder) =>
                  InsuranceTransactionModel.fromJson(insuranceOrder))
              .toList();
          sortTransactions(insuranceTransactionList);
          if (screenContext.showAggregateSection)
            getInsuranceTransactionAggregatesList();
        }

        transactionResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      transactionResponse.message = genericErrorMessage;
      transactionResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  /// Returns a filter payload map based on the current transaction type and selected filters.
  ///
  /// For Mutual Fund transactions, includes date range, client, goal, and scheme filters.
  /// For Insurance transactions, includes client filters in a different format.
  Map<String, dynamic> getFilterPayload() {
    final Map<String, dynamic> filters = {};

    // Apply Mutual Fund specific filters
    if (isMfTabActive) {
      // Date range filters (only for general or sipBook context)
      if (screenContext.showAggregateSection) {
        filters['fromDate'] = fromDate?.toUtc().toIso8601String();
        filters['toDate'] = toDate?.toUtc().toIso8601String();
      }

      // Goal detail page filters
      if (goalId != null) {
        filters['goalId'] = goalId;
      }

      // Scheme code filter
      if (wschemecode.isNotNullOrEmpty) {
        filters['wschemecode'] = wschemecode;
      }

      if (screenContext.isSipBookView) {
        filters['isSip'] = true;
      }

      // If the current tab has a specific backend filter requirement, add it here.
      // Note: Current SIF implementation filters on client side, so we don't need additional payload here
      // unless the API supports 'isSif' filter directly.
      // Assuming user requirement "you can use isSif to filterout" meant client side or just the property existence.
      // If we needed to filter only SIF from backend, we might add logic here.
      // For now, adhering to client-side filtering as per `mfTransactionList` getter.
    }

    if (isPmsTabActive) {
      if (screenContext.showAggregateSection) {
        if (fromDate != null) {
          filters['startDate'] = DateFormat('yyyy-MM-dd').format(fromDate!);
        }
        if (toDate != null) {
          filters['endDate'] = DateFormat('yyyy-MM-dd').format(toDate!);
        }
      }
    }

    // Apply client filters (different format based on transaction type)
    if (selectedClient != null) {
      if (isMfTabActive || isPmsTabActive) {
        filters['userId'] = selectedClient?.taxyID;
      } else {
        filters['user_id__in'] = [selectedClient?.taxyID];
      }
    }

    LogUtil.printLog(filters.toString(), tag: 'getFilterPayload');

    return filters;
  }

  Future<List<String>> getAgentExternalIdList() async {
    List<String> agentExternalIds = [];
    if (partnerOfficeModel != null) {
      agentExternalIds = partnerOfficeModel!.agentExternalIds;
    }
    if (agentExternalIds.isNullOrEmpty) {
      if (selectedClient?.agent?.externalId.isNotNullOrEmpty ?? false) {
        agentExternalIds = [selectedClient!.agent!.externalId!];
      } else {
        agentExternalIds = [await getAgentExternalId() ?? ''];
      }
    }
    return agentExternalIds;
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    getTransactions();
  }

  /// Filters mfTransactionList based on schemeStatus, transactionType, and search query.
  ///
  /// [schemeStatus] should be one of: 'S' (Success), 'F' (Failure), 'P' (Progress), or null for all.
  /// [transactionType] should be one of: 'SIP', 'SWP', 'STP', 'Purchase', 'Redemption', 'Switch', or null for all.
  /// [searchQuery] is matched against clientName, crn, phoneNumber, and goalName (case-insensitive, partial match).
  List<MfTransactionModel> filterMFTransactions() {
    return mfTransactionList.where((tx) {
      final matchesStatus = (selectedTransactionStatus.isNullOrEmpty ||
              selectedTransactionStatus == 'All') ||
          tx.schemeStatus?.toLowerCase() ==
              selectedTransactionStatus.toLowerCase();

      final matchesType = (selectedTransactionType.isNullOrEmpty ||
              selectedTransactionType == 'All') ||
          (tx.transactionType?.toLowerCase() ==
              selectedTransactionType.toLowerCase());

      final query = searchController.text.toLowerCase();

      final matchesSearch = query.isEmpty ||
          [
            tx.clientName,
            tx.crn,
            tx.phoneNumber,
            tx.goalName,
            tx.schemeName,
          ].any((field) => field?.toLowerCase().contains(query) ?? false);
      return matchesStatus && matchesType && matchesSearch;
    }).toList();
  }

  List<InsuranceTransactionModel> filterInsuranceTransactions() {
    return insuranceTransactionList.where((transaction) {
      // Filter by date range
      bool dateFilter = true;
      if (fromDate != null && toDate != null) {
        final transactionDate = transaction.orderStageAudit.isNotNullOrEmpty
            ? transaction.orderStageAudit?.last.stageEta
            : transaction.paymentCompletedAt;
        if (transactionDate != null) {
          dateFilter = transactionDate
                  .isAfter(fromDate!.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(toDate!.add(const Duration(days: 1)));
        }
      }

      // Filter by status
      bool statusFilter = true;
      if (selectedTransactionStatus.isNotNullOrEmpty &&
          selectedTransactionStatus.toLowerCase() != 'all') {
        statusFilter = transaction.status?.toLowerCase() ==
            selectedTransactionStatus.toLowerCase();
      }

      // Filter by insurance type
      bool typeFilter = true;
      if (selectedTransactionType.isNotNullOrEmpty &&
          selectedTransactionType.toLowerCase() != 'all') {
        typeFilter = transaction.insuranceType?.toLowerCase() ==
            selectedTransactionType.toLowerCase();
      }

      // Search filter for client name, policy name, policy number, and phone number
      bool searchFilter = true;
      if (searchController.text.isNotNullOrEmpty) {
        final query = searchController.text.toLowerCase();
        final clientName =
            transaction.userDetails?.firstOrNull?.name?.toLowerCase() ?? '';
        final clientPhone =
            transaction.userDetails?.firstOrNull?.phone?.toLowerCase() ?? '';
        final policyNo = transaction.policyNumber?.toLowerCase() ?? '';
        final policyName = transaction.name?.toLowerCase() ?? '';

        searchFilter = clientName.contains(query) ||
            clientPhone.contains(query) ||
            policyNo.contains(query) ||
            policyName.contains(query);
      }

      return dateFilter && statusFilter && typeFilter && searchFilter;
    }).toList();
  }

  List<PmsTransactionModel> filterPMSTransactions() {
    return pmsTransactionList.where((transaction) {
      final matchesStatus = (selectedTransactionStatus.isNullOrEmpty ||
              selectedTransactionStatus == 'All') ||
          transaction.status?.toLowerCase() ==
              selectedTransactionStatus.toLowerCase();

      final matchesType = (selectedTransactionType.isNullOrEmpty ||
              selectedTransactionType == 'All') ||
          (transaction.transactionType.toLowerCase() ==
              selectedTransactionType.toLowerCase());

      final query = searchController.text.toLowerCase();
      final matchesSearch = query.isEmpty ||
          [
            transaction.pmsName,
            transaction.pmsClientId,
            transaction.manufacturer,
            transaction.description,
            transaction.userName
          ].any((field) => field?.toLowerCase().contains(query) ?? false);

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  void getTransactionAggregatesList<T>({
    required List<T> transactionList,
    required String Function(T) getType,
    required String? Function(T) getStatus,
    required double Function(T) getAmount,
    String Function(String)? normalizeType,
    Map<String, String>? statusMap,
    bool includeActive = false,
  }) {
    final Map<String, TransactionAggregate> aggregates = {};
    int allS = 0, allF = 0, allP = 0, allA = 0;
    double allSAmt = 0, allFAmt = 0, allPAmt = 0, allAAmt = 0;

    for (final tx in transactionList) {
      String type = getType(tx);
      if (normalizeType != null) type = normalizeType(type);
      final status = getStatus(tx);
      final amount = getAmount(tx);

      aggregates[type] ??= TransactionAggregate(
        transactionType: type,
        successCount: 0,
        successAmount: 0.0,
        failureCount: 0,
        failureAmount: 0.0,
        progressCount: 0,
        progressAmount: 0.0,
        activeCount: 0,
        activeAmount: 0.0,
      );
      final agg = aggregates[type]!;

      String? mappedStatus = status;
      if (statusMap != null && status != null) {
        mappedStatus = statusMap[status] ?? status;
      }

      if (mappedStatus == 'S' ||
          mappedStatus == 'success' ||
          mappedStatus == 'verified') {
        agg.successCount++;
        agg.successAmount += amount;
        allS++;
        allSAmt += amount;
      } else if (mappedStatus == 'F' || mappedStatus == 'fail') {
        agg.failureCount++;
        agg.failureAmount += amount;
        allF++;
        allFAmt += amount;
      } else if (mappedStatus == 'P' || mappedStatus == 'progress') {
        agg.progressCount++;
        agg.progressAmount += amount;
        allP++;
        allPAmt += amount;
      } else if (includeActive &&
          (mappedStatus == 'A' || mappedStatus == 'active')) {
        agg.activeCount++;
        agg.activeAmount += amount;
        allA++;
        allAAmt += amount;
      }
    }

    final allAggregate = TransactionAggregate(
      transactionType: 'All',
      successCount: allS,
      successAmount: allSAmt,
      failureCount: allF,
      failureAmount: allFAmt,
      progressCount: allP,
      progressAmount: allPAmt,
      activeCount: allA,
      activeAmount: allAAmt,
    );

    transactionAggregates = [allAggregate, ...aggregates.values];
  }

  void getMFTransactionAggregatesList() {
    getTransactionAggregatesList<MfTransactionModel>(
      transactionList: mfTransactionList,
      getType: (tx) => tx.transactionType ?? '-',
      getStatus: (tx) => tx.schemeStatus,
      getAmount: (tx) => double.tryParse(tx.amount ?? '') ?? 0.0,
    );
  }

  void getInsuranceTransactionAggregatesList() {
    final timeFilteredinsuranceList =
        insuranceTransactionList.where((transaction) {
      // Filter by date range
      bool dateFilter = true;
      if (fromDate != null && toDate != null) {
        final transactionDate = transaction.orderStageAudit.isNotNullOrEmpty
            ? transaction.orderStageAudit?.last.stageEta
            : transaction.paymentCompletedAt;
        if (transactionDate != null) {
          dateFilter = transactionDate
                  .isAfter(fromDate!.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(toDate!.add(const Duration(days: 1)));
        }
      }
      return dateFilter;
    }).toList();

    getTransactionAggregatesList<InsuranceTransactionModel>(
      transactionList: timeFilteredinsuranceList,
      getType: (tx) => (tx.insuranceType ?? '-').toLowerCase(),
      getStatus: (tx) => tx.status?.toLowerCase(),
      getAmount: (tx) =>
          double.tryParse(tx.premiumWithGst?.toString() ?? '') ?? 0.0,
      normalizeType: (type) {
        if (type == 'savings') return 'Savings';
        if (type == 'term') return 'Term';
        if (type == 'health') return 'Health';
        return 'Other';
      },
      statusMap: {
        TransactionOrderStatus.RevenueRelease.toLowerCase(): 'success',
        TransactionOrderStatus.Fail.toLowerCase(): 'fail',
        TransactionOrderStatus.Create.toLowerCase(): 'progress',
        TransactionOrderStatus.Active.toLowerCase(): 'active',
      },
      includeActive: true,
    );
  }

  void getPmsTransactionAggregatesList() {
    getTransactionAggregatesList<PmsTransactionModel>(
      transactionList: pmsTransactionList,
      getType: (tx) => (tx.trnxType ?? '-'),
      getStatus: (tx) => tx.status?.toLowerCase(),
      getAmount: (tx) => double.tryParse(tx.amount ?? '') ?? 0.0,
      normalizeType: (tx) {
        if (tx == 'D') return 'Deposit';
        if (tx == 'W') return 'Withdrawal';
        return 'Other';
      },
      statusMap: {'verified': 'verified'},
    );
  }

  void sortTransactions<T>(List<T> list) {
    scrollToTop = true;
    list.sort((a, b) {
      // Handle MF Transactions
      if (a is MfTransactionModel && b is MfTransactionModel) {
        switch (selectedSortOption) {
          case 'Amount':
            final amountA = double.tryParse(a.amount ?? '0') ?? 0;
            final amountB = double.tryParse(b.amount ?? '0') ?? 0;
            return amountB.compareTo(amountA);

          case 'Date Created':
            final dateA =
                DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1900);
            final dateB =
                DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1900);
            return dateB.compareTo(dateA);

          case 'Date Updated':
            final dateA = a.lastUpdatedAt ?? DateTime(1900);
            final dateB = b.lastUpdatedAt ?? DateTime(1900);
            return dateB.compareTo(dateA);

          default:
            return 0;
        }
      }

      // Handle PMS Transactions
      if (a is PmsTransactionModel && b is PmsTransactionModel) {
        switch (selectedSortOption) {
          case 'Amount':
            final amountA = double.tryParse(a.amount ?? '0') ?? 0;
            final amountB = double.tryParse(b.amount ?? '0') ?? 0;
            return amountB.compareTo(amountA);

          case 'Date Created':
          case 'Date Updated':
            final dateA = a.trnxDate ?? DateTime(1900);
            final dateB = b.trnxDate ?? DateTime(1900);
            return dateB.compareTo(dateA);

          default:
            return 0;
        }
      }

      // Handle Insurance Transactions
      if (a is InsuranceTransactionModel && b is InsuranceTransactionModel) {
        switch (selectedSortOption) {
          case 'Amount':
            return (b.premiumWithGst ?? 0).compareTo(a.premiumWithGst ?? 0);

          case 'Date Created':
            final dateA = a.policyIssueDate ?? DateTime(1900);
            final dateB = b.policyIssueDate ?? DateTime(1900);
            return dateB.compareTo(dateA);

          case 'Date Updated':
            final dateA = a.orderStageAudit?.lastOrNull?.stageEta ??
                a.paymentCompletedAt ??
                DateTime(1900);
            final dateB = b.orderStageAudit?.lastOrNull?.stageEta ??
                b.paymentCompletedAt ??
                DateTime(1900);
            return dateB.compareTo(dateA);

          default:
            return 0;
        }
      }

      return 0;
    });
  }

  // Call this to always scroll to top
  void scrollTransactionListToTop() {
    if (transactionListScrollController.hasClients && scrollToTop) {
      transactionListScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      scrollToTop = false;
    }
  }
}
