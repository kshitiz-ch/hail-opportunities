class ChartDataModel {
  // Fields
  final int millisecondsSinceEpoch;
  final double nav;
  final double percentage;
  late double currentValue;
  late double investedValue;

  // Constructor
  ChartDataModel(this.millisecondsSinceEpoch, this.nav, this.percentage);
  ChartDataModel.returnCalculator(
    this.millisecondsSinceEpoch,
    this.nav,
    this.percentage,
    this.currentValue,
    this.investedValue,
  );
}
