import 'dart:convert';

import 'package:api_sdk/api_collection/common_api.dart';
import 'package:api_sdk/api_collection/proposal_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:dio/dio.dart';

class ProposalRepository {
  Future<dynamic> getProposalsListv2(
    String apiKey,
    int agentId,
    Map<String, dynamic> payload, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await ProposalAPI.getProposalsListv2(
        apiKey,
        agentId,
        payload,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
      throw e;
    }
  }

  Future<dynamic> getProposalData(String apiKey, String proposalId) async {
    try {
      final response = await ProposalAPI.getProposal(apiKey, proposalId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> markProposalFail(
    String apiKey,
    String proposalId,
    String reason,
    String agentId,
  ) async {
    try {
      final payload = {"reason": reason};
      final response = await ProposalAPI.markProposalFailurev2(
        apiKey: apiKey,
        proposalId: proposalId,
        body: payload,
        agentId: agentId,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> updateProposal(String apiKey, int agentId, String proposalId,
      String lumsumAmount, dynamic productExtrasJson) async {
    try {
      final payload = {
        "agent_id": agentId,
        "lumsum_amount": lumsumAmount,
        "product_extras": productExtrasJson
      };
      final response = await CommonAPI.updateProposalData(
          apiKey, proposalId, json.encode(payload));
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  Future<dynamic> getProposalUrl(String apiKey, agentId, payload) async {
    try {
      final response =
          await CommonAPI.getProposalUrl(apiKey, json.encode(payload));

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getProposalEditUrl(String apiKey, proposalId) async {
    try {
      final response = await ProposalAPI.getProposalEditUrl(apiKey, proposalId);

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<dynamic> getProposalCount(
      {required String apiKey, String userId = ''}) async {
    try {
      final response = await ProposalAPI.getProposalCount(apiKey, userId);

      return response;
    } catch (error) {
      LogUtil.printLog("error $error");
    }
  }

  Future<dynamic> getSchemeOrderStatus(
      {required String apiKey,
      required String proposalId,
      required String userId}) async {
    try {
      final response = await ProposalAPI.getSchemeOrderStatus(apiKey,
          proposalId: proposalId, userId: userId);

      return response;
    } catch (error) {
      LogUtil.printLog("error $error");
    }
  }
}
