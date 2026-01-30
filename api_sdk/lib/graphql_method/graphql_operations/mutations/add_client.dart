const String createAgentClient =
    r'''mutation createClient($email: String, $isEmailUnknown: Boolean!, $name: String, $phoneNumber: String, $source: String) {
   createAgentClient(email: $email, isEmailUnknown: $isEmailUnknown, name: $name, phoneNumber: $phoneNumber, source: $source) {
        client {
            id
            taxyId
            email
            name
            phoneNumber
         }
    }
}''';
