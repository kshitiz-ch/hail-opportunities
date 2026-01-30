const String proposalCount = r'''
query proposalStatusCounts($userId: String) {
  hydra {
     proposalStatusCounts (userId: $userId) {
      created
      proposalInitiated
      clientConfirmed
      active
      failure
      completed
     }
  }
}
''';
