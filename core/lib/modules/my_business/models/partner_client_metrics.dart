import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerClientMetrics {
  // Client fields
  int? totalClients;
  int? mfKycClients;
  int? brokingKycClients;
  int? activeClients;

  // Tracker fields
  double? syncedClientsLast30Days;
  double? totalExternalTrackerAmount;
  double? totalTrackerSyncedAmount;

  PartnerClientMetrics.fromJson(Map<String, dynamic> json) {
    totalClients = WealthyCast.toInt(json['totalClients']);
    mfKycClients = WealthyCast.toInt(json['mfKycClients']);
    brokingKycClients = WealthyCast.toInt(json['brokingKycClients']);
    activeClients = WealthyCast.toInt(json['activeClients']);

    syncedClientsLast30Days =
        WealthyCast.toDouble(json['syncedClientsLast30Days']);
    totalExternalTrackerAmount =
        WealthyCast.toDouble(json['totalExternalTrackerAmount']);
    totalTrackerSyncedAmount =
        WealthyCast.toDouble(json['totalTrackerSyncedAmount']);
  }
}
