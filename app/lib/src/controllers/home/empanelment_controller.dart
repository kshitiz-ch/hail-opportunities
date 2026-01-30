import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/models/country_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/empanelment_address_model.dart';
import 'package:core/modules/dashboard/models/kyc/empanelment_model.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

class EmpanelmentController extends GetxController {
  // late Razorpay _razorpay;
  String orderId = '';

  bool isTcAgreed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  EmpanelmentModel? empanelmentData;
  BuildContext context;

  TextEditingController addressLineOneController = TextEditingController();
  TextEditingController addressLineTwoController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  NetworkState empanelmentState = NetworkState.cancel;
  NetworkState validateEmpanelmentState = NetworkState.cancel;

  List<CountryModel> countries = [];

  bool showPaymentFailedDialog = false;
  bool showInProgressDialog = false;

  ApiResponse storeEmpanelmentAddressResponse = ApiResponse();
  ApiResponse payEmpanelmentFeeResponse = ApiResponse();

  AdvisorOverviewModel? advisorOverview;

  EmpanelmentAddressModel? empanelmentAddress;
  ApiResponse empanelmentAddressResponse = ApiResponse();

  bool get isAddressMissing {
    return (empanelmentAddress?.externalId ?? "").isNullOrEmpty;
  }

  bool get isOrderIdExists {
    return empanelmentData?.thirdPartyOrderId?.isNotNullOrEmpty ?? false;
  }

  bool get isArnHolder {
    PartnerArnModel? partnerArn = advisorOverview?.partnerArn;

    if (partnerArn?.status == ArnStatus.Rejected) {
      return false;
    } else if (partnerArn?.status == ArnStatus.Pending) {
      return false;
    } else if (partnerArn?.status == ArnStatus.Approved ||
        partnerArn?.status == null) {
      return partnerArn?.isArnActive == true;
    } else {
      return false;
    }
  }

  EmpanelmentController({
    required this.advisorOverview,
    required this.context,
  });

  @override
  void onInit() {
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getAgentEmpanelmentDetails();
    getCountriesData();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    // _razorpay.clear();
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   Map<String, dynamic> payload = {
  //     "razorpay_signature": response.signature,
  //     "razorpay_payment_id": response.paymentId,
  //     "razorpay_order_id":
  //         response.orderId ?? empanelmentData?.thirdPartyOrderId
  //   };

  //   await validateEmpanelment(payload);
  //   getAgentEmpanelmentDetails();
  // }

  // void _handlePaymentError(PaymentFailureResponse response) async {
  //   getAgentEmpanelmentDetails(showDialog: true);
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> storeEmpanelmentAddress() async {
    storeEmpanelmentAddressResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        "line1": addressLineOneController.text,
        "line2": addressLineTwoController.text,
        "city": cityController.text,
        "state": stateController.text,
        "postalCode": WealthyCast.toInt(pincodeController.text),
        "country": countryController.text
      };

      QueryResult response = await AdvisorOverviewRepository()
          .storeEmpanelmentAddress(apiKey, payload);

      if (response.hasException) {
        storeEmpanelmentAddressResponse.state = NetworkState.error;
        storeEmpanelmentAddressResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        storeEmpanelmentAddressResponse.state = NetworkState.loaded;
        await payEmpanelmentFee();
      }
    } catch (error) {
      storeEmpanelmentAddressResponse.state = NetworkState.error;
      storeEmpanelmentAddressResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getAgentEmpanelmentDetails({showDialog = false}) async {
    empanelmentState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';

      if (advisorOverview == null) {
        await getAdvisorOverview();
      }

      if (advisorOverview == null) {
        throw Exception();
      }

      QueryResult response =
          await AdvisorOverviewRepository().getAgentEmpanelmentDetails(apiKey);

      if (response.hasException) {
        empanelmentState = NetworkState.error;
      } else {
        dynamic data = response.data?['hydra']['agent']['empanelment'];
        if (data != null) {
          empanelmentData = EmpanelmentModel.fromJson(data);
        }

        empanelmentState = NetworkState.loaded;
        if (showDialog) {
          if (empanelmentData?.status == AgentEmpanelmentStatus.InProgress &&
              empanelmentData?.orderStatus ==
                  AgentEmpanelmentOrderStatus.Failed) {
            showPaymentFailedDialog = true;
          } else {
            showInProgressDialog = true;
          }
        } else if (empanelmentData?.status ==
            AgentEmpanelmentStatus.Empanelled) {
          _showSuccessPage();
        }
      }
    } catch (error) {
      empanelmentState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getAdvisorOverview() async {
    try {
      String apiKey = await getApiKey() ?? '';

      final currentTime = DateTime.now();
      final response = await AdvisorOverviewRepository()
          .getAdvisorOverview(currentTime.year, currentTime.month, apiKey);
      if (!response.hasException) {
        advisorOverview = AdvisorOverviewModel.fromJson(response.data['hydra']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> getAgentEmpanelmentAddress() async {
    empanelmentAddressResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';

      final response =
          await AdvisorOverviewRepository().getAgentEmpanelmentAddress(apiKey);
      if (!response.hasException) {
        empanelmentAddress = EmpanelmentAddressModel.fromJson(
            response.data['hydra']['agent']['empanelmentAddress']);
        preFillAddressForm(empanelmentAddress);
        empanelmentAddressResponse.state = NetworkState.loaded;
      } else {
        empanelmentAddressResponse.state = NetworkState.error;
      }
    } catch (error) {
      empanelmentAddressResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void preFillAddressForm(EmpanelmentAddressModel? address) {
    if (address != null) {
      addressLineOneController.text = address.line1 ?? "";
      addressLineTwoController.text = address.line2 ?? "";
      stateController.text = address.state ?? "";
      cityController.text = address.city ?? "";
      pincodeController.text = address.postalCode ?? "";
      countryController.text = address.country ?? "";
    }
  }

  Future<bool> validateEmpanelment(Map<String, dynamic> payload) async {
    validateEmpanelmentState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      var response = await AdvisorOverviewRepository()
          .validateEmpanelment(apiKey, payload);

      if (response["status"] == "200") {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    } finally {
      validateEmpanelmentState = NetworkState.loaded;
      update();
    }
  }

  Future<void> payEmpanelmentFee() async {
    payEmpanelmentFeeResponse.state = NetworkState.loading;
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await AdvisorOverviewRepository().payEmpanelmentFee(apiKey);

      if (response.hasException) {
        payEmpanelmentFeeResponse.state = NetworkState.error;
        payEmpanelmentFeeResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        empanelmentData = EmpanelmentModel.fromJson(
            response.data!["payEmpanelmentFees"]["empanelmentNode"]);
        if ((empanelmentData?.thirdPartyOrderId ?? '').isNullOrEmpty) {
          payEmpanelmentFeeResponse.state = NetworkState.error;
          payEmpanelmentFeeResponse.message =
              'Failed to initiate payment link. Please try again';
        } else {
          payEmpanelmentFeeResponse.state = NetworkState.loaded;
        }
      }
    } catch (error) {
      payEmpanelmentFeeResponse.state = NetworkState.error;
      payEmpanelmentFeeResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> initRazorPay() async {
    var options = {
      "key": F.razorPayKey,
      "amount": (empanelmentData?.totalFees ?? 0) * 100,
      "currency": "INR",
      "name": "Wealthy",
      'description':
          'Partner platform fee - Base Amount ₹${empanelmentData?.fees} with 18% GST ₹${empanelmentData?.gst}',
      "image": "https://i.wlycdn.com/articles/P-updated-wealthy-logo.png",
      "order_id": empanelmentData?.thirdPartyOrderId ?? '',
      "notes": {
        "address":
            "Wealthy - Head Office (BuildWealth Technologies Pvt. Ltd.),1198/1090B, 18th Cross Rd, Sector 6, HSR Layout, Bengaluru, Karnataka 560102"
      },
      "theme": {"color": "#6725F4"},
    };
    // var options = {
    //   'key': 'rzp_test_n9Cp5njaben9BP',
    //   'currency': "INR",
    //   'order_id': empanelmentData?.thirdPartyOrderId ?? '',
    //   'amount': (empanelmentData?.totalFees ?? 0) * 100,
    //   'name': 'Wealthy',
    //   'description':
    //       'Partner platform fee - Base Amount ₹${empanelmentData?.fees} with 18% GST ₹${empanelmentData?.gst}',
    //   'image': "https://i.wlycdn.com/articles/P-updated-wealthy-logo.png",
    //   'theme': {'color': '#6725F4'}
    // };

    try {
      // _razorpay.open(options);
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void toggleTcAgreed() {
    isTcAgreed = !isTcAgreed;
    update();
  }

  void onChangeCountry(String value) {
    if (value != countryController.text) {
      countryController.text = value;
      // selectedCountryIndex = index;
      // stateInputController?.clear();
      // cityInputController?.clear();
      // selectedStateIndex = null;
      update();
    }
  }

  Future<void> getCountriesData() async {
    final data = await rootBundle.loadString(countriesDataFile);
    CountryModel? indiaCountryModel;
    countries = (jsonDecode(data) as List).map(
      (dynamic e) {
        // if (e)
        CountryModel country = CountryModel.fromJson(e as Map<String, dynamic>);
        if (country.name == "India") {
          indiaCountryModel = country;
        }
        return country;
      },
    ).toList();

    if (indiaCountryModel != null) {
      onChangeCountry(indiaCountryModel!.name!);
    }
  }

  void disablePaymentFailedDialog() {
    showPaymentFailedDialog = false;
    update();
  }

  void disableInProgressDialog() {
    showInProgressDialog = false;
    update();
  }

  _showSuccessPage() {
    AutoRouter.of(context).push(
      SuccessRoute(
        title: 'Congratulations!',
        subtitle: 'You are now a Wealthy Partner',
        actionButtonText: 'Proceed',
        onPressed: () {
          AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));

          final homeController = Get.isRegistered<HomeController>()
              ? Get.find<HomeController>()
              : Get.put(HomeController());
          homeController.getAdvisorOverview();
        },
      ),
    );
  }
}
