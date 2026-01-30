import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientTrackerAllocation {
  double? currentValue;
  double? investedAmount;
  double? absoluteReturns;
  List<Allocation>? allocation;

  ClientTrackerAllocation(
      {this.currentValue,
      this.investedAmount,
      this.absoluteReturns,
      this.allocation});

  ClientTrackerAllocation.fromJson(Map<String, dynamic> json) {
    currentValue = WealthyCast.toDouble(json['currentValue']);
    investedAmount = WealthyCast.toDouble(json['investedAmount']);
    absoluteReturns = WealthyCast.toDouble(json['absoluteReturns']);
    if (json['allocation'] != null) {
      allocation = <Allocation>[];
      json['allocation'].forEach((v) {
        allocation!.add(new Allocation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentValue'] = this.currentValue;
    data['investedAmount'] = this.investedAmount;
    data['absoluteReturns'] = this.absoluteReturns;
    if (this.allocation != null) {
      data['allocation'] = this.allocation!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Allocation {
  String? allocationType;
  List<AllocationData>? allocationData;

  Allocation({this.allocationType, this.allocationData});

  Allocation.fromJson(Map<String, dynamic> json) {
    allocationType = WealthyCast.toStr(json['allocationType']);
    if (json['allocationData'] != null) {
      allocationData = <AllocationData>[];
      json['allocationData'].forEach((v) {
        allocationData!.add(new AllocationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allocationType'] = this.allocationType;
    if (this.allocationData != null) {
      data['allocationData'] =
          this.allocationData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllocationData {
  String? category;
  double? currentValue;
  double? weight;

  AllocationData({this.category, this.currentValue, this.weight});

  AllocationData.fromJson(Map<String, dynamic> json) {
    category = WealthyCast.toStr(json['category']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    weight = WealthyCast.toDouble(json['weight']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['currentValue'] = this.currentValue;
    data['weight'] = this.weight;
    return data;
  }
}
