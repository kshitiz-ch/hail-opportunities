import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

class SwpSchemeContext {
  SwpSchemeContext({
    required this.schemeData,
    this.amount,
    required this.goalId,
    this.days,
    this.startDate,
    this.endDate,
  });

  String get id => schemeData.basketKey;

  final SchemeMetaModel schemeData;
  double? amount;
  final String goalId;
  List<int>? days;
  DateTime? startDate;
  DateTime? endDate;

  Map<String, dynamic> toJson() => {
        "goal": goalId,
        "days": days?.join(','),
        "start_date": startDate != null
            ? startDate!.toIso8601String().split('T')[0]
            : null,
        "end_date":
            endDate != null ? endDate!.toIso8601String().split('T')[0] : null,
        "amount": amount?.toInt(),
        "wschemecode": schemeData.wschemecode,
        "folio_number": schemeData.folioOverview?.folioNumber,
      };
}
