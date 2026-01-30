const String serviceRequest = r'''
query clientTickets($limit: Int, $offset: Int, $userId: String!) {
  entreat(userId: $userId) {
    id
    tickets(limit: $limit, offset: $offset) {
      id
      title
      createdAt
      ticketId
      no
      ticketName
      status
      priority
      requestorCode
      assigneeCode
      customerApprovedOn
      customerUrlTokenExpiresAt
      group {
        id
        ticketGroupId
      }
    }
    ticketsCount
  }
}
''';
