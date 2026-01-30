const String sipListV2 = r'''
query sipListV2($userId: String!, $goalId:ID) {
    taxy(userId: $userId) {
      sipMetas(goalId: $goalId) {
        id
        isActive
        sipAmount
        totalAmount
        completedAmount
        startDate
        endDate
        sipDay
        sipDay2
        baseSipId
        pauseDate
        frequency
        days
        createdAt
        stepperEnabled
        stepperSetupDate
        incrementPeriod
        incrementPercentage
        goal {
          id
          name
          displayName
          goalId
          goalSubtype {
            id
            subtype
            goalType
          }
        }
        nextSip {
          amount
          sipDate
        }
        sipMetaFunds {
          wschemecode
          amount
        }
        lastSuccessfulOrder {
          id
          sipDate
          amount
        }
        sipSchemes {
          wschemecode
          schemeName
        }
        completedOrderCount
        isSipActive
      }
    }
  }

  ''';

const String sipDetailsV2 = r'''
query sipDetailsV2($userId: String!, $baseSipId: String, $filterDateForPast: DateTime, $toDate: DateTime, $limit: Int, $offset: Int) {
    taxy(userId: $userId) {
    id
    pastSips: sipsV2(sipMetaId: $baseSipId, filterDate: $filterDateForPast, toDate: $toDate, limit: $limit, offset: $offset) {
      id
      sipDate
      stage
      amount
      pauseDate
      status
      failureReason
      orderId
    }
  }
}
  ''';

const String sipOrders = r'''
  query sipOrders(
    $userId: String!,
    $goalId: ID
  ) {
    taxy(userId: $userId) {
      id
      orders(
        goalId: $goalId,
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
    }
  }
''';
