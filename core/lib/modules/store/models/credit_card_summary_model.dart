import 'package:core/modules/common/resources/wealthy_cast.dart';

class CreditCardSummaryModel {
  int? leadsInProgress;
  int? applicationSubmitted;
  int? aipApproved;
  int? productsIssued;

  CreditCardSummaryModel(
      {this.leadsInProgress,
      this.applicationSubmitted,
      this.aipApproved,
      this.productsIssued});

  CreditCardSummaryModel.fromJson(Map<String, dynamic> json) {
    leadsInProgress = WealthyCast.toInt(json['leads_in_progress']);
    applicationSubmitted = WealthyCast.toInt(json['application_submitted']);
    aipApproved = WealthyCast.toInt(json['aip_approved']);
    productsIssued = WealthyCast.toInt(json['products_issued']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['leads_in_progress'] = this.leadsInProgress;
    data['application_submitted'] = this.applicationSubmitted;
    data['aip_approved'] = this.aipApproved;
    data['products_issued'] = this.productsIssued;
    return data;
  }
}
