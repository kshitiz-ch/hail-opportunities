const String createPartnerOffice = r'''
  mutation createPartnerOffice($name: String!) {
    createPartnerOffice(name: $name) {
      message
    }
  }
''';

const String addPartnerOfficeEmployee = r'''
  mutation addPartnerOfficeEmployee(
    $designation: String!,
    $email: String!,
    $firstName: String!,
    $lastName: String!,
    $phoneNumber: String!
  ) {
    addPartnerOfficeEmployee(
      designation: $designation,
      email: $email,
      firstName: $firstName,
      lastName: $lastName,
      phoneNumber: $phoneNumber
    ) {
      agentLeadId
    }
  }
''';

const String addExistingAgentPartnerOfficeEmployee = r'''
  mutation addExistingAgentPartnerOfficeEmployee(
    $designation: String!,
    $phoneNumber: String!
  ) {
    addExistingAgentPartnerOfficeEmployee(
      designation: $designation
      phoneNumber: $phoneNumber
    ) {
      message
    }
  }
''';

const String assignUnassignClient = r'''
   mutation AssignOrReassignClients($clientIds: [String!]!, $targetAgentExternalId: String!) {
    assignOrReassignClients(
      clientIds: $clientIds,
      targetAgentExternalId: $targetAgentExternalId
    ) {
      message
    }
  }
''';

const String renameOffice = r'''
   mutation updatePartnerOffice($name: String!) {
    updatePartnerOffice(name: $name) {
      message
    }
  }
''';

const String removeEmployee = r'''
   mutation removePartnerOfficeEmployee($employeeExternalId: String!) {
    removePartnerOfficeEmployee(employeeExternalId: $employeeExternalId) {
      message
    }
  }
''';
