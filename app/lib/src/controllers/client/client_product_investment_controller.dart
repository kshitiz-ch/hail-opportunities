import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientProductInvestmentController extends GetxController {
  late Client client;
  late ClientInvestmentProductType productType;
  bool showEmptyFolios = false;

  List<ProductInvestmentModel> products = [];

  ApiResponse investmentDetailsResponse = ApiResponse();

  bool showAbsoluteReturn = true;

  ClientProductInvestmentController({
    required this.client,
    required this.productType,
  });

  void onInit() {
    getProductInvestmentDetails();
    super.onInit();
  }

  Future<void> getProductInvestmentDetails() async {
    products.clear();
    investmentDetailsResponse.state = NetworkState.loading;

    update();

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientListRepository()
          .getProductInvestmentDetails(apiKey, client.taxyID!,
              type: productType, showZeroFolios: showEmptyFolios);

      if (response.hasException) {
        investmentDetailsResponse.state = NetworkState.error;
      } else {
        String queryName = getQueryName();
        response.data![queryName].forEach(
          (x) => products.add(ProductInvestmentModel.fromJson(x)),
        );

        investmentDetailsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      investmentDetailsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void toggleShowEmptyFolios() {
    showEmptyFolios = !showEmptyFolios;
    getProductInvestmentDetails();
  }

  String getQueryName() {
    if (productType == ClientInvestmentProductType.pms) {
      return "userPmsOverview";
    }
    if (productType == ClientInvestmentProductType.debentures) {
      return "userMldOverview";
    }

    if (productType == ClientInvestmentProductType.preIpo) {
      return "userUnlistedOverview";
    }

    if (productType == ClientInvestmentProductType.fixedDeposit) {
      return "userFdOverview";
    }

    return '';
  }

  void toggleAbsoluteReturn() {
    showAbsoluteReturn = !showAbsoluteReturn;
    update();
  }
}
