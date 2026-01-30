const String dematAccounts = r'''
  query dematAccounts($userId: String) {
    taxy(userId: $userId) {
      tradingAccounts {
        id
        dematId
        dpid
        boid
        dematImageId
        stockBroker
        isVerified
        docUrl
        tradingAccountId
        provider
      }
    }
  }
''';
