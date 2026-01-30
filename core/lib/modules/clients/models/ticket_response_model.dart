import 'package:core/modules/common/resources/wealthy_cast.dart';

class TicketResponseModel {
  String? id;
  String? customerTicketUrl;

  TicketResponseModel({this.id, this.customerTicketUrl});

  TicketResponseModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    customerTicketUrl = WealthyCast.toStr(json['customerTicketUrl']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerTicketUrl'] = this.customerTicketUrl;
    return data;
  }
}
