const String advisorOverview = r'''
query advisorOverview()  {
  hydra {
    agentDesignation {
      designation
      partnerOfficeName
    }
     agent {
      createdAt
      name
      email
      phoneNumber
      id
      externalId
      aadhaarLinked
      kycStatus
      segment
      agentType
      salesPlanType
      panNumber
      displayName
      firstRewardAt
      isFirstTransactionCompleted
      bankStatus
      dematTncConsentAt
      brokingApId
      dob
      secondRewardAt
      imageUrl
      gst {
        gstin
        verifiedAt
        corporateName
      }
      bankDetails{
        bankIfscCode
        bankAccountNo
        bankName
        nameAsPerBank
      }
      dateOfActivation
      emailVerifiedAt
      phoneNumberVerifiedAt
      agentReferralData {
        referralUrl
      }
      manager {
        id
        name
        email
        phoneNumber
      }
      pst {
        id
        name
        email
        phoneNumber
      }
      hasAcceptedActiveTnc
    }

    partnerArn{
      id
      externalId
      arn
      euin
      arnStatus
      status
      additionalEuins
      nameAsPerArn
      addressAsPerArn
      phoneNumberAsPerArn
      arnValidFrom
      partnerApprovedAt
      isArnActive
      arnValidTill
    }
  }
}
''';

const String agentEmpanelment = r'''
  query agentEmpnelmentQuery {
    hydra {
      id
      agent {
        id
        empanelment {
          id
          status
          fees
          gst
          totalFees
          empanelledAt
          bypassedAt
          orderId
          orderStatus
          thirdPartyOrderId
          orderFinalStageArrivedAt
        }
      }
    }
  }
''';

const String partnerNominee = r'''
  query partnerNominees {
    partnerNominees {
        id
        name
        dob
        address
        relationship
        guardianName
        guardianAddress
        percentage
    }
  }
''';

const String agentDesignation = r'''
  query agentDesignation() {
    hydra {
       agentDesignation {
        designation
        partnerOfficeName
      }
    }
  }
''';

const String payouts = r'''
  query payouts {
    hydra {
      payouts {
        payoutId
        totalPayout
        payoutDate
        payoutReadyAt
        tds
        status
        finalPayout
        effectiveGst
        gst
        basePayout
        agentName
        agentEmail
        payoutRedemptionDetails {
          payoutResponseDetails
          description
          paidBankDetails
          status
          amount
        }
        payoutDate
        revenueDate
        employeesPayouts {
          payoutId
          totalPayout
          payoutDate
          payoutReadyAt
          tds
          status
          finalPayout
          effectiveGst
          basePayout
          agentName
          agentEmail
          payoutDate
          revenueDate
        }
      }
    }
  }
''';

const String payoutProductBreakup = r'''
  query payoutBreakup ($payoutId: String!) {
    hydra {
      payoutBreakup(payoutId: $payoutId) {
       productType
       baseRevenue
      }
    }
  }
''';

const String brokingPayouts = r'''
  query brokingPayouts {
    hydra {
      brokingPayouts {
        payoutId
        payoutReadyAt
        payoutInitiatedAt
        payoutCompletedAt
        payoutPausedAt
        payoutReleasedAt
        tds
        status
        finalPayout
        gst
        basePayout
        agentName
        agentEmail
        revenueDate
        bankDetails
      }
    }
  }
''';

const String brokingPayoutBreakup = r'''
  query brokingPayoutBreakup ($payoutId: String!) {
    hydra {
      brokingPayoutBreakup(payoutId: $payoutId) {
        categoryType
        baseRevenue
        gst
      }
    }
  }
''';

const String aumOverview = r'''
  query aumQuery($userId: String!, $agentExternalId: String!, $agentExternalIdList: [String], $months: Int!, $includeCurrentMonth: Boolean!) {
    delta(userId: $userId){
      id
      partnerMonthlyMetric(agentExternalIdList: $agentExternalIdList, agentExternalId: $agentExternalId, months: $months, includeCurrentMonth: $includeCurrentMonth) {
        id
        TOTAL
        TOTALDebt
        TOTALEquity
        MF
        MFEquity
        MFDebt
        MFCommodity
        MLD
        MLDEquity
        MLDDebt
        MLDCommodity
        MLDAlternative
        PMS
        PMSDebt
        PMSEquity
        INSURANCE
        FD
        PREIPO
        SGB
        GSEC
        NCD
        NCDDebt
        NCDEquity
        NCDAlternative
        AIFDebt
        AIFEquity
        AIFAlternative
        AIFCommodity
        AIF
        TOTALAlternative
        TOTALCommodity
        date
        asOnDate
      }
    }
  }
''';

const String aumAggregate = r'''
  query aumAggregateQuery($userId: String!, $agentExternalId: String!, $agentExternalIdList: [String], $months: Int!, $includeCurrentMonth: Boolean!) {
    delta(userId: $userId){
      id
      partnersMonthlyMetricAum(agentExternalIdList: $agentExternalIdList, agentExternalId: $agentExternalId, months: $months, includeCurrentMonth: $includeCurrentMonth) {
        TOTAL
        TOTALDebt
        TOTALEquity
        MF
        MFEquity
        MFDebt
        MFCommodity
        MLD
        MLDEquity
        MLDDebt
        MLDCommodity
        MLDAlternative
        PMS
        PMSDebt
        PMSEquity
        INSURANCE
        FD
        PREIPO
        SGB
        GSEC
        NCD
        NCDDebt
        NCDEquity
        NCDAlternative
        AIFDebt
        AIFEquity
        AIFAlternative
        AIFCommodity
        AIF
        TOTALAlternative
        TOTALCommodity
        date
      }
    }
  }
''';

const String activeSipCount = r'''
  query sipMetrics ($agentExternalIdList: [String]!) {
    taxy {
      sipAggregateData(agentExternalIdList: $agentExternalIdList) {
        activeSip {
          count
          transactions
          amount
        }
      }
    }
  }
''';

const String sipMetrics = r'''
  query sipMetrics ($agentExternalIdList: [String]!) {
    taxy {
      sipAggregateData(agentExternalIdList: $agentExternalIdList) {
        activeSip {
          count
          transactions
          amount
        }
        newCurrentMonthSip {
          count
          transactions
          amount
        }
        pausedCurrentMonth {
          count
          transactions
          amount
        }
        wonSip {
          count
          transactions
          amount
        }
        failedSip {
          count
          transactions
          amount
        }
        pendingSip {
          count
          transactions
          amount
        }
        inprogressSip {
          count
          transactions
          amount
        }
        todaysMetric {
          sips
          sipAmount
          successfulSips
          successfulSipsAmount
        }
        currentMonthAggregate {
          count
          transactions
          amount
        }
        uniqueClientsWithActiveSips {
          count
          transactions
          amount
        }
        unsuccessfulMandateSips {
          count
          transactions
          amount
        }
      }
      partnerMfOfflineSips(agentExternalIdList: $agentExternalIdList) {
        count
        activeAmount
        activeCount
        pausedCount
        inactiveCount
        activeMonthlyAmount
      }
    }
  }
''';

const String sipGraphData = r'''
  query sipGraph ($agentExternalIdList: [String]!) {
    taxy {
      sipGraphData(agentExternalIdList: $agentExternalIdList){
        activeSipVsMonth{
          month
          amount
        }
        successfulNavAllocationAmountVsMonth{
          month
          amount
        }
      }
    }
  }
''';

const String sipDayWiseActiveCount = r'''
  query sipGraph ($agentExternalIdList: [String]!) {
    taxy {
      sipDayWiseActiveCount(agentExternalIdList: $agentExternalIdList)
    }
  }
''';

const sipUserData = r'''
  query sipUserData ($agentExternalIdList: [String]!, $offset: Int , $limit: Int, $isPaused: Boolean, $isActive: Boolean, $pausedCurrentMonth: Boolean, $sipRegisteredCurrentMonth: Boolean, $notMandateApproved: Boolean, $isInactive: Boolean, $userIds: [String]) {
    taxy {
      sipUserData(input: {agentExternalIdList: $agentExternalIdList, limit: $limit, offset: $offset}, filter: {isPaused: $isPaused, isActive: $isActive, pausedCurrentMonth: $pausedCurrentMonth, sipRegisteredCurrentMonth: $sipRegisteredCurrentMonth,notMandateApproved: $notMandateApproved, isInactive: $isInactive, userIds: $userIds}) {
        count
        sipData {
          id
          userId
          name
          sipDays
          fundName
          startDate
          endDate
          sipAmount
          lastSipDate
          lastSipStatus
          failureReason
          goalName
          isPaused
          isSipActive
          stepperEnabled
          incrementPeriod
          incrementPercentage
          pauseReason
          crn
          agentName
          email
          phoneNumber
          failureReason
          goalExternalId
          goalType
          mandateApproved
          sipDayData{
            day
            status
            sipDate
          }
          sipMetaFunds {
            wschemecode
            amount
            schemeName
          }
          agentExternalId
          sipMetaId
          paymentBankAccountId
        }
      }
    }
  }
''';

const sipDataV2 = r'''
  query sipDataV2 ($offset: Int , $limit: Int, $isPaused: Boolean, $isActive: Boolean, $pausedCurrentMonth: Boolean, $sipRegisteredCurrentMonth: Boolean $goalId: String, $wschemecodes: [String]) {
    taxy {
      sipUserData: sipDataV2(input: {limit: $limit, offset: $offset}, filters: {isPaused: $isPaused, isActive: $isActive, pausedCurrentMonth: $pausedCurrentMonth, sipRegisteredCurrentMonth: $sipRegisteredCurrentMonth, goalId: $goalId, wschemecodes: $wschemecodes}) {
        count
        sipData {
          id
          userId
          name
          sipDays
          fundName
          startDate
          endDate
          sipAmount
          lastSipDate
          lastSipStatus
          failureReason
          goalName
          isPaused
          isSipActive
          stepperEnabled
          incrementPeriod
          incrementPercentage
          pauseReason
          crn
          agentName
          email
          phoneNumber
          failureReason
          goalExternalId
          goalType
          mandateApproved
          sipDayData{
            day
            status
            sipDate
          }
          sipMetaFunds {
            wschemecode
            amount
            schemeName
          }
          agentExternalId
          sipMetaId
          paymentBankAccountId
        }
      }
    }
  }
''';

const agentReports = r'''
  query agentReports($limit: Int, $offset: Int, $templateName: String) {
    hydra {
      agentReports(limit: $limit, offset: $offset, templateName: $templateName) {
        id
        createdAt
        name
        status
        urlToken
        expiresAt
        requestorCode
        shortLink
        reportGeneratedAt
        reportUrl
      }
    }
  }
''';

const agentReportTemplates = r'''
  query agentReportTemplates {
    hydra {
      agentReportTemplates {
        name
        functionParameters
        reportType
        pdfTemplateName
        isPublished
        displayName
        description
        reportTemplateId
      }
    }
  }
''';

const String offlineSipList = r'''
query offlineSipList($agentExternalIdList: [String], $searchText: String, $offset: Int , $limit: Int) {
    taxy {
        partnerMfOfflineSips(agentExternalIdList: $agentExternalIdList, searchText: $searchText, offset: $offset, limit: $limit) {
            count
            userOfflineSipTransactionData {
                name
                userId
                panNumber
                folioNumber
                schemeCode
                schemeName
                crn
                amount
                monthlyAmount
                agentName
                agentExternalId
                status
                sipDays
                frequency
                startDate
                endDate
                regDate
                terminationDate
            }
        }
    }
}
''';

const String partnerTrackerMetrics = r'''
  query partnerTrackerMetrics($agentExternalIdList: [String]) {
    delta(userId: "") {
      partnersTrakerMetrics(agentExternalIdList: $agentExternalIdList) {
        users {
          taxyId
          name
          crn
          trakCobOpportunityValue
          trakFamilyMfCurrentValue
        }
        aggregatedMetrics {
          totalUsers
          totalCobOpportunityValue
          totalFamilyMfCurrentValue
        }
      }
    }
  }
''';

const String empanelmentAddress = r'''
query empanelmentAddress {
  hydra {
    agent {
      empanelmentAddress {
        externalId
        line1
        line2
        city
        state
        country
        postalCode
      }
    }
  }
}
''';

const String agentReferralData = r'''
  query advisorOverview()  {
    hydra {
      agent {
        agentReferralData {
          referralUrl
          totalClicks
          totalUniqueClicks
          totalSignups
          totalTransacted
          referredUsers {
            stage
            userId
            userEmail
            userPhone
            userName
          }
        }
      }
    }
  }
''';

const String clientBirthdays = r'''
  query clientBirthdays {
    hydra {
      clientBirthdays(days: 40) {
        name
        dob
        crn
        wealthyCurrentValue
        email
        phoneNumber
      }
    }
  }
''';
