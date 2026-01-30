import 'dart:math';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

enum NomineeType { MF, TRADING }

class ClientNomineeController extends GetxController {
  ApiResponse nomineeListResponse = ApiResponse();
  ApiResponse nomineeBreakdownResponse = ApiResponse();
  Client? client;

  List<ClientNomineeModel> mfNominees = [];
  List<ClientNomineeModel> userNominees = [];
  List<ClientNomineeModel> brokingNominees = [];

  TextEditingController nomineeOnePercentage = TextEditingController();
  TextEditingController nomineeTwoPercentage = TextEditingController();
  TextEditingController nomineeThreePercentage = TextEditingController();

  List<NomineeBreakdown> nomineeBreakdowns = [];

  bool shouldSplitPercentageEqually = false;

  bool get nomineePercentageEqual {
    if (nomineeBreakdowns.isEmpty) {
      return false;
    }

    int totalPercentage = 0;

    nomineeBreakdowns.forEach((breakdown) {
      int percentage = WealthyCast.toInt(breakdown.controller.text) ?? 0;
      totalPercentage += percentage;
    });

    return totalPercentage == 100;
  }

  void onInit() {
    getClientNominees();

    super.onInit();
  }

  ClientNomineeController(this.client);

  Future<dynamic> getClientNominees() async {
    nomineeListResponse.state = NetworkState.loading;
    mfNominees.clear();
    brokingNominees.clear();
    userNominees.clear();

    update();

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .getClientNominees(apiKey, client?.taxyID ?? '');

      if (response.hasException) {
        nomineeListResponse.state = NetworkState.error;
        nomineeListResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        var data = response.data!["hagrid"];
        List mfNominessJson = WealthyCast.toList(data["mfNominees"]);
        List userNominessJson = WealthyCast.toList(data["userNominees"]);
        List brokingNomineesJson = WealthyCast.toList(data["brokingNominees"]);

        mfNominessJson.forEach((nominee) {
          ClientNomineeModel nomineeModel =
              ClientNomineeModel.fromJson(nominee["nominee"]);

          nomineeModel.percentage = nominee["percentage"];

          mfNominees.add(nomineeModel);
        });

        brokingNomineesJson.forEach((nominee) {
          ClientNomineeModel nomineeModel =
              ClientNomineeModel.fromJson(nominee["nominee"]);

          nomineeModel.percentage = nominee["percentage"];

          brokingNominees.add(nomineeModel);
        });

        userNominessJson.forEach((nominee) {
          userNominees.add(ClientNomineeModel.fromJson(nominee));
        });

        nomineeListResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      nomineeListResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  // Nominee Breakdown Logic
  // =======================
  Future<dynamic> updateNomineeBreakdown() async {
    nomineeBreakdownResponse.state = NetworkState.loading;
    update([GetxId.nomineeBreakdowns]);

    try {
      String apiKey = await getApiKey() ?? '';
      List<Map<String, dynamic>> payload = [];
      nomineeBreakdowns.forEach((breakdown) {
        payload.add({
          "nomineeId": breakdown.nominee.externalId,
          "percentage": WealthyCast.toInt(breakdown.controller.text) ?? 0
        });
      });

      QueryResult response = await ClientProfileRepository()
          .createMfNominees(apiKey, client?.taxyID ?? '', payload);

      if (response.hasException) {
        nomineeBreakdownResponse.state = NetworkState.error;
        nomineeBreakdownResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        nomineeBreakdownResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      nomineeBreakdownResponse.state = NetworkState.error;
    } finally {
      update([GetxId.nomineeBreakdowns]);
    }
  }

  void toggleSplitPercentageEqually(NomineeType nomineeType) {
    shouldSplitPercentageEqually = !shouldSplitPercentageEqually;

    if (shouldSplitPercentageEqually) {
      int avgPercentage = (100 / nomineeBreakdowns.length).floor();
      splitNomineePercentageEqually(avgPercentage);
    } else {
      assignNomineeBreakdowns(nomineeType);
    }

    update([GetxId.nomineeBreakdowns]);
  }

  void splitNomineePercentageEqually(int avgPercentage) {
    nomineeBreakdowns.forEach((NomineeBreakdown breakdown) {
      breakdown.controller.text = avgPercentage.toString();
    });
  }

  void assignNomineeBreakdowns(NomineeType nomineeType) {
    nomineeBreakdowns.clear();

    List<ClientNomineeModel> nominees =
        nomineeType == NomineeType.MF ? mfNominees : brokingNominees;

    nominees.forEach((ClientNomineeModel nominee) {
      int percentage = nominee.percentage ?? 0;
      nomineeBreakdowns.add(
        NomineeBreakdown(
          nominee: nominee,
          controller: TextEditingController(
            text: percentage.toString(),
          ),
        ),
      );
    });

    update([GetxId.nomineeBreakdowns]);
  }

  void deleteNomineeBreakdown(int index) {
    nomineeBreakdowns.removeAt(index);
    update([GetxId.nomineeBreakdowns]);
  }

  void replaceNomineeBreakdown(int index, ClientNomineeModel nominee) {
    int percentage =
        WealthyCast.toInt(nomineeBreakdowns[index].controller.text) ?? 0;

    nomineeBreakdowns[index] = NomineeBreakdown(
      nominee: nominee,
      controller: TextEditingController(
        text: percentage.toString(),
      ),
    );
    update([GetxId.nomineeBreakdowns]);
  }

  void addNomineeBreakdown(ClientNomineeModel nominee) {
    int percentage;

    if (shouldSplitPercentageEqually) {
      percentage = (100 / (nomineeBreakdowns.length + 1)).floor();
      splitNomineePercentageEqually(percentage);
    } else {
      int totalPercentage = 0;
      nomineeBreakdowns.forEach((breakdown) {
        totalPercentage += WealthyCast.toInt(breakdown.controller.text) ?? 0;
      });
      percentage = 100 - totalPercentage;
    }

    nomineeBreakdowns.add(NomineeBreakdown(
      nominee: nominee,
      controller: TextEditingController(
        text: percentage.toString(),
      ),
    ));
    update([GetxId.nomineeBreakdowns]);
  }
}

class NomineeBreakdown {
  ClientNomineeModel nominee;
  TextEditingController controller;

  NomineeBreakdown({
    required this.nominee,
    required this.controller,
  });
}

String getNomineeTypeDescription(NomineeType nomineeType) {
  if (nomineeType == NomineeType.MF) {
    return 'Mutual Fund';
  } else {
    return 'Stocks';
  }
}
