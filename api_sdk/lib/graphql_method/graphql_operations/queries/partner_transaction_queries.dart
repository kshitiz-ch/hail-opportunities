const String mfOrderTransactions = r'''
query mfOrderTransaction($agentExternalIdList: [String], $filters: String, $limit: Int, $offset: Int){
  taxy {
    userMfOrders(agentExternalIdList: $agentExternalIdList, filters: $filters, limit: $limit, offset: $offset) {
      userTransactionOrderData {
        requestPrn
        transactionId
        orderId
        statusDisplay
        sourceDisplay
        orderType
        goalTitleDisplay
        lumsumAmount
        status
        failureReason
        paymentBankName
        paymentBankIfscCode
        paymentBankAccountNumber
        lastUpdatedStageAt
        navAllocatedAt
        category
        transactionTypeDisplay
        transactionSourceDisplay
        orderStageAudit {
          customerStageText
          stageEta
          stageLastUpdatedAt
        }
        crn
        agentName
        schemeStatusTitleDisplay
        schemeOrders {
          id
          schemeName
          orderId
          category
          schemeStatus
          schemeStatusDisplay
          transactionTypeDisplay
          agentName
          amount
          units
          nav
          email
          phoneNumber
          panNumber
          name
          lastCheckedAt
          navAllocatedAt
        }
      }
      count
    }
  }
}
''';

const String mfTransactions = r'''
query partnerSchemeOrderDetailedView($agentExternalIdList: [String], $filters: SchemeOrderDataFilter, $orderBy: String, $historical: Boolean) {
  taxy {
    partnerSchemeOrderDetailedView(agentExternalIdList: $agentExternalIdList, filters: $filters, orderBy: $orderBy, historical: $historical) {
      count
      schemeOrderData {
        goalName
        amc
        folioNumber
        fundType
        category
        transactionType
        source
        orderId
        schemeOrderId
        orderPrn
        units
        amount
        nav
        transactionId
        schemeStatus
        failureReason
        createdAt
        navAllocatedAt
        bankName
        accountNumber
        ifscCode
        clientName
        crn
        userId
        phoneNumber
        lastUpdatedAt
        schemeName
        isSif
        orderStageAudit {
          customerStageText
          stageEta
          stageLastUpdatedAt
          stage
        }
      }
    }
  }
}
''';

const String insuranceTransactions = r'''
query insuranceOrders($agentExternalIdList: [String], $offset: Int, $limit: Int, $filters: String) {
  entreat {
    id
    insuranceTransactionsPartner(agentExternalIdList: $agentExternalIdList, limit: $limit, offset: $offset, filters: $filters) {
      count
      data {
        userId
        userDetails {
          name
          phone
          email
        }
        name
        insuranceType
        insurer
        sourcingChannel
        premiumWithGst
        premiumWithoutGst
        premiumFrequency
        policyNumber
        status
        paymentCompletedAt
        policyIssueDate
        lastRenewalPaidAt
        renewalDate
        status
        agentName
        agentExternalId
        policyDocumentPath
        orderId
        orderStageAudit {
          stage
          stageText
          stageEta
        }
      }
    }
  }
}
''';

const String pmsTransactions = r'''
  query pmsTransactions($userId: String, $agentExternalIdList: [String], $orderBy: String, $filters: PMSCashFlowFilters, $limit: Int) {
  entreat(userId: $userId) {
    pmsCashflowsPartner(agentExternalIdList: $agentExternalIdList, orderBy: $orderBy, filters: $filters, userId: $userId, offset: 0, limit: $limit) {
      count
      data {
        userId
        pmsName
        pmsClientId
        manufacturer
        status
        segment
        currentValue
        currentInvestedValue
        xirr
        asOnDate
        trnxDate
        trnxType
        amount
        description
        userId
        userName
        userEmail
        agentExternalId
        agentName
      }
    }
  }
}
''';

const String pmsTransactionCount = r'''
  query pmsTransactions($userId: String, $agentExternalIdList: [String], $orderBy: String, $filters: PMSCashFlowFilters) {
  entreat(userId: $userId) {
    pmsCashflowsPartner(agentExternalIdList: $agentExternalIdList, orderBy: $orderBy, filters: $filters, userId: $userId) {
      count
    }
  }
}
''';
