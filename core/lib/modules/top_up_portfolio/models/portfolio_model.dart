import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_user_products_model.dart';

class PortfolioModel {
  String? id;
  List<PortfolioUserProductsModel>? userProducts;

  PortfolioModel({this.id, this.userProducts});

  PortfolioModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    userProducts = WealthyCast.toList(json['userProducts'])
        .map((e) => PortfolioUserProductsModel.fromJson(e))
        .toList();
    userProducts?.removeWhere(((element) {
      if (!(element.canMakePayment ?? false)) {
        return true;
      }

      if (element.productType == null ||
          element.productType!.toLowerCase() != 'mf') {
        return true;
      }

      // Filter out AnyFund portfolio
      if (element.extras?.goalType == 10) {
        return true;
      }

      return false;
    }));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    if (this.userProducts != null) {
      data['userProducts'] = this.userProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
