import 'package:core/modules/common/resources/wealthy_cast.dart';

class ProductRevenueModel {
  double? revenue;
  String? productType;
  double? percentage;

  ProductRevenueModel({this.revenue, this.productType, this.percentage});

  ProductRevenueModel.fromJson(Map<String, dynamic> json) {
    revenue = WealthyCast.toDouble(json['revenue'] ?? json['amount']);
    productType =
        WealthyCast.toStr(json['product_type'] ?? json['product_name']);
    percentage = WealthyCast.toDouble(json['percentage']);
  }
}

class ProductRevenueUIData {
  List<ProductRevenueModel> sortedProducts = [];
  List<ProductRevenueModel> graphData = [];

  ProductRevenueUIData(List<ProductRevenueModel> data) {
    updateProductRevenueUIData(data);
  }

  void updateProductRevenueUIData(List<ProductRevenueModel> products) {
    // sort products based on revenue
    products.sort(
      (a, b) {
        return (b.revenue ?? 0).compareTo(a.revenue ?? 0);
      },
    );
    sortedProducts = List.from(products);

    if (products.length > 5) {
      // if total products is greater than 5
      // then top 4 products + other
      ProductRevenueModel? other;
      other = ProductRevenueModel(
        revenue: 0,
        percentage: 0,
        productType: 'Others',
      );
      for (int index = 4; index < products.length; index++) {
        other.percentage =
            other.percentage! + (products[index].percentage ?? 0);
        other.revenue = other.revenue! + (products[index].revenue ?? 0);
      }
      products = products.sublist(0, 4);
      products.add(other);
    }
    graphData = List.from(products);
  }
}
