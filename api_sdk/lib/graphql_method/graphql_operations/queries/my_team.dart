String getEmployees = r'''
  query employees(
    $search: String,
    $designation: String
  ) {
    hydra {
      employees (
        search: $search,
        designation: $designation
      ) {
         externalId
        agentExternalId
        firstName
        lastName
        email
        phoneNumber
        customersCount
        designation
        agent {
          id
          lastLoginAt
        }
      }
    }
  }
''';

// String getEmployees = r'''
//   query employee(
//     $search: String,
//     $designation: String,
//     $limit: Int,
//     $offset: Int
//   ) {
//     hydra {
//       employee (
//         agentExternalId: $agentExternalId,
//       ) {
//         customerCount
//       }
//     }
//   }
// ''';

String getPartnersDailyMetric = r'''
  query partnersDailyMetric(
    $date: String,
    $agentExternalIdList: [String]
  ) {
    delta(userId: "") {
      partnersDailyMetric (
        date: $date,
        agentExternalIdList: $agentExternalIdList
      ) {
        TOTAL
        id
        agentExternalId
        date
      }
    }
  }
''';
