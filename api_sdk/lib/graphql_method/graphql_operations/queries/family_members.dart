const String familyMembers = '''
  query famMembers {
 famMembers {
    ID
    MemberCRN
    MemberFirstName
    MemberLastName
    MemberUserID
    Relationship
    Email
    PhoneNumber
    MemberName
  }
}
''';

const String familyInfo = '''
  query myfamilies {
    myfamilies {
        UserID
        Name
      }
  }
''';

const String familyMemberList = r'''
query familyMemberList($userId: String){
  hagrid(userId: $userId) {
    familyMembers {
      id
      memberName
      memberEmail
      memberUserId
      memberPhoneNumber
      crn
      relation
    }
  }
}
''';
