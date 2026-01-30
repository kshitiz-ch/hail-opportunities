import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/insurance_detail_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ProposalDetailController extends GetxController {
  // Fields
  ProposalModel? proposal;
  String? apiKey = '';
  final ScrollController scrollController = ScrollController();

  bool isMicroSIP = false;
  bool isCustom = false;
  bool isSmartSwitch = false;

  NetworkState? proposalDetailState = NetworkState.cancel;
  NetworkState? fundsState = NetworkState.cancel;
  NetworkState? proposalDataState;
  NetworkState? updateProposalState;
  NetworkState? getInsuranceEditUrlState;
  NetworkState? checkingWebViewState;

  ProposalModel proposalDetail = ProposalModel(userProfileStatuses: []);
  StoreFundAllocation fundsResult = StoreFundAllocation();

  InvestmentType? investmentType = InvestmentType.oneTime;
  int? selectedSipDay = 5;
  int? selectedSwitchPeriod;

  String proposalErrorMessage = '';
  String fundsErrorMessage = '';
  String updateProposalErrorMessage = '';

  int fundsListCount = 3;

  // Constructor
  ProposalDetailController(this.proposal) {
    if (proposal?.displayName == null) {
      getProposalData();
    }
  }

  bool get hasNfoFunds {
    if ((fundsResult.schemeMetas ?? []).isNotEmpty) {
      return fundsResult.schemeMetas!
          .any((element) => element.isNfoFund == true);
    }

    return false;
  }

  @override
  void onInit() {
    // proposalDetailState = NetworkState.loading;
    // fundsState = NetworkState.loading;

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();

    if (proposal?.displayName != null &&
        !([ProductVariant.demat, ProductVariant.switchTracker]
            .contains(proposal?.productTypeVariant))) {
      await getProposalDetails();
    } else {
      proposalDetailState = NetworkState.loaded;
    }

    if (proposal?.productType == ProductType.MF &&
        proposal?.productTypeVariant != ProductVariant.switchTracker) {
      await getPortfolioFunds();
    }
  }

  /// Get Proposal data from the API
  Future<void> getProposalDetails(
      {bool isRetry = false, shouldUpdateProposalData = false}) async {
    proposalDetailState = NetworkState.loading;
    update(['proposal', 'action-button']);

    try {
      final response = await ProposalRepository()
          .getProposalData(apiKey!, proposal!.externalId!);

      if (response != null && response['status'] == '200') {
        final Map<String, dynamic> data = response['response'];

        proposalDetail = ProposalModel.fromJson(data);
        if (shouldUpdateProposalData) {
          proposal = ProposalModel.fromJson(data);
        }
      } else {
        proposalDetail = proposal!;
      }

      if (proposal!.productType == ProductType.MF) {
        isSmartSwitch = proposalDetail.productInfo?.isSmartSwitch ?? false;
        isMicroSIP = proposalDetail.productTypeVariant == microSipGoalSubtype;
        isCustom = proposalDetail.productTypeVariant == otherFundsGoalSubtype ||
            proposalDetail.productTypeVariant == anyFundGoalSubtype;

        investmentType = getInvestmentTypeFromString(
          proposalDetail.productExtrasJson!['order_type'],
        );

        if (isSmartSwitch) {
          selectedSwitchPeriod =
              proposalDetail.productExtrasJson!['switch_period'];
        }

        if (investmentType == InvestmentType.SIP) {
          try {
            selectedSipDay =
                proposalDetail.productExtrasJson!['sip']['sip_day'];
          } catch (e) {}
        }
      }

      proposalDetailState = NetworkState.loaded;
    } catch (e) {
      LogUtil.printLog(e.toString());
      proposalErrorMessage = 'Something went wrong';
      proposalDetailState = NetworkState.error;
    } finally {
      update(['proposal', 'action-button']);
    }
  }

  Future<void> getProposalData() async {
    proposalDataState = NetworkState.loading;
    update(['proposal-data']);

    try {
      String apiKey = (await getApiKey())!;
      final response = await ProposalRepository()
          .getProposalData(apiKey, proposal!.externalId!);

      if (response['status'] == '200') {
        final Map<String, dynamic> data = response['response'];

        proposal = ProposalModel.fromJson(data);

        getProposalDetails();

        if (proposal?.productType == ProductType.MF) {
          getPortfolioFunds();
        }

        proposalDataState = NetworkState.loaded;
      } else {
        proposalDataState = NetworkState.error;
      }
    } catch (error) {
      proposalDataState = NetworkState.error;
    } finally {
      update(['proposal-data']);
    }
  }

  // Get Funds in the portfolio from the API
  Future<void> getPortfolioFunds([
    String? userId,
  ]) async {
    String wSchemeCodes = '';
    String delimeter = ",";

    List schemes = proposal!.productExtrasJson != null
        ? (proposal!.productExtrasJson?['order_funds'] ??
            proposal!.productExtrasJson!['funds'])
        : [];

    fundsState = NetworkState.loading;
    update(['funds', 'action-button']);

    try {
      if (schemes.isNotEmpty) {
        schemes.forEach((scheme) {
          wSchemeCodes += scheme["wschemecode"] + delimeter;
        });
      }

      final QueryResult response =
          await StoreAPI.getSchemeData(apiKey!, userId, wSchemeCodes);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        fundsErrorMessage = "Something went wrong";
        fundsState = NetworkState.error;
      } else {
        fundsResult = StoreFundAllocation.fromJson(response.data!['metahouse']);
        fundsResult.schemeMetas!.forEach(
          (schemeMeta) {
            Iterable temp = schemes.where(
              (scheme) => schemeMeta.wschemecode == scheme['wschemecode'],
            );
            if (temp.isNotEmpty) {
              schemeMeta.idealWeight = temp.first["ideal_weight"] ?? 0;
              // TODO: check why amount is integer
              if (temp.first["amount"] != null) {
                schemeMeta.amountEntered =
                    WealthyCast.toDouble(temp.first["amount"]);
              } else if (schemeMeta.idealWeight != null &&
                  proposal?.productInfo?.goalType != GoalType.CUSTOM) {
                schemeMeta.amountEntered = WealthyCast.toDouble(
                    (schemeMeta.idealWeight! / 100) * proposal!.lumsumAmount!);
              }

              // TODO: Add Later
              if (temp.first['folio_number'] != null) {
                schemeMeta.folioOverview?.folioNumber =
                    temp.first['folio_number'].toString();
              }
            }
          },
        );

        // Sort by amc
        fundsResult.schemeMetas!.sort((a, b) => a.amc!.compareTo(b.amc!));

        fundsState = NetworkState.loaded;

        String proposalId = proposal?.externalId ?? '';

        // if (proposal?.userProductOrderId != null &&
        //     proposal!.userProductOrderId!.isNotEmpty) {
        //   proposalId = proposal!.userProductOrderId!;
        // } else if (proposal!.productExtrasJson!['downstream_resp'] != null &&
        //     proposal!.productExtrasJson!['downstream_resp']['order'] != null) {
        //   proposalId =
        //       proposal!.productExtrasJson!['downstream_resp']['order']['id'];
        // }

        if (proposalId.isNotNullOrEmpty) {
          try {
            final QueryResult orderStatusResponse = await ProposalRepository()
                .getSchemeOrderStatus(
                    apiKey: apiKey!,
                    userId: proposal?.customer?.taxyID ?? '',
                    proposalId: proposalId);

            if (orderStatusResponse.hasException) {
              LogUtil.printLog("Something went wrong");
            } else {
              List ordersList =
                  List.from(orderStatusResponse.data!['taxy']['orders']);
              List schemeOrdersList =
                  List.from(ordersList.first["schemeorders"]);

              fundsResult.schemeMetas!.forEach((schemeMeta) {
                Iterable temp = schemeOrdersList.where((scheme) {
                  LogUtil.printLog(scheme);
                  LogUtil.printLog(scheme['wschemecode']);
                  return schemeMeta.wschemecode == scheme['wschemecode'];
                });

                if (temp.isNotEmpty) {
                  schemeMeta.schemeStatus = temp.first["schemeStatus"];
                }
              });
              // schemeOrdersList.forEach((element) {

              // });
            }

            LogUtil.printLog(fundsResult.schemeMetas);
          } catch (error) {
            LogUtil.printLog(error);
          }
        }
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      fundsErrorMessage = "Something went wrong";
      fundsState = NetworkState.error;
    } finally {
      update(['funds', 'action-button']);
    }
  }

  void updateFundsListCount(int itemCount) {
    fundsListCount = itemCount;
    update(['funds']);
  }

  /// Get url for editing Insurances
  Future<String?> getProposalEditUrl() async {
    String? customerUrl = '';

    getInsuranceEditUrlState = NetworkState.loading;
    update(['edit-proposal']);

    try {
      final response = await ProposalRepository().getProposalEditUrl(
        apiKey!,
        proposal!.externalId,
      );

      if (response['status'] == '200') {
        customerUrl = response['response']['url'];
        getInsuranceEditUrlState = NetworkState.loaded;
      } else {
        getInsuranceEditUrlState = NetworkState.error;
      }
    } catch (e) {
      getInsuranceEditUrlState = NetworkState.error;
      LogUtil.printLog(e.toString());
    } finally {
      // if (errorMessage.isNotEmpty) {
      //   showToast(
      //     text: updateProposalErrorMessage,
      //   );
      // }

      update(['edit-proposal']);
    }

    return customerUrl;
  }

  Future<bool?> shouldOpenWebView(String productVariant) async {
    checkingWebViewState = NetworkState.loading;
    update(['edit-proposal']);
    bool? viaWebView = false;
    try {
      final data =
          await StoreRepository().getInsuranceProductDetail(productVariant);

      if (data['status'] == "200") {
        InsuranceDetailModel insuranceDetailModel =
            InsuranceDetailModel.fromJson(data['response']);
        viaWebView = insuranceDetailModel.viaWebView;
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      checkingWebViewState = NetworkState.loaded;
      update(['edit-proposal']);
    }

    return viaWebView;
  }
}

class SwitchTrackerSchemeModel {
  String? amc;
  double? amount;
  String? folioNumber;
  bool? full;
  String? fundName;
  String? isin;
  double? units;
  String? wschemecode;

  SwitchTrackerSchemeModel({
    this.amc,
    this.amount,
    this.folioNumber,
    this.full,
    this.fundName,
    this.isin,
    this.units,
    this.wschemecode,
  });

  SwitchTrackerSchemeModel.fromJson(Map<String, dynamic> json) {
    amc = WealthyCast.toStr(json['amc']);
    amount = WealthyCast.toDouble(json['amount']);
    folioNumber = WealthyCast.toStr(json['folio_number']);
    full = WealthyCast.toBool(json['full']);
    fundName = WealthyCast.toStr(json['fund_name']);
    isin = WealthyCast.toStr(json['isin']);
    units = WealthyCast.toDouble(json['units']);
    wschemecode = WealthyCast.toStr(json['wschemecode']);
  }
}
