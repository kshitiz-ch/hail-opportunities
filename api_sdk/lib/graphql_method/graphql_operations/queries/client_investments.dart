const String clientInvestments = r'''
  query clientInvestments($userId: String) {
  entreat(userId: $userId) {
    userOverviewByProductCategory{
      id
      currentValue
      productCategory
    }
  }
}
''';

const String mfTransactions = r'''
  query recentTransactions(
    $userId: String!,
    $limit: Int!,
    $offset: Int!,
    $status: String,
    $goalId: ID
  ) {
    taxy(userId: $userId) {
      id
      orders(
        limit: $limit,
        offset: $offset,
        status: $status,
        goalId: $goalId
      ) {
        id
        category
        createdAt
        displayAmount
        status
        paymentMode
        source
        requestPrn
        navAllocatedAt
        estProcessedAt
        orderId
        appVersionDisplayName

        goal {
          id
          displayName
          name
          goalSubtype {
            goalType
            subtype
          }
        }

        schemeorders {
          id
          schemeName
          amc
          displayAmount
          wschemecode
          category
          transactionId
          units
          nav
        }
      }
      mfOrdersCount(status: $status, goalId: $goalId)
    }
  }
''';
