import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:confetti/confetti.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/kyc/initiate_partner_kyc_model.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:permission_handler/permission_handler.dart';

class PartnerKycController extends GetxController {
  //Fields
  late TextEditingController panNumberController;
  late TextEditingController emailController;
  late TextEditingController gstNumberController;
  late TextEditingController dobController;

  DateTime? pickedDob;

  late AdvisorOverviewRepository advisorOverviewRepository;

  List<String>? partnerTypes;
  String? selectedPartnerType;
  String? kycInitMsg;
  int? euinSelected;
  String? euin;
  bool? isPartnerArnSearching;
  String? fromScreen;
  String? kycUrl;
  int? kycStatus;
  bool isDigioGstVerificationFailed = false;
  bool isGstPanLinkDeclared = false;
  String corporateName = '';

  String? apiKey;
  bool? isAadharLinked = false;
  bool isGstNotAvailableDeclared = false;
  AgentModel? agent;
  NetworkState? getAgentDetailState;
  NetworkState? getStartKYCState;
  NetworkState? verifyGstState;
  NetworkState? saveGstState;

  //KYC Status Field
  ConfettiController? confettiControllerKYCStatus;
  late String titleKYCStatus;
  late String subtitleKYCStatus;
  String? iconUrlKYCStatus;
  bool showConfettiKYCStatus = false;

  dynamic updatedPartnerDetailsData;
  String? updatePartnerDetailsErrorMessage;
  String? saveGstErrorMessage;
  NetworkState updatePartnerState = NetworkState.loading;

  KycPanUsageType panUsageType = KycPanUsageType.INDIVIDUAL;

  PartnerKycController({AgentModel? agentDetail}) {
    getAgentDetailState = NetworkState.loading;
    panNumberController = TextEditingController();
    emailController = TextEditingController();
    gstNumberController = TextEditingController();
    dobController = TextEditingController();
    advisorOverviewRepository = AdvisorOverviewRepository();

    getApiKey().then((value) {
      apiKey = value;
    });

    if (agentDetail != null) {
      isAadharLinked = agentDetail.aadhaarLinked;
      agent = agentDetail;

      if (agent?.panNumber != null) {
        panNumberController.text = agent!.panNumber ?? '';
      }
      if (agent?.email != null) {
        emailController.text = agent!.email!;
      }

      if (agent?.gst?.gstin != null) {
        gstNumberController.text = agent?.gst?.gstin ?? '';
      }

      getAgentDetailState = NetworkState.loaded;
      update();
    } else {
      getAgentDetails();
    }
  }

  @override
  void onInit() {
    partnerTypes = ['Individual', 'Company'];
    selectedPartnerType = 'Individual';
    panNumberController.addListener(() {
      if (panNumberController.text.length != 10 &&
          verifyGstState == NetworkState.loaded) {
        verifyGstState = NetworkState.cancel;
        corporateName = '';
        isGstPanLinkDeclared = false;
      }
      update();
    });
    kycInitMsg = '';
    euinSelected = -1;
    euin = '';
    isPartnerArnSearching = false;
    fromScreen = '';
    kycUrl = '';
    super.onInit();
  }

  @override
  void dispose() {
    panNumberController.dispose();
    emailController.dispose();
    confettiControllerKYCStatus!.dispose();

    super.dispose();
  }

  void initKYCStatusScreen({int? kycStatusData}) {
    if (kycStatusData != null) {
      kycStatus = kycStatusData;
    }
    if (kycStatus == AgentKycStatus.APPROVED) {
      confettiControllerKYCStatus =
          ConfettiController(duration: const Duration(seconds: 5));

      confettiControllerKYCStatus?.play();
      Future.delayed(Duration(seconds: 3), () {
        if (confettiControllerKYCStatus != null) {
          //todo update
          confettiControllerKYCStatus?.stop();
        }
      });
      titleKYCStatus = 'KYC approved!';
      subtitleKYCStatus = '';
      iconUrlKYCStatus = AllImages().kycSuccess;
      showConfettiKYCStatus = true;
    } else if (kycStatus == AgentKycStatus.SUBMITTED) {
      titleKYCStatus = 'Your KYC is submitted!';
      subtitleKYCStatus = 'We will notify you as soon as it is processed!';
      iconUrlKYCStatus = AllImages().kycPending;
    } else if (kycStatus == AgentKycStatus.REJECTED) {
      titleKYCStatus = 'KYC Failed';
      subtitleKYCStatus =
          'Please ensure your personal and PAN \ndetails are correct.';
      iconUrlKYCStatus = AllImages().kycFail;
    } else {
      titleKYCStatus = kycStatus == AgentKycStatus.INPROGRESS
          ? 'KYC In Progress'
          : kycStatus == AgentKycStatus.INITIATED
              ? 'KYC Initiated'
              : 'KYC Missing';
      subtitleKYCStatus = 'Please Complete your Kyc';
      iconUrlKYCStatus = AllImages().kycPending;
    }
  }

  Future<void> getAgentDetails({bool updateKYCStatusScreen = false}) async {
    try {
      getAgentDetailState = NetworkState.loading;
      update();
      apiKey ??= await getApiKey();
      final response = await advisorOverviewRepository.getAdvisorOverview(
          DateTime.now().year, DateTime.now().month, apiKey!);
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        getAgentDetailState = NetworkState.error;
      } else {
        AdvisorOverviewModel advisorOverview =
            AdvisorOverviewModel.fromJson(response.data['hydra']);
        agent = advisorOverview.agent;
        panNumberController.text = agent?.panNumber ?? '';
        emailController.text = agent?.email ?? '';
        gstNumberController.text = agent?.gst?.gstin ?? '';
        getAgentDetailState = NetworkState.loaded;
        isAadharLinked = agent?.aadhaarLinked ?? false;

        // if (agent!.kycStatus != AgentKycStatus.APPROVED &&
        //     gstNumberController.text.isNotEmpty &&
        //     agent!.gst?.verifiedAt == null) {
        //   verifyGst();
        // }
        if (updateKYCStatusScreen) {
          initKYCStatusScreen(kycStatusData: agent?.kycStatus);
        }
      }
    } catch (error) {
      getAgentDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  void toggleGstDeclaration() {
    isGstNotAvailableDeclared = !isGstNotAvailableDeclared;

    if (isGstNotAvailableDeclared) {
      gstNumberController.clear();
    }
    update();
  }

  void switchPanUsageType(KycPanUsageType newPanUsageType) {
    panUsageType = newPanUsageType;
    update();
  }

  void onPartnerTypeSelected(String partnerType) {
    selectedPartnerType = partnerType;
    update();
  }

  Future<int?> startKYC(
    String panNumber,
    String? phoneNumber,
    String email,
    bool? isAadharLinked,
  ) async {
    getStartKYCState = NetworkState.loading;
    update();
    LogUtil.printLog('$phoneNumber  $email');
    final kycPermission = await getKYCPermissions();

    if (kycPermission) {
      dynamic data = await advisorOverviewRepository.initiateKyc(
        apiKey!,
        panNumber,
        email,
        isAadharLinked!,
        DateFormat('yyyy-MM-dd').format(pickedDob!),
        panUsageType.name,
      );

      // Even if GST not provided, we still call verify GST Api to populate gst_denied at timestamp
      // await saveGst();

      if (data is InitiatePartnerKycModel) {
        kycUrl = data.kycUrl;
        kycStatus = AgentKycStatus.INITIATED;
      } else {
        kycInitMsg = data;
        kycStatus = AgentKycStatus.FAILED;
      }
      getStartKYCState = NetworkState.loaded;
      update();
      return kycStatus;
    } else {
      kycInitMsg = 'Provide the required permissions to submit KYC';
      getStartKYCState = NetworkState.error;
      kycStatus = AgentKycStatus.FAILED;
      update();

      return kycStatus;
    }
  }

  Future<Map<String, dynamic>> checkARNStatus() async {
    dynamic data = await advisorOverviewRepository.checkARNStatus(apiKey!);
    if (data is PartnerArnModel) {
      Map<String, dynamic> response = {
        "message": "success",
        "status": 1,
      };
      List<dynamic> euinList = [];

      if (data.euin!.isNotEmpty) {
        euinList.add(data.euin);
      }

      if (data.additionalEuins!.length > 0) {
        euinList.addAll(data.additionalEuins!);
      }

      response['euins'] = euinList;
      response['arn'] = data.arn;
      response['externalId'] = data.externalId;
      response['isArnActive'] = data.isArnActive;
      response['arnValidTill'] = data.arnValidTill;
      response['nameAsPerArn'] = data.nameAsPerArn;
      return response;
    } else {
      return {"message": data, "status": 0};
    }
  }

  Future<Map<String, dynamic>> attachArn(String externalId, String euin) async {
    dynamic data =
        await advisorOverviewRepository.attachEUIN(apiKey!, externalId, euin);
    if (data is PartnerArnModel) {
      Map<String, dynamic> response = {
        "message": "success",
        "status": 1,
      };

      return response;
    } else {
      return {"message": data, "status": 0};
    }
  }

  Future<RestApiResponse> searchPartnerArn() async {
    RestApiResponse result = RestApiResponse();
    try {
      var response = await advisorOverviewRepository.searchParnterArn(apiKey!);

      if (response.exception != null) {
        if (response?.exception?.linkException != null ||
            response.exception.graphqlErrors.length == 0) {
          result.message =
              'we couldn’t find your ARN this time. Check again in some time';
        } else {
          result.message = response.exception.graphqlErrors[0].message;
        }
        result.status = 0;
        // updatePartnerState = NetworkState.error;
      } else {
        dynamic data = response.data['searchPartnerArn'];
        if (data != null) {
          data = PartnerArnModel.fromJson(data['partnerArnNode']);
        }
        result.status = 1;
        result.data = data;
        // updatePartnerState = NetworkState.loaded;
        // updatedPartnerDetailsData = data;
      }
    } catch (error) {
      result.status = 0;
      result.message = "Something went wrong! Please try again";
      // updatePartnerState = NetworkState.error;
      // updatePartnerDetailsErrorMessage = 'Something went wrong';
    }

    return result;
  }

  Future<bool> getKYCPermissions() async {
    List<Permission> permissionList = [
      Permission.camera,
      Permission.mediaLibrary,
    ];

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // permissionList.add(Permission.photos);
      } else {
        permissionList.add(Permission.storage);
      }
    } else {
      permissionList.add(Permission.storage);
    }

    Map<Permission, PermissionStatus> permissionStatuses =
        await permissionList.request();

    bool isAllPermissionsGranted = true;

    for (Permission permission in permissionStatuses.keys) {
      if (!permissionStatuses[permission]!.isGranted) {
        isAllPermissionsGranted = false;
        break;
      }
    }

    return isAllPermissionsGranted;
  }

  Future<void> verifyGst({bool showLoader = true}) async {
    if (showLoader) {
      verifyGstState = NetworkState.loading;
      update();
    }

    try {
      Map<String, dynamic> payload = {
        "gst": gstNumberController.text,
        "pan_number": panNumberController.text
      };

      var data = await AdvisorOverviewRepository().verifyGst(apiKey!, payload);

      if (data["status"] == "200") {
        bool isGstValid = data["response"]["is_valid"] ?? false;
        isDigioGstVerificationFailed = !isGstValid;
        verifyGstState = NetworkState.loaded;

        if (isGstValid) {
          corporateName = data["response"]["message"] ?? '';
        }
      } else {
        verifyGstState = NetworkState.error;
        String errorMessage = getErrorMessageFromResponse(data["response"],
            defaultMessage:
                'Invalid GST. Please make sure PAN is associated with GST');
        showToast(text: errorMessage);
      }
    } catch (error) {
      verifyGstState = NetworkState.error;
      showToast(text: "Invalid GST");
    } finally {
      update();
    }
  }

  Future<void> saveGst() async {
    saveGstState = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = {
        "gst": gstNumberController.text,
        "pan_number": panNumberController.text
      };

      if (isGstNotAvailableDeclared) {
        payload["gst_denied"] = true;
      }

      var response =
          await AdvisorOverviewRepository().saveGst(apiKey!, payload);

      if (response["status"] == "200") {
        saveGstState = NetworkState.loaded;
      } else {
        saveGstState = NetworkState.error;
        saveGstErrorMessage = getErrorMessageFromResponse(response["response"]);
      }
    } catch (error) {
      saveGstState = NetworkState.error;
      saveGstErrorMessage = "Please enter a valid GST";
    } finally {
      update();
    }
  }

  void resetGstInput() {
    verifyGstState = NetworkState.cancel;
    corporateName = '';
    isGstPanLinkDeclared = false;
    gstNumberController.clear();
    update();
  }

  void onEuinSelected(int index) {
    euinSelected = index;
    update();
  }

  void toggleGstPanLinkDeclared() {
    isGstPanLinkDeclared = !isGstPanLinkDeclared;
    update();
  }
}
