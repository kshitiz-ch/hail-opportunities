class TransactionAggregate {
  final String transactionType;
  int successCount;
  double successAmount;
  int failureCount;
  double failureAmount;
  int progressCount;
  double progressAmount;
  int activeCount;
  double activeAmount;

  int get totalCount =>
      successCount + failureCount + progressCount + activeCount;
  double get totalAmount =>
      successAmount + failureAmount + progressAmount + activeAmount;

  TransactionAggregate({
    required this.transactionType,
    required this.successCount,
    required this.successAmount,
    required this.failureCount,
    required this.failureAmount,
    required this.progressCount,
    required this.progressAmount,
    this.activeCount = 0,
    this.activeAmount = 0.0,
  });
}
