const String trackerValue = r'''
  query familyOverview($userId: String!) {
  phaser(userId: $userId) {
    familyOverview {
      currentValue
      mfCurrentValue
      familyReport {
        id
        syncDate
        panNumber
        currentValue
        mfCurrentValue
      }
    }
  }
}
''';
